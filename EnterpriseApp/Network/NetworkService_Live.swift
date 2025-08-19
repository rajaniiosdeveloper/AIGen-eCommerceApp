//
//  NetworkService_Live.swift
//  EnterpriseApp
//
//  Created by AI Assistant - Live API Integration
//

import Foundation
import Combine

// MARK: - API Configuration
struct APIConfig {
    static let baseURL = "http://localhost:3000"
    static let timeout: TimeInterval = 30.0
}

// MARK: - HTTP Method Enum
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

// MARK: - Error Response
struct APIErrorResponse: Codable {
    let status: String
    let message: String
}

// MARK: - API Response Models
struct APIResponse<T: Codable>: Codable {
    let status: String
    let data: T
    let message: String?
}

struct ProductsAPIResponse: Codable {
    let products: [APIProduct]
    let pagination: PaginationInfo?
}

struct PaginationInfo: Codable {
    let currentPage: Int
    let totalPages: Int
    let totalProducts: Int
    let hasNextPage: Bool
    let hasPrevPage: Bool
}

struct APIProduct: Codable {
    let id: String
    let title: String
    let description: String
    let price: Double
    let imageURL: String
    let category: String
    let categoryId: String?
    let rating: Double
    let stock: Int
    let brand: String
    let formattedPrice: String?
    let isInStock: Bool?
}

struct APIProductDetails: Codable {
    let product: APIProduct
}

struct CategoriesAPIResponse: Codable {
    let categories: [APICategory]
}

struct APICategory: Codable {
    let id: String
    let name: String
    let image: String?
    let productCount: Int
}

struct AuthAPIResponse: Codable {
    let user: APIUser
    let token: String
    let expiresIn: Int
}

struct APIUser: Codable {
    let id: String
    let name: String
    let email: String
}

struct UserProfileResponse: Codable {
    let user: APIUser
}

struct OrdersAPIResponse: Codable {
    let orders: [APIOrder]
}

struct APIOrder: Codable {
    let id: String
    let userId: String
    let totalAmount: Double
    let status: String
    let orderDate: String
    let shippingAddress: String
    let items: [APIOrderItem]
    let formattedTotal: String?
    let formattedDate: String?
}

struct APIOrderItem: Codable {
    let id: String
    let productId: String
    let productTitle: String
    let quantity: Int
    let price: Double
    let formattedPrice: String?
}

struct OrderDetailResponse: Codable {
    let order: APIOrder
}

struct OrderCreateResponse: Codable {
    let order: APIOrder
    let message: String?
}

struct CartAPIResponse: Codable {
    let items: [APICartItem]
    let totalAmount: Double
    let totalItems: Int
    let formattedTotal: String?
}

struct APICartItem: Codable {
    let id: String
    let productId: String
    let productTitle: String
    let productImage: String?
    let price: Double
    let quantity: Int
}

struct WishlistAPIResponse: Codable {
    let items: [APIWishlistItem]
    let totalItems: Int
}

struct APIWishlistItem: Codable {
    let id: String
    let productId: String
    let productTitle: String
    let productImage: String?
    let price: Double
    let addedAt: String
}

struct PaymentInitiateResponse: Codable {
    let paymentId: String
    let orderId: String
    let amount: Double
    let currency: String
    let paymentMethod: String
    let paymentUrl: String?
    let expiresAt: String?
}

struct PaymentVerifyResponse: Codable {
    let paymentId: String
    let status: String
    let transactionId: String?
    let processedAt: String
}

// MARK: - Live Network Service Implementation
class LiveNetworkService: NetworkServiceProtocol {
    static let shared = LiveNetworkService()
    
    private let session: URLSession
    private let decoder = JSONDecoder()
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConfig.timeout
        config.timeoutIntervalForResource = APIConfig.timeout * 2
        self.session = URLSession(configuration: config)
        
        // Configure JSON decoder for date parsing
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Private Helper Methods
    private func makeRequest(endpoint: String, method: HTTPMethod = .GET, body: Data? = nil, token: String? = nil) async throws -> Data {
        guard let url = URL(string: "\(APIConfig.baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                return data
            case 401:
                throw NetworkError.unauthorized
            case 400...499:
                let errorMessage = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
                throw NetworkError.serverError(httpResponse.statusCode, errorMessage?.message ?? "Client error")
            case 500...599:
                let errorMessage = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
                throw NetworkError.serverError(httpResponse.statusCode, errorMessage?.message ?? "Server error")
            default:
                throw NetworkError.serverError(httpResponse.statusCode, "Unknown error")
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            if (error as NSError).code == NSURLErrorTimedOut {
                throw NetworkError.timeoutError
            } else {
                throw NetworkError.networkFailure(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Product API Methods
    func fetchProducts(page: Int = 1, limit: Int = 20, category: String? = nil) async throws -> (products: [Product], hasMore: Bool, totalPages: Int) {
        var endpoint = "/api/products?page=\(page)&limit=\(limit)"
        if let category = category {
            endpoint += "&category=\(category)"
        }
        
        let data = try await makeRequest(endpoint: endpoint)
        let response = try decoder.decode(APIResponse<ProductsAPIResponse>.self, from: data)
        
        let products = response.data.products.map { apiProduct in
            Product(
                id: apiProduct.id,
                title: apiProduct.title,
                description: apiProduct.description,
                price: apiProduct.price,
                imageURL: apiProduct.imageURL,
                category: apiProduct.category,
                rating: apiProduct.rating,
                stock: apiProduct.stock,
                brand: apiProduct.brand
            )
        }
        
        let hasMore = response.data.pagination?.hasNextPage ?? false
        let totalPages = response.data.pagination?.totalPages ?? 1
        
        return (products, hasMore, totalPages)
    }
    
    func fetchProduct(id: String) async throws -> Product {
        let data = try await makeRequest(endpoint: "/api/products/\(id)")
        let response = try decoder.decode(APIResponse<APIProductDetails>.self, from: data)
        
        return Product(
            id: response.data.product.id,
            title: response.data.product.title,
            description: response.data.product.description,
            price: response.data.product.price,
            imageURL: response.data.product.imageURL,
            category: response.data.product.category,
            rating: response.data.product.rating,
            stock: response.data.product.stock,
            brand: response.data.product.brand
        )
    }
    
    func searchProducts(query: String) async throws -> [Product] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw NetworkError.invalidURL
        }
        
        let data = try await makeRequest(endpoint: "/api/products?search=\(encodedQuery)")
        let response = try decoder.decode(APIResponse<ProductsAPIResponse>.self, from: data)
        
        return response.data.products.map { apiProduct in
            Product(
                id: apiProduct.id,
                title: apiProduct.title,
                description: apiProduct.description,
                price: apiProduct.price,
                imageURL: apiProduct.imageURL,
                category: apiProduct.category,
                rating: apiProduct.rating,
                stock: apiProduct.stock,
                brand: apiProduct.brand
            )
        }
    }
    
    func fetchProductsByCategory(categoryId: String) async throws -> [Product] {
        let data = try await makeRequest(endpoint: "/api/categories/\(categoryId)/products")
        let response = try decoder.decode(APIResponse<ProductsAPIResponse>.self, from: data)
        
        return response.data.products.map { apiProduct in
            Product(
                id: apiProduct.id,
                title: apiProduct.title,
                description: apiProduct.description,
                price: apiProduct.price,
                imageURL: apiProduct.imageURL,
                category: apiProduct.category,
                rating: apiProduct.rating,
                stock: apiProduct.stock,
                brand: apiProduct.brand
            )
        }
    }
    
    // MARK: - Authentication API Methods
    func signIn(email: String, password: String) async throws -> AuthResponse {
        let requestBody = ["email": email, "password": password]
        let bodyData = try JSONEncoder().encode(requestBody)
        
        let data = try await makeRequest(endpoint: "/api/auth/signin", method: .POST, body: bodyData)
        let response = try decoder.decode(APIResponse<AuthAPIResponse>.self, from: data)
        
        return AuthResponse(
            user: User(
                id: response.data.user.id,
                name: response.data.user.name,
                email: response.data.user.email
            ),
            token: response.data.token,
            refreshToken: nil,
            expiresIn: response.data.expiresIn
        )
    }
    
    func register(name: String, email: String, password: String) async throws -> AuthResponse {
        let requestBody = ["name": name, "email": email, "password": password]
        let bodyData = try JSONEncoder().encode(requestBody)
        
        let data = try await makeRequest(endpoint: "/api/auth/register", method: .POST, body: bodyData)
        let response = try decoder.decode(APIResponse<AuthAPIResponse>.self, from: data)
        
        return AuthResponse(
            user: User(
                id: response.data.user.id,
                name: response.data.user.name,
                email: response.data.user.email
            ),
            token: response.data.token,
            refreshToken: nil,
            expiresIn: response.data.expiresIn
        )
    }
    
    func getUserProfile(token: String) async throws -> User {
        let data = try await makeRequest(endpoint: "/api/auth/profile", token: token)
        let response = try decoder.decode(APIResponse<UserProfileResponse>.self, from: data)
        
        return User(
            id: response.data.user.id,
            name: response.data.user.name,
            email: response.data.user.email
        )
    }
    
    // MARK: - Category API Methods
    func fetchCategories() async throws -> [Category] {
        let data = try await makeRequest(endpoint: "/api/categories")
        let response = try decoder.decode(APIResponse<CategoriesAPIResponse>.self, from: data)
        
        return response.data.categories.map { apiCategory in
            Category(
                id: apiCategory.id,
                name: apiCategory.name,
                imageURL: apiCategory.image,
                productCount: apiCategory.productCount
            )
        }
    }
    
    // MARK: - Order API Methods
    func fetchOrders(token: String) async throws -> [Order] {
        let data = try await makeRequest(endpoint: "/api/orders", token: token)
        let response = try decoder.decode(APIResponse<OrdersAPIResponse>.self, from: data)
        
        return response.data.orders.map { apiOrder in
            let orderStatus = OrderStatus(rawValue: apiOrder.status) ?? .pending
            let dateFormatter = ISO8601DateFormatter()
            let orderDate = dateFormatter.date(from: apiOrder.orderDate) ?? Date()
            
            let orderItems = apiOrder.items.map { apiItem in
                OrderItem(
                    id: apiItem.id,
                    productId: apiItem.productId,
                    productTitle: apiItem.productTitle,
                    productImageURL: "", // API doesn't return image URL in order items
                    quantity: apiItem.quantity,
                    unitPrice: apiItem.price
                )
            }
            
            return Order(
                id: apiOrder.id,
                userId: apiOrder.userId,
                items: orderItems,
                totalAmount: apiOrder.totalAmount,
                status: orderStatus,
                orderDate: orderDate,
                shippingAddress: apiOrder.shippingAddress
            )
        }
    }
    
    func fetchOrder(orderId: String, token: String) async throws -> Order {
        let data = try await makeRequest(endpoint: "/api/orders/\(orderId)", token: token)
        let response = try decoder.decode(APIResponse<OrderDetailResponse>.self, from: data)
        
        let orderStatus = OrderStatus(rawValue: response.data.order.status) ?? .pending
        let dateFormatter = ISO8601DateFormatter()
        let orderDate = dateFormatter.date(from: response.data.order.orderDate) ?? Date()
        
        let orderItems = response.data.order.items.map { apiItem in
            OrderItem(
                id: apiItem.id,
                productId: apiItem.productId,
                productTitle: apiItem.productTitle,
                productImageURL: "",
                quantity: apiItem.quantity,
                unitPrice: apiItem.price
            )
        }
        
        return Order(
            id: response.data.order.id,
            userId: response.data.order.userId,
            items: orderItems,
            totalAmount: response.data.order.totalAmount,
            status: orderStatus,
            orderDate: orderDate,
            shippingAddress: response.data.order.shippingAddress
        )
    }
    
    func createOrder(token: String, shippingAddress: String) async throws -> Order {
        let requestBody = ["shippingAddress": shippingAddress]
        let bodyData = try JSONEncoder().encode(requestBody)
        
        let data = try await makeRequest(endpoint: "/api/orders", method: .POST, body: bodyData, token: token)
        let response = try decoder.decode(APIResponse<OrderCreateResponse>.self, from: data)
        
        let orderStatus = OrderStatus(rawValue: response.data.order.status) ?? .pending
        let dateFormatter = ISO8601DateFormatter()
        let orderDate = dateFormatter.date(from: response.data.order.orderDate) ?? Date()
        
        let orderItems = response.data.order.items.map { apiItem in
            OrderItem(
                id: apiItem.id,
                productId: apiItem.productId,
                productTitle: apiItem.productTitle,
                productImageURL: "",
                quantity: apiItem.quantity,
                unitPrice: apiItem.price
            )
        }
        
        return Order(
            id: response.data.order.id,
            userId: response.data.order.userId,
            items: orderItems,
            totalAmount: response.data.order.totalAmount,
            status: orderStatus,
            orderDate: orderDate,
            shippingAddress: response.data.order.shippingAddress
        )
    }
    
    // MARK: - Cart API Methods
    func addToCart(productId: String, quantity: Int) async throws -> Void {
        let requestBody = ["productId": productId, "quantity": quantity] as [String : Any]
        let bodyData = try JSONSerialization.data(withJSONObject: requestBody)
        
        _ = try await makeRequest(endpoint: "/api/cart", method: .POST, body: bodyData)
    }
    
    func getCart() async throws -> [CartItem] {
        let data = try await makeRequest(endpoint: "/api/cart")
        let response = try decoder.decode(APIResponse<CartAPIResponse>.self, from: data)
        
        return response.data.items.map { apiCartItem in
            let product = Product(
                id: apiCartItem.productId,
                title: apiCartItem.productTitle,
                description: "",
                price: apiCartItem.price,
                imageURL: apiCartItem.productImage ?? "",
                category: "",
                rating: 0,
                stock: 10,
                brand: ""
            )
            
            return CartItem(product: product, quantity: apiCartItem.quantity)
        }
    }
    
    func updateCartItem(itemId: String, quantity: Int) async throws -> Void {
        let requestBody = ["quantity": quantity]
        let bodyData = try JSONEncoder().encode(requestBody)
        
        _ = try await makeRequest(endpoint: "/api/cart/\(itemId)", method: .PUT, body: bodyData)
    }
    
    func removeFromCart(itemId: String) async throws -> Void {
        _ = try await makeRequest(endpoint: "/api/cart/\(itemId)", method: .DELETE)
    }
    
    func clearCart() async throws -> Void {
        _ = try await makeRequest(endpoint: "/api/cart", method: .DELETE)
    }
    
    // MARK: - Wishlist API Methods
    func addToWishlist(productId: String) async throws -> Void {
        let requestBody = ["productId": productId]
        let bodyData = try JSONEncoder().encode(requestBody)
        
        _ = try await makeRequest(endpoint: "/api/wishlist", method: .POST, body: bodyData)
    }
    
    func getWishlist() async throws -> [WishlistItem] {
        let data = try await makeRequest(endpoint: "/api/wishlist")
        let response = try decoder.decode(APIResponse<WishlistAPIResponse>.self, from: data)
        
        return response.data.items.map { apiWishlistItem in
            let product = Product(
                id: apiWishlistItem.productId,
                title: apiWishlistItem.productTitle,
                description: "",
                price: apiWishlistItem.price,
                imageURL: apiWishlistItem.productImage ?? "",
                category: "",
                rating: 0,
                stock: 10,
                brand: ""
            )
            
            return WishlistItem(product: product)
        }
    }
    
    func removeFromWishlist(itemId: String) async throws -> Void {
        _ = try await makeRequest(endpoint: "/api/wishlist/\(itemId)", method: .DELETE)
    }
    
    // MARK: - Payment API Methods
    func initiatePayment(orderId: String, paymentMethod: String) async throws -> PaymentInfo {
        let requestBody = ["orderId": orderId, "paymentMethod": paymentMethod]
        let bodyData = try JSONEncoder().encode(requestBody)
        
        let data = try await makeRequest(endpoint: "/api/payment/initiate", method: .POST, body: bodyData)
        let response = try decoder.decode(APIResponse<PaymentInitiateResponse>.self, from: data)
        
        return PaymentInfo(
            paymentId: response.data.paymentId,
            orderId: response.data.orderId,
            amount: response.data.amount,
            currency: response.data.currency,
            paymentMethod: response.data.paymentMethod,
            paymentUrl: response.data.paymentUrl,
            expiresAt: response.data.expiresAt
        )
    }
    
    func verifyPayment(paymentId: String, signature: String) async throws -> PaymentResult {
        let requestBody = ["paymentId": paymentId, "signature": signature]
        let bodyData = try JSONEncoder().encode(requestBody)
        
        let data = try await makeRequest(endpoint: "/api/payment/verify", method: .POST, body: bodyData)
        let response = try decoder.decode(APIResponse<PaymentVerifyResponse>.self, from: data)
        
        return PaymentResult(
            paymentId: response.data.paymentId,
            status: response.data.status,
            transactionId: response.data.transactionId,
            processedAt: response.data.processedAt
        )
    }
}