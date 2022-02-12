//
//  StoreConfiguration.swift
//  RCFlowers4U
//
//  Created by Russell Archer on 04/02/2022.
//

import Foundation
import OrderedCollections

public typealias ProductId = String

/// Provides static methods for reading plist configuration files.
public struct StoreConfiguration {
    
    private init() {}
    
    /// Read the contents of the product definition property list. The appropriate list for
    /// test and production environments is returned.
    /// - Returns: Returns a set of ProductId if the list was read, nil otherwise.
    public static func readConfigFile() -> OrderedSet<ProductId>? {
        guard let result = read(filename: StoreConstants.productsList), result.count > 0,
              let values = result[StoreConstants.productsList] as? [String] else { return nil }
        
        return OrderedSet<ProductId>(values.compactMap { $0 })
    }
    
    /// Read a plist property file and return a dictionary of values
    private static func read(filename: String) -> [String : AnyObject]? {
        guard let path = Bundle.main.path(forResource: filename, ofType: "plist"),
              let contents = NSDictionary(contentsOfFile: path) as? [String : AnyObject]
        else { return nil }
        
        return contents
    }
}
