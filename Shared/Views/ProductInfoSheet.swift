//
//  ProductInfoSheet.swift
//  RCFlowers4U
//
//  Created by Russell Archer on 07/02/2022.
//

import SwiftUI
import StoreKit

struct ProductInfoSheet: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var showProductInfoSheet: Bool
    var productId: ProductId
    
    var body: some View {
        VStack {
            SheetBarView(showSheet: $showProductInfoSheet, title: "Product Info")
            
            ScrollView {
                VStack {
                    // Show an image of the product
                    Image(productId)
                        .resizable()
                        .frame(maxWidth: 200, maxHeight: 200)
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(25)
                    
                    // Pull in the text appropriate for the product
                    switch productId {
                        case "com.rarcher.rcdemo.nonconsumable.flowers.large": ProductInfoFlowersLarge()
                        case "com.rarcher.rcdemo.nonconsumable.flowers.small": ProductInfoFlowersSmall()
                        default: ProductInfoDefault()
                    }
                }
                .padding(.bottom)
            }
        }
    }
}

struct ProductInfoFlowersLarge: View {
    @ViewBuilder var body: some View {
        Text("This is a information about the **Large Flowers** product.").font(.title2).padding().multilineTextAlignment(.center)
        Text("Add text and images explaining this product here.").font(.title3).padding().multilineTextAlignment(.center)
    }
}

struct ProductInfoFlowersSmall: View {
    @ViewBuilder var body: some View {
        Text("This is a information about the **Small Flowers** product.").font(.title2).padding().multilineTextAlignment(.center)
        Text("Add text and images explaining this product here.").font(.title3).padding().multilineTextAlignment(.center)
    }
}

struct ProductInfoDefault: View {
    @ViewBuilder var body: some View {
        Text("This is generic information about a product.").font(.title2).padding().multilineTextAlignment(.center)
        Text("Add text and images explaining your product here.").font(.title3).padding().multilineTextAlignment(.center)
    }
}

