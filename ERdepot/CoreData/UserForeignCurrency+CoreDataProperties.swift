//
//  UserForeignCurrency+CoreDataProperties.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/4/14.
//
//

import Foundation
import CoreData


extension UserForeignCurrency {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserForeignCurrency> {
        return NSFetchRequest<UserForeignCurrency>(entityName: "UserForeignCurrency")
    }

    @NSManaged public var amount: Double
    @NSManaged public var purchaseAmount: Double
    @NSManaged public var purchaseDate: Date?
    @NSManaged public var reamark: String?
    @NSManaged public var symbol: String?

}

extension UserForeignCurrency : Identifiable {

}
