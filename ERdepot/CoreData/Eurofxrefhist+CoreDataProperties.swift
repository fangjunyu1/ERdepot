//
//  Eurofxrefhist+CoreDataProperties.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/3/27.
//
//

import Foundation
import CoreData


extension Eurofxrefhist {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Eurofxrefhist> {
        return NSFetchRequest<Eurofxrefhist>(entityName: "Eurofxrefhist")
    }

    @NSManaged public var currencySymbol: String?
    @NSManaged public var exchangeRate: Double
    @NSManaged public var date: Date?

}

extension Eurofxrefhist : Identifiable {

}
