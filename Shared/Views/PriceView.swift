//
//  PriceView.swift
//  RCFlowers4U
//
//  Created by Russell Archer on 05/02/2022.
//

import SwiftUI
import StoreKit

/// Displays a product price and a button that enables purchasing.
public struct PriceView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State private var canMakePayments: Bool = false
    @Binding var purchaseState: PurchaseState
    
    var productId: ProductId
    var price: String
    
    public var body: some View {
        HStack {
            Button(action: {
                withAnimation { purchaseState = .inProgress }
                viewModel.purchase(productId: productId) { status in
                    withAnimation { purchaseState = status }
                }
            }) {
                PriceButtonText(price: price, disabled: !canMakePayments)
            }
            .disabled(!canMakePayments)
        }
        .onAppear { canMakePayments = AppStore.canMakePayments }
    }
}

public struct PriceButtonText: View {
    var price: String
    var disabled: Bool
    
    public var body: some View {
        Text(disabled ? "Disabled" : price)
            .font(.body)
            .foregroundColor(.white)
            .padding()
            .frame(width: 100, height: 40)
            .fixedSize()
            .background(Color.blue)
            .cornerRadius(25)
            .padding(.leading, 10)
    }
}
