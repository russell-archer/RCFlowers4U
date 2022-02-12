//
//  StoreConstants.swift
//  RCFlowers4U
//
//  Created by Russell Archer on 11/02/2022.
//

import Foundation

/// Constants used in support of App Store operations.
public struct StoreConstants {
    
    /// Returns the name of our Products .plist configuration file that holds the TEST and PROD list of `ProductId`.
    /// In this demo we're just using one list for both debug and release builds.
    #if DEBUG
    public static let productsList = "Products"
    #else
    public static let productsList = "Products"
    #warning("🔥 Check that StoreConstants.productsList identifies the correct list of product ids before release to production.")
    #endif
    
    /// The ID of the offering set on our RevenueCat dashboard.
    public static let offeringID = "default"
    
    /// The RevenueCat API Key. See "Important Security Note" in README.md.
    public static let revenueCatApiKey = ""
}
