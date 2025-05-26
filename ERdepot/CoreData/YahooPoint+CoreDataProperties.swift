//
//  YahooPoint+CoreDataProperties.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/5/25.
//
//

import Foundation
import CoreData


extension YahooPoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<YahooPoint> {
        return NSFetchRequest<YahooPoint>(entityName: "YahooPoint")
    }

    @NSManaged public var close: Double
    @NSManaged public var high: Double
    @NSManaged public var low: Double
    @NSManaged public var open: Double
    @NSManaged public var symbol: String?
    @NSManaged public var time: Date?
    @NSManaged public var volume: Double

}

extension YahooPoint : Identifiable {

}
