//
//  CoreDataPersistenceController.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/4/12.
//

import CoreData
class CoreDataPersistenceController {
    static let shared = CoreDataPersistenceController()  // 全局单例
    let container: NSPersistentContainer
    private init() {
        container = NSPersistentContainer(name: "ExchangeRateDataModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
    }
    // 加载 xcdatamodeld 文件，确保名字匹配
    var context: NSManagedObjectContext {
        return Self.shared.container.viewContext
    }
    var backgroundContext: NSManagedObjectContext {
        return Self.shared.container.newBackgroundContext()
    }
}
