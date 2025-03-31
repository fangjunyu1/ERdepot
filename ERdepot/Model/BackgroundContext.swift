//
//  BackgroundContext.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/3/31.
//

import CoreData
import SwiftUI

// 创建自定义 EnvironmentKey
struct BackgroundContextKey: EnvironmentKey {
    static let defaultValue: NSManagedObjectContext? = nil
}

// 添加环境变量扩展
extension EnvironmentValues {
    var backgroundContext: NSManagedObjectContext? {
        get { self[BackgroundContextKey.self] }
        set { self[BackgroundContextKey.self] = newValue }
    }
}
