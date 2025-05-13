//
//  CryptoCurrency+CoreDataProperties.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/5/12.
//
//

import Foundation
import CoreData


extension CryptoCurrency {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CryptoCurrency> {
        return NSFetchRequest<CryptoCurrency>(entityName: "CryptoCurrency")
    }

    @NSManaged public var id: String?
    @NSManaged public var symbol: String?
    @NSManaged public var name: String?
    @NSManaged public var image: URL?
    @NSManaged public var currentPrice: Double
    @NSManaged public var marketCap: Int64
    @NSManaged public var marketCapRank: Int64
    @NSManaged public var fullyDilutedValuation: Int64
    @NSManaged public var totalVolume: Double
    @NSManaged public var high24h: Double
    @NSManaged public var low24h: Double
    @NSManaged public var priceChange24h: Double
    @NSManaged public var priceChangePercentage24h: Double
    @NSManaged public var marketCapChange24h: Double
    @NSManaged public var marketCapChangePercentage24h: Double
    @NSManaged public var circulatingSupply: Double
    @NSManaged public var totalSupply: Double
    @NSManaged public var maxSupply: Double
    @NSManaged public var ath: Double
    @NSManaged public var athChangePercentage: Double
    @NSManaged public var athDate: Date?
    @NSManaged public var atl: Double
    @NSManaged public var atlChangePercentage: Double
    @NSManaged public var atlDate: Date?
    @NSManaged public var roiTime: Double
    @NSManaged public var roiCurrency: String?
    @NSManaged public var roiPercentage: Double
    @NSManaged public var lastUpdated: Date?

}

extension CryptoCurrency : Identifiable {

}
