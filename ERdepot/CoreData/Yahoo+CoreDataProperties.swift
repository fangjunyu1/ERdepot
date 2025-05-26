//
//  Yahoo+CoreDataProperties.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/5/25.
//
//

import Foundation
import CoreData


extension Yahoo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Yahoo> {
        return NSFetchRequest<Yahoo>(entityName: "Yahoo")
    }

    @NSManaged public var chartPreviousClose: Double
    @NSManaged public var fiftyTwoWeekHigh: Double
    @NSManaged public var fiftyTwoWeekLow: Double
    @NSManaged public var fullExchangeName: String?
    @NSManaged public var regularMarketDayHigh: Double
    @NSManaged public var regularMarketDayLow: Double
    @NSManaged public var regularMarketPrice: Double
    @NSManaged public var symbol: String?
    @NSManaged public var updateTime: Date?

}

extension Yahoo : Identifiable {

}
