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
    let CoreDatacontainer = CoreDataPersistenceController.shared
    // 创建 NSPersistentContainer
    init() {
        // 更新 Core Data 中的汇率数据
        #if DEBUG
        print("测试环境，不更新 Core Data 汇率数据")
        #else
        exchangeRate.downloadExchangeRates()
        #endif
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(iapManager)
                .environment(\.managedObjectContext, CoreDatacontainer.context) // 加载 NSPersistentContainer
                .environment(\.backgroundContext, CoreDatacontainer.backgroundContext)
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
