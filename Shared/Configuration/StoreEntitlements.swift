//
//  StoreEntitlements.swift
//  RCFlowers4U
//
//  Created by Russell Archer on 13/02/2022.
//

import Foundation

/// Provides mapping between a ProductId and a RevenueCat entitlements id
enum StoreEntitlements {
    case vipGold, vipSilver, vipBronze, nonconsumables
    
    func id() -> String {
        switch self {
            case .vipGold:          return "VIP_Gold_Features"
            case .vipSilver:        return "VIP_Silver_Features"
            case .vipBronze:        return "VIP_Bronze_Features"
            case .nonconsumables:   return "Unrestricted_Ownership"
        }
    }
    
    static func id(from productId: ProductId) -> String {
        switch productId {
            case "com.rarcher.rcflowers4u.subscription.vip.gold":            return "VIP_Gold_Features"
            case "com.rarcher.rcflowers4u.subscription.vip.silver":          return "VIP_Silver_Features"
            case "com.rarcher.rcflowers4u.subscription.vip.bronze":          return "VIP_Bronze_Features"
            case "com.rarcher.rcflowers4u.nonconsumable.flowers.large":      return "Unrestricted_Ownership"
            case "com.rarcher.rcflowers4u.nonconsumable.flowers.small":      return "Unrestricted_Ownership"
            case "com.rarcher.rcflowers4u.nonconsumable.roses.large":        return "Unrestricted_Ownership"
            case "com.rarcher.rcflowers4u.nonconsumable.chocolates.small":   return "Unrestricted_Ownership"
            default:                                                         return ""
        }
    }
    
    func productId() -> [String] {
        switch self {
            case .vipGold:          return ["com.rarcher.rcflowers4u.subscription.vip.gold"]
            case .vipSilver:        return ["com.rarcher.rcflowers4u.subscription.vip.silver"]
            case .vipBronze:        return ["com.rarcher.rcflowers4u.subscription.vip.bronze"]
            case .nonconsumables:   return ["com.rarcher.rcflowers4u.nonconsumable.flowers.large",
                                            "com.rarcher.rcflowers4u.nonconsumable.flowers.small",
                                            "com.rarcher.rcflowers4u.nonconsumable.roses.large",
                                            "com.rarcher.rcflowers4u.nonconsumable.chocolates.small"]
        }
    }
}
