//
//  AutoUpdater.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/6/12.
//

import SwiftUI

class AutoUpdater: ObservableObject {
    static var shared = AutoUpdater()
    private var timer: Timer?
    private var appStorage = AppStorageManager.shared
    
    private init() {}
    
    func startTimer() {
        print("进入计时器 startTimer 方法")
        stopTimer()
        
        guard let interval = intervalForFrequency(appStorage.updateFrequency) else {
            // 每次打开应用更新
            print("设置为每次启动时更新，立即执行")
            self.performUpdate()
            return // 不启动定时器
        }
        
        print("当前设定的更新频率为: \(appStorage.updateFrequency.rawValue)，对应间隔: \(interval) 秒")
        
        // 启动定时器
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.fetchIfNeeded()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        print("计时器已停止")
    }
    
    func fetchIfNeeded() {
        // 获取最新的时间
        let now = Date()
        
        print("当前设定的更新间隔为:\(appStorage.updateFrequency.rawValue)")
        
        // 解包 intervalForFrequency 方法
        guard let interval = intervalForFrequency(appStorage.updateFrequency) else { print("设置为每次启动时更新，立即执行")
            self.performUpdate()
            return
        }
        // 如果当前时间距离加密货币上次更新时间大于设定的时间间隔（秒），执行更新方法
        // 或者，如果当前时间距离Yahoo黄金、汇率上次更新时间大于设定的时间间隔（秒），执行更新方法
        // 判断是否到达更新周期
        if now.timeIntervalSince(appStorage.CryptocurrencylastUpdateDate) >= interval ||
            now.timeIntervalSince(appStorage.YahooLastUpdateDate) >= interval {
            self.performUpdate()
        }
    }
    
    func performUpdate() {
        let now = Date()
        print("执行数据更新：\(now)")
        // 调取加密货币的接口
        print("调用加密货币的接口")
        CryptoDataManager.shared.fetchCryptoData()
        print("调用 Yahoo 接口")
        // 调用 Yahoo 的接口
        YahooManager.shared.fetchYahooData()
    }
    
    func intervalForFrequency(_ frequency: UpdateFrequency) -> TimeInterval? {
        switch frequency {
        case .every10Seconds: return 10
        case .every30Seconds: return 30
        case .everyMinute: return 60
        case .everyHour: return 3600
        case .everyDay: return 86400
        case .everyAppLaunch: return nil
        }
    }
}
