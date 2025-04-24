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
    let calendar = Calendar.current
    // 创建 NSPersistentContainer
    init() {
        if calendar.isDate(Date(), inSameDayAs: Date(timeIntervalSince1970: appStorage.exchangeRateUpdateDate)) {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(identifier: "Asia/Shanghai") // 设置为中国时间
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

            print("今天\(formatter.string(from: Date(timeIntervalSince1970: appStorage.exchangeRateUpdateDate))) 已经更新过汇率，不在更新。")
        } else {
            print("今天首次打开应用，更新汇率数据")
            exchangeRate.downloadExchangeRates()
            print("将今天的日期更新到同步日期，今天不再更新汇率，除非手动更新。")
            appStorage.exchangeRateUpdateDate = Date().timeIntervalSince1970
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
