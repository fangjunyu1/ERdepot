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
    
    @Published var listOfSupportedCurrencies:[String] = ["USD","JPY","BGN","CYP","CZK","DKK","EEK","GBP","HUF","LTL","LVL","MTL","PLN","ROL","RON","SEK","SIT","SKK","CHF","ISK","NOK","HRK","RUB","TRL","TRY","AUD","BRL","CAD","CNY","HKD","IDR","ILS","INR","KRW","MXN","MYR","NZD","PHP","SGD","THB","ZAR"] {
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
    
    // 从UserDefaults加载数据
    private func loadUserDefault() {
        isInit = UserDefaults.standard.bool(forKey: "isInit")  // 初始化流程
        RequestRating = UserDefaults.standard.bool(forKey: "RequestRating") // 请求评分
        isInAppPurchase = UserDefaults.standard.bool(forKey: "isInAppPurchase") // 内购标识
        if let tmpListOfSupportedCurrencies = UserDefaults.standard.array(forKey: "listOfSupportedCurrencies") as? [String] {
            listOfSupportedCurrencies = tmpListOfSupportedCurrencies
        } else {
            print("未从UserDefaults获取listOfSupportedCurrencies货币数组")
            listOfSupportedCurrencies = ["USD","JPY","BGN","CYP","CZK","DKK","EEK","GBP","HUF","LTL","LVL","MTL","PLN","ROL","RON","SEK","SIT","SKK","CHF","ISK","NOK","HRK","RUB","TRL","TRY","AUD","BRL","CAD","CNY","HKD","IDR","ILS","INR","KRW","MXN","MYR","NZD","PHP","SGD","THB","ZAR"]
        }
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
        
        if let tmpListOfSupportedCurrencies = store.object(forKey: "listOfSupportedCurrencies") as? [String] {
            listOfSupportedCurrencies = tmpListOfSupportedCurrencies
        } else {
            print("未从 iCloud 获取listOfSupportedCurrencies货币数组")
            store.set(listOfSupportedCurrencies, forKey: "listOfSupportedCurrencies")
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
