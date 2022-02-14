//
//  PurchaseInfoView.swift
//  RCFlowers4U
//
//  Created by Russell Archer on 07/02/2022.
//

import SwiftUI

/// Displays information on a consumable or non-consumable purchase.
public struct PurchaseInfoView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State private var purchaseInfoText = ""
    var productId: ProductId
    
    public var body: some View {
        
        HStack(alignment: .center) {
            Image(systemName: "creditcard.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.blue)
                .frame(height: 30)
            
            Text(purchaseInfoText)
                .font(.subheadline)
                .foregroundColor(.blue)
                .lineLimit(nil)
        }
        .padding()
        .onAppear {
            purchaseInfoText = viewModel.info(for: productId)
        }
    }
}
