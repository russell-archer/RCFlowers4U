//
//  ViewModel.swift
//  RCFlowers4U
//
//  Created by Russell Archer on 13/02/2022.
//

import Purchases
import StoreKit

public typealias ProductId = String

/// The state of a purchase.
enum PurchaseState { case notStarted, userCannotMakePayments, inProgress, purchased, pending, cancelled, failed, failedVerification, unknown }

/// ViewModel singleton. Sits between ContentView and its subviews and the RevenueCat Purchases framework
class ViewModel: NSObject, ObservableObject {
    
    /// Singleton access. Use ViewModel.shared to access all properties and methods.
    static let shared = ViewModel()
    
    /// Array of `Product` retrieved from RevenueCat and available for purchase.
    @Published private(set) var products: [SKProduct]?
    
    /// Array of `ProductId` for products that have been purchased. This array is primarily used to trigger
    /// updates in the UI. It is not persisted but re-built as required whenever a purchase successfully
    /// completes, or when a call is made to `isPurchased(product:)`.
    @Published private(set) var purchasedProducts = [ProductId]()
    
    /// The current state of a purchase. Used to trigger UI changes
    @Published private(set) var purchaseState: PurchaseState = .notStarted
    
    /// Array of packages retrieved from RevenueCat.
    private(set) var packages: [Purchases.Package]?
    
    // MARK: - Public helper properties
    var nonConsumableProducts:       [SKProduct]? { products?.filter { $0.subscriptionGroupIdentifier == nil }}
    var subscriptionProducts:        [SKProduct]? { products?.filter { $0.subscriptionGroupIdentifier != nil }}
    var nonConsumableProductIds:     [ProductId]? { nonConsumableProducts?.map { $0.productIdentifier }}
    var subscriptionProductIds:      [ProductId]? { subscriptionProducts?.map { $0.productIdentifier }}
    var hasPackages:                 Bool         { packages?.count ?? 0 > 0 ? true : false }
    var hasProducts:                 Bool         { products?.count ?? 0 > 0 ? true : false }
    var hasNonConsumableProducts:    Bool         { nonConsumableProducts?.count ?? 0 > 0 ? true : false }
    var hasSubscriptionProducts:     Bool         { subscriptionProducts?.count ?? 0 > 0 ? true : false }
    var hasNonConsumableProductIds:  Bool         { nonConsumableProductIds?.count ?? 0 > 0 ? true : false }
    var hasSubscriptionProductIds:   Bool         { subscriptionProductIds?.count ?? 0 > 0 ? true : false }
    var canMakePayments:             Bool         { AppStore.canMakePayments }
    
    private override init() {
        super.init()
        
        if !AppStore.canMakePayments { purchaseState = .userCannotMakePayments }
        
        // Configure RC with our API key and an anonymous user
        Purchases.logLevel = .info
        Purchases.configure(withAPIKey: StoreConstants.revenueCatApiKey)
        Purchases.shared.delegate = self  // Set ourselves as the delegate for `RCPurchases`
        
        Task.init { await refreshProducts()}
    }
    
    /// Get localized product info from RevenueCat. Sets the @Published products property
    @MainActor func refreshProducts() {
        Purchases.shared.offerings { offerings, error in
            guard error == nil, let allOfferings = offerings, let currentOfferings = allOfferings.current else { return }
            self.packages = currentOfferings.availablePackages
            guard self.hasPackages else { return }
            
            var availableProducts = [SKProduct]()
            self.packages?.forEach { package in
                availableProducts.append(package.product)
            }
            
            self.products = availableProducts  // products is a @Published property so we can use it to update the UI
        }
    }
    
    /// Gets the localized price for the product `Package` identified by `ProductId`.
    /// - Parameter productId: The `ProductId` of the package whose price you want.
    /// - Returns: Returns the localized price for the product `Package` identified by `ProductId`.
    func price(for productId: ProductId) -> String? {
        guard hasPackages, let package = package(from: productId) else { return nil }
        return package.localizedPriceString
    }
    
    /// Gets a product `Package`. A `Package` contains one or more products that are equivalent across different stores.
    /// For example, you may have a "Large Roses" product that is available on the App Store and Google Play, but not
    /// on the Amazon store. In this case, the package would contain two products. A package cannot contain multiple
    /// products for the same store. Only the products appropriate for the Apple App Store are returned.
    /// - Parameter productId: The product's `ProductId`.
    /// - Returns: Returns the `Package` identified by the `ProductId`.
    func package(from productId: ProductId) -> Purchases.Package? {
        guard hasPackages else { return nil }
        let package = packages!.filter { package in package.product.productIdentifier == productId }
        return package.count > 0 ? package.first : nil
    }
    
    /// Purchase a product from the App Store via RevenueCat.
    /// - Parameters:
    ///   - productId: The product's `ProductId`.
    ///   - completion: A completion closure that will be called when the purchase process completes.
    func purchase(productId: ProductId, completion: @escaping (PurchaseState) -> Void) {
        purchaseState = .inProgress
        guard let package = package(from: productId) else {
            purchaseState = .failed
            completion(purchaseState)
            return
        }
        
        Purchases.shared.purchasePackage(package) { [self] transaction, info, error, userCancelled in
            guard error == nil else {
                print("Purchase of \(productId) failed with error \(error!.localizedDescription)")
                purchaseState = .failed
                completion(purchaseState)
                return
            }
            
            guard !userCancelled else {
                print("Purchase of \(productId) cancelled by user")
                purchaseState = .cancelled
                completion(purchaseState)
                return
            }
            
            guard let purchaseInfo = info else {
                purchaseState = .failed
                completion(purchaseState)
                return
            }
            
            if let entitlementInfo = purchaseInfo.entitlements[StoreEntitlements.id(from: productId)],
               entitlementInfo.isActive,
               entitlementInfo.productIdentifier == productId {
                
                print("Product \(productId) successfully purchased")
                if !purchasedProducts.contains(productId) { purchasedProducts.append(productId)}
                purchaseState = .purchased
                completion(purchaseState)
                
            } else {
                print("Purchase of product \(productId) failed (entitlements)")
                purchaseState = .failed
                completion(purchaseState)
            }
        }
    }
    
    /// Determines if a product has been purchased by the current user. Works for non-consumables and subscriptions.
    /// - Parameter productId: The product's `ProductId`.
    /// - Returns: Returns true if the product has been purchased, false otherwise.
    func isPurchased(productId: ProductId) -> Bool {
        var info: Purchases.PurchaserInfo?
        
        Purchases.shared.purchaserInfo { purchaserInfo, error in
            info = purchaserInfo
        }
        
        guard let pi = info else { return false }

        if isSubscription(productId: productId) { return pi.entitlements[StoreEntitlements.id(from: productId)]?.isActive ?? false }
        else { return pi.nonSubscriptionTransactions.filter { transaction in transaction.productId == productId }.count > 0 }
    }
    
    /// Gets formatted text information on the purchase status of a product. Works for non-consumables and subscriptions.
    /// - Parameter productId: The `ProductId`.
    /// - Returns: Returns information on the purchase status of a product, or "No purchase information available".
    func info(for productId: ProductId) -> String {
        var text = "No purchase information available"
        var purchaseInfo: Purchases.PurchaserInfo?
        
        Purchases.shared.purchaserInfo { purchaserInfo, error in
            purchaseInfo = purchaserInfo
        }
        
        guard let pi = purchaseInfo else { return text }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM y"
        
        if isSubscription(productId: productId), let e = pi.entitlements[StoreEntitlements.id(from: productId)] {
            if e.isActive {
                text = "Subscription."
                if let expires = e.expirationDate { text += " \(e.willRenew ? "Renews" : "Expires") \(dateFormatter.string(from: expires)).\n" }
                text += "Most recent purchase \(dateFormatter.string(from: e.latestPurchaseDate))."
                
            } else { text = "Subscription has expired" }
            
        } else {
            pi.nonSubscriptionTransactions.forEach { transaction in
                if transaction.productId == productId {
                    text = "Purchased \(dateFormatter.string(from: transaction.purchaseDate))"
                }
            }
        }
        
        return text
    }
    
    /// Determines if a product is a subscrition or not.
    /// - Parameter productId: The `ProductId`.
    /// - Returns: Returns true if the product is an auto-renewing subscription, false otherwise.
    func isSubscription(productId: ProductId) -> Bool {
        guard hasSubscriptionProductIds else { return false }
        return subscriptionProductIds!.contains(productId)
    }
    
    /// Determines if a product is a non-consumable or not.
    /// - Parameter productId: The `ProductId`.
    /// - Returns: Returns true if the product is a non-consumable, false otherwise.
    func isNonConsumable(productId: ProductId) -> Bool {
        guard hasNonConsumableProductIds else { return false }
        return nonConsumableProductIds!.contains(productId)
    }
}

extension ViewModel: PurchasesDelegate {
    /// Delegate method that is called in response to updated purchaser info or promotional product purchases.
    /// - Parameters:
    ///   - purchases: The ReveneueCat `Purchases` object.
    ///   - purchaserInfo: Purchase information for all products.
    func purchases(_ purchases: Purchases, didReceiveUpdated purchaserInfo: Purchases.PurchaserInfo) {
        // In the demo we're not making use of this notification
    }
}
