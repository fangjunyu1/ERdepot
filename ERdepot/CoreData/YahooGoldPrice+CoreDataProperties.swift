//
//  YahooGoldPrice+CoreDataProperties.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/5/24.
//
//

import Foundation
import CoreData


extension YahooGoldPrice {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<YahooGoldPrice> {
        return NSFetchRequest<YahooGoldPrice>(entityName: "YahooGoldPrice")
    }

    @NSManaged public var chartPreviousClose: Double
    @NSManaged public var fiftyTwoWeekHigh: Double
    @NSManaged public var fiftyTwoWeekLow: Double
    @NSManaged public var fullExchangeName: String?
    @NSManaged public var regularMarketDayHigh: Double
    @NSManaged public var regularMarketDayLow: Double
    @NSManaged public var regularMarketPrice: Double
    @NSManaged public var updateTime: Date?

}

extension YahooGoldPrice : Identifiable {

}
