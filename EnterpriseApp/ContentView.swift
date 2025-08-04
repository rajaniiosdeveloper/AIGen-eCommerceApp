//
//  ContentView.swift
//  EnterpriseApp
//
//  Created by Chandan Singh on 04/08/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var router = AppRouter()
    @StateObject private var authManager = AuthenticationManager.shared
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                mainAppView
            } else {
                SignInView {
                    // Navigation handled by AuthenticationManager state change
                }
            }
        }
    }
    
    private var mainAppView: some View {
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
                },
                onMenuTap: {
                    router.navigateToMenu()
                }
            )
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
        }
        .sheet(isPresented: $router.showingWishlist) {
            WishlistView(onProductTap: { product in
                router.showingWishlist = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    router.navigateToProductDetail(product)
                }
            })
        }
        .sheet(isPresented: $router.showingPayment) {
            PaymentView(
                product: router.paymentProduct,
                isFromCart: router.isPaymentFromCart
            )
        }
        .sheet(isPresented: $router.showingMenu) {
            MenuView(
                onOrderHistoryTap: {
                    router.showingMenu = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        router.navigateToOrderHistory()
                    }
                },
                onSignOutTap: {
                    router.showingMenu = false
                    authManager.signOut()
                }
            )
        }
        .sheet(isPresented: $router.showingOrderHistory) {
            OrderHistoryView(
                onOrderTap: { order in
                    router.showingOrderHistory = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        router.navigateToOrderDetail(order)
                    }
                }
            )
        }
        .sheet(isPresented: $router.showingOrderDetail) {
            if let order = router.selectedOrder {
                OrderDetailView(order: order)
            }
        }
    }
}

#Preview {
    ContentView()
}
