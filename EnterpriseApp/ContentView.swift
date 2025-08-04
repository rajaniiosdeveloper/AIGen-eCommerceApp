//
//  ContentView.swift
//  EnterpriseApp
//
//  Created by Chandan Singh on 04/08/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppStore.shared
    @StateObject private var router = AppRouter()
    
    var body: some View {
        NavigationView {
            HomeView(
                onProductTap: { product in
                    router.navigateToProductDetail(product)
                },
                onCartTap: {
                    router.navigateToCart()
                },
                onWishlistTap: {
                    router.navigateToWishlist()
                }
            )
            .environmentObject(store)
            .environmentObject(router)
        }
        .sheet(isPresented: $router.showingProductDetail) {
            if let product = router.selectedProduct {
                NavigationView {
                    ProductDetailView(
                        product: product,
                        onBuyNow: { product in
                            router.showingProductDetail = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                router.navigateToPayment(product: product)
                            }
                        }
                    )
                    .environmentObject(store)
                }
            }
        }
        .sheet(isPresented: $router.showingCart) {
            CartView(onCheckout: {
                router.showingCart = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    router.navigateToCheckout()
                }
            })
            .environmentObject(store)
        }
        .sheet(isPresented: $router.showingWishlist) {
            WishlistView(onProductTap: { product in
                router.showingWishlist = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    router.navigateToProductDetail(product)
                }
            })
            .environmentObject(store)
        }
        .sheet(isPresented: $router.showingPayment) {
            PaymentView(
                product: router.paymentProduct,
                isFromCart: router.isPaymentFromCart
            )
            .environmentObject(store)
        }
    }
}

#Preview {
    ContentView()
}
