//
//  RCFlowers4UApp.swift
//  Shared
//
//  Created by Russell Archer on 10/02/2022.
//

import SwiftUI

@main
struct RCFlowers4UApp: App {
    @StateObject var viewModel: ViewModel = ViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                #if os(macOS)
                .frame(minWidth: 700, idealWidth: 700, minHeight: 700, idealHeight: 700)
                .font(.title2)
                #endif
        }
    }
}
