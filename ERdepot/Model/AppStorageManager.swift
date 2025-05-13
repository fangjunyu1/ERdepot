//
//  AppStorageManager.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/3/31.
//

import SwiftUI
import Observation

class AppStorageManager:ObservableObject {
    static let shared = AppStorageManager()  // 全局单例
    private init() {
        // 初始化时同步本地存储
        loadUserDefault()
        
        // 从iCloud读取数据
        loadFromiCloud()
        
        // 监听 iCloud 变化，同步到本地
        observeiCloudChanges()
        
        // 监听应用进入后台事件
        observeAppLifecycle()
    }
    
    // 完成初始化流程，true表示完成，false表示未完成，完成后打开应用会直接进入主视图。
    @Published var isInit: Bool = false  {
        didSet {
            if isInit != oldValue {
                UserDefaults.standard.set(isInit, forKey: "isInit")
                //                syncToiCloud()
            }
        }
    }
    
    @Published var localCurrency: String = "CNY"  {
        didSet {
            if localCurrency != oldValue {
                UserDefaults.standard.set(localCurrency, forKey: "localCurrency")
                syncToiCloud()
            }
        }
    }
    
    // 主视图的仓库金额界面，false 为默认界面，true 为简洁界面
    @Published var mainInterfaceWarehouseAmountStyle = false  {
        didSet {
            if mainInterfaceWarehouseAmountStyle != oldValue {
                UserDefaults.standard.set(mainInterfaceWarehouseAmountStyle, forKey: "mainInterfaceWarehouseAmountStyle")
                syncToiCloud()
            }
        }
    }
    
    @Published var listOfSupportedCurrencies:[String] = ["USD","JPY","BGN","CYP","CZK","DKK","EEK","EUR","GBP","HUF","LTL","LVL","MTL","PLN","ROL","RON","SEK","SIT","SKK","CHF","ISK","NOK","HRK","RUB","TRL","TRY","AUD","BRL","CAD","CNY","HKD","IDR","ILS","INR","KRW","MXN","MYR","NZD","PHP","SGD","THB","ZAR"] {
        didSet {
            if listOfSupportedCurrencies != oldValue {
                UserDefaults.standard.set(listOfSupportedCurrencies, forKey: "isInit")
                syncToiCloud()
            }
        }
    }
    
    // 请求评分
    @Published  var RequestRating = false  {
        didSet {
            if RequestRating != oldValue {
                UserDefaults.standard.set(RequestRating, forKey: "RequestRating")
                syncToiCloud()
            }
        }
    }
    
    /// 内购完成后，设置为true，@AppStorage("20240523")
    @Published  var isInAppPurchase = false {
        didSet {
            if isInAppPurchase != oldValue {
                UserDefaults.standard.set(isInAppPurchase, forKey: "isInAppPurchase")
                syncToiCloud()
            }
        }
    }
    
    // 重新统计历史高点
    @Published var reCountingHistoricalHighs = false {
        didSet {
            if reCountingHistoricalHighs != oldValue {
                UserDefaults.standard.set(reCountingHistoricalHighs, forKey: "reCountingHistoricalHighs")
                // syncToiCloud()
            }
        }
    }
    
    // 历史时间
    @Published var historicalTime: Double = Date().timeIntervalSince1970 {
        didSet {
            if historicalTime != oldValue {
                UserDefaults.standard.set(historicalTime, forKey: "historicalTime")
                // syncToiCloud()
            }
        }
    }
    
    // 历史高点
    @Published var historicalHigh: Double = 0.00 {
        didSet {
            if historicalHigh != oldValue {
                UserDefaults.standard.set(historicalHigh, forKey: "historicalHigh")
                // syncToiCloud()
            }
        }
    }
    
    // 折算外币
    @Published var convertForeignCurrency: [String] = ["USD", "EUR", "JPY", "GBP", "HKD", "CNY"] {
        didSet {
            if convertForeignCurrency != oldValue {
                UserDefaults.standard.set(convertForeignCurrency, forKey: "convertForeignCurrency")
                // syncToiCloud()
            }
        }
    }
    
    // 更新日期
    @Published var exchangeRateUpdateDate: Double = 0 {
        didSet {
            if exchangeRateUpdateDate != oldValue {
                UserDefaults.standard.set(exchangeRateUpdateDate, forKey: "exchangeRateUpdateDate")
                // syncToiCloud()
            }
        }
    }
    
    // 更新日期
    @Published var CryptocurrencylastUpdateDate: Date = Date.distantPast {
        didSet {
            if CryptocurrencylastUpdateDate != oldValue {
                UserDefaults.standard.set(CryptocurrencylastUpdateDate, forKey: "CryptocurrencylastUpdateDate")
                // syncToiCloud()
                print("修改加密货币的更新日期为:\(CryptocurrencylastUpdateDate)")
            }
        }
    }
    
    // 从UserDefaults加载数据
    private func loadUserDefault() {
        
        mainInterfaceWarehouseAmountStyle = UserDefaults.standard.bool(forKey: "mainInterfaceWarehouseAmountStyle")  // 初始化流程
        
        isInit = UserDefaults.standard.bool(forKey: "isInit")  // 初始化流程
        RequestRating = UserDefaults.standard.bool(forKey: "RequestRating") // 请求评分
        isInAppPurchase = UserDefaults.standard.bool(forKey: "isInAppPurchase") // 内购标识
        convertForeignCurrency = UserDefaults.standard.stringArray(forKey: "convertForeignCurrency") ?? ["USD", "EUR", "JPY", "GBP", "HKD", "CNY"] // 折算外币
        
        // 如果没有历史时间，默认设置为1999年1月4日
        if UserDefaults.standard.double(forKey: "historicalTime") == 0.00 {
            historicalTime = 915379200.00
        } else {
            historicalTime = UserDefaults.standard.double(forKey: "historicalTime") // 历史时间
        }
        historicalHigh = UserDefaults.standard.double(forKey: "historicalHigh") // 历史高点
        
        // 如果没有更新日期，默认设置为1999年1月4日
        if UserDefaults.standard.double(forKey: "exchangeRateUpdateDate") == 0.00 {
            exchangeRateUpdateDate = 915379200.00
        } else {
            exchangeRateUpdateDate = UserDefaults.standard.double(forKey: "exchangeRateUpdateDate") // 历史时间
        }
        
        // 如果UserDefaults中重新统计为nil
        if UserDefaults.standard.object(forKey: "reCountingHistoricalHighs") == nil {
            // 设置默认值为true
            reCountingHistoricalHighs = true
        } else {
            reCountingHistoricalHighs = UserDefaults.standard.bool(forKey: "reCountingHistoricalHighs") // 内购标识
        }
        
        localCurrency = UserDefaults.standard.string(forKey: "localCurrency") ??  "USD" // 当前币种
        if let tmpListOfSupportedCurrencies = UserDefaults.standard.array(forKey: "listOfSupportedCurrencies") as? [String] {
            listOfSupportedCurrencies = tmpListOfSupportedCurrencies
        } else {
            print("未从UserDefaults获取listOfSupportedCurrencies货币数组")
            listOfSupportedCurrencies = ["USD","JPY","BGN","CYP","CZK","DKK","EEK","EUR","GBP","HUF","LTL","LVL","MTL","PLN","ROL","RON","SEK","SIT","SKK","CHF","ISK","NOK","HRK","RUB","TRL","TRY","AUD","BRL","CAD","CNY","HKD","IDR","ILS","INR","KRW","MXN","MYR","NZD","PHP","SGD","THB","ZAR"]
        }
        
        // 加密货币更新日期
        CryptocurrencylastUpdateDate = UserDefaults.standard.object(forKey: "CryptocurrencylastUpdateDate") as? Date ?? Date.distantPast
        
    }
    
    /// 从 iCloud 读取数据
    private func loadFromiCloud() {
        let store = NSUbiquitousKeyValueStore.default
        print("从iCloud读取数据")
        
        // 读取布尔值
        // 暂时不将初始化同步到iCloud
        //        if store.object(forKey: "isInit") != nil {
        //            isInit = store.bool(forKey: "isInit")
        //        } else {
        //            store.set(isInit, forKey: "isInit")
        //        }
        
        if store.object(forKey: "RequestRating") != nil {
            RequestRating = store.bool(forKey: "RequestRating")
        } else {
            store.set(RequestRating, forKey: "RequestRating")
        }
        
        if store.object(forKey: "isInAppPurchase") != nil {
            isInAppPurchase = store.bool(forKey: "isInAppPurchase")
        } else {
            store.set(isInit, forKey: "isInAppPurchase")
        }
        
        // 读取数组值
        if let tmpListOfSupportedCurrencies = store.object(forKey: "listOfSupportedCurrencies") as? [String] {
            listOfSupportedCurrencies = tmpListOfSupportedCurrencies
        } else {
            print("未从 iCloud 获取listOfSupportedCurrencies货币数组")
            store.set(listOfSupportedCurrencies, forKey: "listOfSupportedCurrencies")
        }
        
        // 读取字符串值
        // 更新当前币种
        if let storedLocalCurrency = store.string(forKey: "localCurrency") {
            localCurrency = storedLocalCurrency
        } else {
            store.set(localCurrency, forKey: "localCurrency")
        }
        
        print("完成 loadFromiCloud 方法的读取")
        store.synchronize() // 强制触发数据同步
    }
    
    /// 数据变化时，**同步到 iCloud**
    private func syncToiCloud() {
        let store = NSUbiquitousKeyValueStore.default
        //        store.set(isInit, forKey: "isInit")
        store.set(listOfSupportedCurrencies, forKey: "listOfSupportedCurrencies")
        store.set(RequestRating, forKey: "RequestRating")
        store.set(isInAppPurchase, forKey: "isInAppPurchase")
        store.set(localCurrency, forKey: "localCurrency")
        store.set(localCurrency, forKey: "localCurrency")
        store.synchronize() // 强制触发数据同步
    }
    
    /// 监听 iCloud 变化，同步到本地
    private func observeiCloudChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iCloudDidUpdate),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSUbiquitousKeyValueStore.default
        )
    }
    
    /// iCloud 数据变化时，更新本地数据
    @objc private func iCloudDidUpdate(notification: Notification) {
        print("iCloud数据发生变化，更新本地数据")
        DispatchQueue.main.async {
            self.loadFromiCloud()
        }
    }
    
    /// 监听应用生命周期事件
    private func observeAppLifecycle() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    /// 当应用进入后台时，将数据同步到 iCloud
    @objc private func appWillResignActive() {
        print("应用进入后台，将本地数据同步到iCloud")
        syncToiCloud()
    }
    
    /// 防止内存泄漏
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
}
