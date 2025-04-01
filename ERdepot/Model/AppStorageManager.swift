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
                syncToiCloud()
            }
        }
    }

    // 从UserDefaults加载数据
    private func loadUserDefault() {
        isInit = UserDefaults.standard.bool(forKey: "isInit")  // 初始化流程
    }
    
    /// 从 iCloud 读取数据
    private func loadFromiCloud() {
        let store = NSUbiquitousKeyValueStore.default
        print("从iCloud读取数据")

        // 读取布尔值
        if store.object(forKey: "isInit") != nil {
            isInit = store.bool(forKey: "isInit")
        } else {
            store.set(isInit, forKey: "isInit")
        }

        print("完成 loadFromiCloud 方法的读取")
        print("isInit: \(isInit)")
        store.synchronize() // 强制触发数据同步
    }
    
    /// 数据变化时，**同步到 iCloud**
    private func syncToiCloud() {
        let store = NSUbiquitousKeyValueStore.default
        store.set(isInit, forKey: "isInit")
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
