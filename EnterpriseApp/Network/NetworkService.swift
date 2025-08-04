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
    func fetchProducts() async throws -> [Product]
    func fetchProduct(id: String) async throws -> Product
    func searchProducts(query: String) async throws -> [Product]
    
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
}