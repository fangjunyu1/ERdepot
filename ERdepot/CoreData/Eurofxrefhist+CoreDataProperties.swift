//
//  Eurofxrefhist+CoreDataProperties.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/4/18.
//
//

import Foundation
import CoreData


extension Eurofxrefhist {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Eurofxrefhist> {
        return NSFetchRequest<Eurofxrefhist>(entityName: "Eurofxrefhist")
    }

    @NSManaged public var date: Date?
    @NSManaged public var rate: Double
    @NSManaged public var symbol: String?

}

extension Eurofxrefhist : Identifiable {

}
