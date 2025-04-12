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
    
    @StateObject var appStorage = AppStorageManager.shared  // 共享实例
    @StateObject var iapManager = IAPManager.shared
    @StateObject var exchangeRate = ExchangeRate.shared
    // 创建 NSPersistentContainer
    let container: NSPersistentContainer
    init() {
        // 加载 xcdatamodeld 文件，确保名字匹配
        container = NSPersistentContainer(name: "ExchangeRateDataModel")
        
        // 加载持久化存储
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // 更新 Core Data 中的汇率数据
        exchangeRate.downloadExchangeRates()
        
        // 更新最新的汇率数据日期
        appStorage.latestSyncDate = exchangeRate.fetchLatestDate()
        var components = DateComponents()
        components.year = 2025
        components.month = 4
        components.day = 4
        let calendar = Calendar.current
        
        if let newDate = calendar.date(from: components) {
            print("最新的汇率数据日期为:\(appStorage.latestSyncDate ?? newDate)")
        } else {
            print("DateComponents日期创建失败") // 输出2025年1月1日
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(iapManager)
                .environment(\.managedObjectContext, container.viewContext) // 加载 NSPersistentContainer
                .environment(\.backgroundContext, container.newBackgroundContext())
                .environmentObject(appStorage)
                .environmentObject(exchangeRate)
                .task {
                    await iapManager.loadProduct()   // 加载产品信息
                    await iapManager.checkAllTransactions()  // 先检查历史交易
                    await iapManager.handleTransactions()   // 加载内购交易更新
                }
        }
    }
}
