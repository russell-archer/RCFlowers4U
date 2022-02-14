//
//  PurchaseButton.swift
//  RCFlowers4U
//
//  Created by Russell Archer on 05/02/2022.
//

import SwiftUI
import StoreKit

/// Provides a button that enables the user to purchase a product.
/// The product's price is also displayed in the localized currency.
public struct PurchaseButton: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var purchaseState: PurchaseState
    
    var productId: ProductId
    var price: String
    
    public var body: some View {
        HStack {
            withAnimation { BadgeView(purchaseState: $purchaseState) }
            if purchaseState != .purchased {
                PriceView(purchaseState: $purchaseState, productId: productId, price: price)
            }
        }
    }
}
