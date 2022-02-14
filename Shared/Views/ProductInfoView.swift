//
//  ProductInfoView.swift
//  RCFlowers4U
//
//  Created by Russell Archer on 07/02/2022.
//

import SwiftUI

public struct ProductInfoView: View {
    var productId: ProductId
    var displayName: String
    var productInfoCompletion: (() -> Void)
    
    public var body: some View {
        Button(action: { productInfoCompletion()}) {
            HStack {
                Image(systemName: "info.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 30)
                Text("Info on \"\(displayName)\"")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .lineLimit(nil)
            }
            .padding()
        }
    }
}
