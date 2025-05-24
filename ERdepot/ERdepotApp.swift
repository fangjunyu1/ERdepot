//
//  ERdepotApp.swift
//  ERdepot
//
//  Created by 方君宇 on 2024/10/15.
//

import SwiftUI
import CoreData
import StoreKit
@main
struct ERdepotApp: App {
    
    @StateObject var appStorage = AppStorageManager.shared  // 共享实例
    @StateObject var iapManager = IAPManager.shared
    @StateObject var exchangeRate = ExchangeRate.shared
    @StateObject var cryptoData = CryptoDataManager.shared
    @StateObject var yahooGoldPriceManager = YahooGoldPriceManager.shared
    let CoreDatacontainer = CoreDataPersistenceController.shared

    init() {
        // 首次打开应用，调用评分
        if !appStorage.RequestRating {
            appStorage.RequestRating = true
            SKStoreReviewController.requestReview()
        }
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
