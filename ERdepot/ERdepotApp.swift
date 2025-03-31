//
//  ERdepotApp.swift
//  ERdepot
//
//  Created by 方君宇 on 2024/10/15.
//

import SwiftUI
import CoreData
@main
struct ERdepotApp: App {
    
    // 创建 NSPersistentContainer
    let container: NSPersistentContainer
    init() {
        // 加载 xcdatamodeld 文件，确保名字匹配
        container = NSPersistentContainer(name: "ExchangeRateDataModel")
        
        // 加载持久化存储
        container.loadPersistentStores { (storeDescription, error) in
            print("storeDescription:\(storeDescription)")
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, container.viewContext)
                .environment(\.backgroundContext, container.newBackgroundContext()) 
        }
    }
}
