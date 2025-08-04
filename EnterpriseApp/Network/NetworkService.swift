//
//  NetworkService.swift
//  EnterpriseApp
//
//  Created by AI Assistant
//

import Foundation
import Combine

// MARK: - Network Service Protocol
protocol NetworkServiceProtocol {
    // Product APIs
    func fetchProducts() async throws -> [Product]
    func fetchProduct(id: String) async throws -> Product
    func searchProducts(query: String) async throws -> [Product]
    func fetchProductsByCategory(categoryId: String) async throws -> [Product]
    
    // Authentication APIs
    func signIn(email: String, password: String) async throws -> AuthResponse
    func register(name: String, email: String, password: String) async throws -> AuthResponse
    func refreshToken(_ token: String) async throws -> AuthResponse
    
    // Category APIs
    func fetchCategories() async throws -> [Category]
    
    // Order APIs
    func fetchOrders(userId: String) async throws -> [Order]
    func fetchOrder(orderId: String) async throws -> Order
    func createOrder(userId: String, items: [CartItem], shippingAddress: String) async throws -> Order
    
    // Combine versions for backward compatibility
    func fetchProductsPublisher() -> AnyPublisher<[Product], Error>
    func fetchProductPublisher(id: String) -> AnyPublisher<Product, Error>
    func searchProductsPublisher(query: String) -> AnyPublisher<[Product], Error>
}

// MARK: - Network Service Implementation
class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    
    private let baseURL = "https://dummyjson.com/products"
    private let session = URLSession.shared
    
    private init() {}
    
    // MARK: - Async/Await API Methods
    func fetchProducts() async throws -> [Product] {
        // For development/demo purposes, we'll use mock data
        // In production, uncomment the real API call below
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        return MockData.sampleProducts
        
        // Real API implementation (uncomment for production):
        /*
        guard let url = URL(string: baseURL) else {
            throw APIError(message: "Invalid URL", code: -1)
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError(message: "Invalid response", code: -1)
        }
        
        let productsResponse = try JSONDecoder().decode(ProductsResponse.self, from: data)
        return productsResponse.products
        */
    }
    
    func fetchProduct(id: String) async throws -> Product {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        if let product = MockData.sampleProducts.first(where: { $0.id == id }) {
            return product
        } else {
            throw APIError(message: "Product not found", code: 404)
        }
        
        // Real API implementation (uncomment for production):
        /*
        guard let url = URL(string: "\(baseURL)/\(id)") else {
            throw APIError(message: "Invalid URL", code: -1)
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError(message: "Invalid response", code: -1)
        }
        
        return try JSONDecoder().decode(Product.self, from: data)
        */
    }
    
    func searchProducts(query: String) async throws -> [Product] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        let filteredProducts = MockData.sampleProducts.filter { product in
            product.title.localizedCaseInsensitiveContains(query) ||
            product.description.localizedCaseInsensitiveContains(query) ||
            product.category.localizedCaseInsensitiveContains(query)
        }
        
        return filteredProducts
        
        // Real API implementation (uncomment for production):
        /*
        guard let url = URL(string: "\(baseURL)/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            throw APIError(message: "Invalid URL", code: -1)
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError(message: "Invalid response", code: -1)
        }
        
        let productsResponse = try JSONDecoder().decode(ProductsResponse.self, from: data)
        return productsResponse.products
        */
    }
    
    // MARK: - Combine Compatibility Methods
    func fetchProductsPublisher() -> AnyPublisher<[Product], Error> {
        return Future { promise in
            Task {
                do {
                    let products = try await self.fetchProducts()
                    promise(.success(products))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func fetchProductPublisher(id: String) -> AnyPublisher<Product, Error> {
        return Future { promise in
            Task {
                do {
                    let product = try await self.fetchProduct(id: id)
                    promise(.success(product))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func searchProductsPublisher(query: String) -> AnyPublisher<[Product], Error> {
        return Future { promise in
            Task {
                do {
                    let products = try await self.searchProducts(query: query)
                    promise(.success(products))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    // MARK: - Real API Implementation (commented for reference)
    /*
    func fetchProducts() -> AnyPublisher<[Product], Error> {
        guard let url = URL(string: baseURL) else {
            return Fail(error: APIError(message: "Invalid URL", code: -1))
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: ProductsResponse.self, decoder: JSONDecoder())
            .map(\.products)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    */
}

// MARK: - Mock Data for Development
struct MockData {
    static let sampleProducts: [Product] = [
        Product(
            title: "iPhone 15 Pro",
            description: "The latest iPhone with A17 Pro chip, titanium design, and advanced camera system. Perfect for photography enthusiasts and power users who demand the best mobile experience.",
            price: 134900.00,
            imageURL: "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=500",
            category: "Electronics",
            rating: 4.8,
            stock: 15,
            brand: "Apple"
        ),
        Product(
            title: "MacBook Air M2",
            description: "Supercharged by M2 chip for incredible performance. Ultra-thin design with all-day battery life, perfect for students and professionals.",
            price: 114900.00,
            imageURL: "https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=500",
            category: "Electronics",
            rating: 4.9,
            stock: 8,
            brand: "Apple"
        ),
        Product(
            title: "AirPods Pro",
            description: "Active Noise Cancellation, Transparency mode, and spatial audio. The ultimate wireless earbuds for immersive sound experience.",
            price: 24900.00,
            imageURL: "https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?w=500",
            category: "Electronics",
            rating: 4.7,
            stock: 25,
            brand: "Apple"
        ),
        Product(
            title: "Nike Air Max 270",
            description: "Comfortable running shoes with Air Max cushioning. Perfect for daily workouts and casual wear with modern style.",
            price: 12995.00,
            imageURL: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500",
            category: "Fashion",
            rating: 4.5,
            stock: 30,
            brand: "Nike"
        ),
        Product(
            title: "Samsung 55\" 4K TV",
            description: "Crystal clear 4K display with smart TV features. Experience your favorite shows and movies in stunning detail with vibrant colors.",
            price: 54999.00,
            imageURL: "https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=500",
            category: "Electronics",
            rating: 4.6,
            stock: 12,
            brand: "Samsung"
        ),
        Product(
            title: "Coffee Maker Pro",
            description: "Professional grade coffee maker with multiple brewing options. Start your day with perfectly brewed coffee every morning.",
            price: 8999.00,
            imageURL: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=500",
            category: "Home",
            rating: 4.4,
            stock: 20,
            brand: "BrewMaster"
        ),
        Product(
            title: "Wireless Headphones",
            description: "Premium wireless headphones with noise cancellation and 30-hour battery life. Perfect for music lovers and frequent travelers.",
            price: 15999.00,
            imageURL: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500",
            category: "Electronics",
            rating: 4.3,
            stock: 18,
            brand: "SoundMax"
        ),
        Product(
            title: "Gaming Laptop",
            description: "High-performance gaming laptop with RTX graphics and 144Hz display. Built for serious gamers who demand smooth gameplay.",
            price: 89999.00,
            imageURL: "https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=500",
            category: "Electronics",
            rating: 4.7,
            stock: 6,
            brand: "GameForce"
        )
    ]
    
    // MARK: - Mock Categories
    static let sampleCategories: [Category] = [
        Category(id: "cat1", name: "Electronics", imageURL: "https://images.unsplash.com/photo-1498049794561-7780e7231661?w=500", productCount: 6),
        Category(id: "cat2", name: "Fashion", imageURL: "https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=500", productCount: 1),
        Category(id: "cat3", name: "Home", imageURL: "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=500", productCount: 1),
        Category(id: "cat4", name: "Sports", imageURL: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500", productCount: 0),
        Category(id: "cat5", name: "Books", imageURL: "https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=500", productCount: 0),
        Category(id: "cat6", name: "Beauty", imageURL: "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=500", productCount: 0)
    ]
    
    // MARK: - Mock Orders
    static let sampleOrders: [Order] = [
        Order(
            id: "ord1",
            userId: "user1",
            items: [
                OrderItem(productId: "1", productTitle: "iPhone 15 Pro", productImageURL: "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=500", quantity: 1, unitPrice: 134900.00),
                OrderItem(productId: "3", productTitle: "AirPods Pro", productImageURL: "https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?w=500", quantity: 2, unitPrice: 24900.00)
            ],
            totalAmount: 184700.00,
            status: .delivered,
            orderDate: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date(),
            deliveryDate: Calendar.current.date(byAdding: .day, value: -12, to: Date()),
            shippingAddress: "123 Main St, Mumbai, MH 400001"
        ),
        Order(
            id: "ord2",
            userId: "user1",
            items: [
                OrderItem(productId: "2", productTitle: "MacBook Air M2", productImageURL: "https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=500", quantity: 1, unitPrice: 114900.00)
            ],
            totalAmount: 114900.00,
            status: .shipped,
            orderDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            deliveryDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
            shippingAddress: "456 Park Ave, Delhi, DL 110001"
        ),
        Order(
            id: "ord3",
            userId: "user1",
            items: [
                OrderItem(productId: "4", productTitle: "Nike Air Max 270", productImageURL: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500", quantity: 1, unitPrice: 12995.00),
                OrderItem(productId: "7", productTitle: "Wireless Headphones", productImageURL: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500", quantity: 1, unitPrice: 15999.00)
            ],
            totalAmount: 28994.00,
            status: .processing,
            orderDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            shippingAddress: "789 Tech Plaza, Bangalore, KA 560001"
        )
    ]
    
    // MARK: - Mock Users
    static let sampleUsers: [User] = [
        User(id: "user1", name: "John Doe", email: "john@example.com"),
        User(id: "user2", name: "Jane Smith", email: "jane@example.com")
    ]
}

// MARK: - NetworkService Extended Implementation
extension NetworkService {
    
    // MARK: - Product Category Methods
    func fetchProductsByCategory(categoryId: String) async throws -> [Product] {
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        let category = MockData.sampleCategories.first { $0.id == categoryId }
        guard let categoryName = category?.name else {
            return MockData.sampleProducts
        }
        
        return MockData.sampleProducts.filter { $0.category == categoryName }
    }
    
    // MARK: - Authentication Methods
    func signIn(email: String, password: String) async throws -> AuthResponse {
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Simple mock authentication - in production, this would be a real API call
        guard email.contains("@") && password.count >= 6 else {
            throw APIError(message: "Invalid email or password", code: 401)
        }
        
        // Mock successful authentication
        let user = MockData.sampleUsers.first { $0.email == email } 
                  ?? User(name: "Demo User", email: email)
        
        return AuthResponse(
            user: user,
            token: "mock_jwt_token_\(UUID().uuidString)",
            refreshToken: "mock_refresh_token_\(UUID().uuidString)",
            expiresIn: 3600 // 1 hour
        )
    }
    
    func register(name: String, email: String, password: String) async throws -> AuthResponse {
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        guard !name.isEmpty && email.contains("@") && password.count >= 6 else {
            throw APIError(message: "Invalid registration data", code: 400)
        }
        
        // Check if user already exists (mock check)
        if MockData.sampleUsers.contains(where: { $0.email == email }) {
            throw APIError(message: "User already exists", code: 409)
        }
        
        let newUser = User(name: name, email: email)
        
        return AuthResponse(
            user: newUser,
            token: "mock_jwt_token_\(UUID().uuidString)",
            refreshToken: "mock_refresh_token_\(UUID().uuidString)",
            expiresIn: 3600
        )
    }
    
    func refreshToken(_ token: String) async throws -> AuthResponse {
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Mock token refresh
        let user = MockData.sampleUsers.first ?? User(name: "Demo User", email: "demo@example.com")
        
        return AuthResponse(
            user: user,
            token: "refreshed_jwt_token_\(UUID().uuidString)",
            refreshToken: "refreshed_refresh_token_\(UUID().uuidString)",
            expiresIn: 3600
        )
    }
    
    // MARK: - Category Methods
    func fetchCategories() async throws -> [Category] {
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        return MockData.sampleCategories
    }
    
    // MARK: - Order Methods
    func fetchOrders(userId: String) async throws -> [Order] {
        try await Task.sleep(nanoseconds: 400_000_000) // 0.4 seconds
        
        // Filter orders by userId (in production, this would be handled by the API)
        return MockData.sampleOrders.filter { $0.userId == userId }
                                   .sorted { $0.orderDate > $1.orderDate }
    }
    
    func fetchOrder(orderId: String) async throws -> Order {
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        guard let order = MockData.sampleOrders.first(where: { $0.id == orderId }) else {
            throw APIError(message: "Order not found", code: 404)
        }
        
        return order
    }
    
    func createOrder(userId: String, items: [CartItem], shippingAddress: String) async throws -> Order {
        try await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
        
        guard !items.isEmpty else {
            throw APIError(message: "Cart is empty", code: 400)
        }
        
        let orderItems = items.map { cartItem in
            OrderItem(
                productId: cartItem.product.id,
                productTitle: cartItem.product.title,
                productImageURL: cartItem.product.imageURL,
                quantity: cartItem.quantity,
                unitPrice: cartItem.product.price
            )
        }
        
        let totalAmount = orderItems.reduce(0) { $0 + $1.totalPrice }
        
        let newOrder = Order(
            userId: userId,
            items: orderItems,
            totalAmount: totalAmount,
            status: .pending,
            shippingAddress: shippingAddress
        )
        
        return newOrder
    }
}