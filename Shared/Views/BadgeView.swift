//
//  BadgeView.swift
//  RCFlowers4U
//
//  Created by Russell Archer on 05/02/2022.
//

import SwiftUI

/// Displays a small image that gives a visual clue to the product's purchase state.
public struct BadgeView: View {
    @Binding var purchaseState: PurchaseState
    
    public var body: some View {
        if let options = badgeOptions() {
            Image(systemName: options.badgeName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .foregroundColor(options.fgColor)
        }
    }
    
    public func badgeOptions() -> (badgeName: String, fgColor: Color)? {
        switch purchaseState {
            case .notStarted:               return nil
            case .userCannotMakePayments:   return (badgeName: "nosign", Color.red)
            case .inProgress:               return (badgeName: "hourglass", Color.cyan)
            case .purchased:                return (badgeName: "checkmark", Color.green)
            case .pending:                  return (badgeName: "hourglass", Color.orange)
            case .cancelled:                return (badgeName: "person.crop.circle.fill.badge.xmark", Color.blue)
            case .failed:                   return (badgeName: "hand.raised.slash", Color.red)
            case .failedVerification:       return (badgeName: "hand.thumbsdown.fill", Color.red)
            case .unknown:                  return nil
        }
    }
}
