//
//  ProductView.swift
//  RCFlowers4U
//
//  Created by Russell Archer on 05/02/2022.
//

import SwiftUI
import StoreKit
import WidgetKit

/// Displays a single row of product information for the main content List.
public struct ProductView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State private var purchaseState: PurchaseState = .unknown
    @State private var showInfoSheet = false
    var productId: ProductId
    var displayName: String
    var description: String
    var price: String
    
    public var body: some View {
        VStack {
            Text(displayName).font(.largeTitle).padding(.bottom, 1)
            Text(description)
                .font(.subheadline)
                .padding(EdgeInsets(top: 0, leading: 5, bottom: 3, trailing: 5))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            HStack {
                Image(productId)
                    .resizable()
                    .frame(maxWidth: 250, maxHeight: 250)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(25)
                
                Spacer()
                PurchaseButton(purchaseState: $purchaseState, productId: productId, price: price)
            }
            #if os(macOS)
            .frame(width: 500)
            #endif
            .padding()
            
            if purchaseState == .purchased { PurchaseInfoView(productId: productId)}
            else { ProductInfoView(productId: productId, displayName: displayName) { showInfoSheet.toggle()}}
            
            Divider()
        }
        .padding()
        .onAppear {
            Task.init { await purchaseState(for: productId)}
        }
        .onChange(of: viewModel.purchasedProducts) { _ in
            Task.init { await purchaseState(for: productId)}
        }
        .sheet(isPresented: $showInfoSheet) {
            ProductInfoSheet(showProductInfoSheet: $showInfoSheet, productId: productId)
        }
    }
    
    func purchaseState(for productId: ProductId) async {
        purchaseState = viewModel.isPurchased(productId: productId) ? .purchased : .unknown
    }
}


