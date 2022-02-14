//
//  ContentView.swift
//  RCFlowers4U
//
//  Created by Russell Archer on 03/02/2022.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State private var showProductInfoSheet = false
    @State private var canMakePayments = true
    
    var body: some View {
        ScrollView {
            VStack {
                if viewModel.hasProducts {
                    
                    if viewModel.hasNonConsumableProducts, let nonConsumables = viewModel.nonConsumableProducts {
                        Section(header: Text("Products")) {
                            ForEach(nonConsumables, id: \.productIdentifier) { product in
                                ProductView(productId: product.productIdentifier,
                                            displayName: product.localizedTitle,
                                            description: product.localizedDescription,
                                            price: viewModel.price(for: product.productIdentifier) ?? "Price Unknown")
                            }
                        }
                    }
                    
                    if viewModel.hasSubscriptionProducts, let subscriptions = viewModel.subscriptionProducts {
                        Section(header: Text("Subscriptions")) {
                            ForEach(subscriptions, id: \.productIdentifier) { product in
                                ProductView(productId: product.productIdentifier,
                                            displayName: product.localizedTitle,
                                            description: product.localizedDescription,
                                            price: viewModel.price(for: product.productIdentifier) ?? "Price Unknown")
                            }
                        }
                    }
                    
                    if !canMakePayments {
                        Spacer()
                        Text("Purchases are not permitted on your device.")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    
                } else {
                    
                    Button("Refresh Products") { viewModel.refreshProducts()}.buttonStyle(.borderedProminent).padding()
                }
            }
            .onAppear { canMakePayments = viewModel.canMakePayments }
        }
    }
}

