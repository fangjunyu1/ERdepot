//
//  YahooGoldPricePoint+CoreDataProperties.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/5/24.
//
//

import Foundation
import CoreData


extension YahooGoldPricePoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<YahooGoldPricePoint> {
        return NSFetchRequest<YahooGoldPricePoint>(entityName: "YahooGoldPricePoint")
    }

    @NSManaged public var time: Date?
    @NSManaged public var open: Double
    @NSManaged public var low: Double
    @NSManaged public var close: Double
    @NSManaged public var high: Double
    @NSManaged public var volume: Double

}

extension YahooGoldPricePoint : Identifiable {

}
