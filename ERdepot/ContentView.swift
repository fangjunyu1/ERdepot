//
//  ContentView.swift
//  ERdepot
//
//  Created by 方君宇 on 2024/10/15.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var ViewSteps = 0
    @EnvironmentObject var appStorage:AppStorageManager
    var body: some View {
        if appStorage.isInit {
            HomeView()
        } else {
            if ViewSteps == 0 {
                WelcomeView(ViewSteps: $ViewSteps)
            } else if ViewSteps == 1 {
                PrivacyPolicyView(ViewSteps: $ViewSteps)
            }
        }
    }
}

#Preview {
//    if let bundleID = Bundle.main.bundleIdentifier {
//        UserDefaults.standard.removePersistentDomain(forName: bundleID)
//    }
    return ContentView()
        // .environment(\.locale, .init(identifier: "de")) // 设置为阿拉伯语
        .environmentObject(AppStorageManager.shared)
        .environmentObject(ExchangeRate.shared)
        .environmentObject(IAPManager.shared)
        .environment(\.managedObjectContext, CoreDataPersistenceController.shared.context) // 加载 NSPersistentContainer
        .environment(\.backgroundContext, CoreDataPersistenceController.shared.backgroundContext) // 加载 NSPersistentContainer
}
#Preview {
    if let bundleID = Bundle.main.bundleIdentifier {
        UserDefaults.standard.removePersistentDomain(forName: bundleID)
    }
    return ContentView()
        // .environment(\.locale, .init(identifier: "de")) // 设置为阿拉伯语
        .environmentObject(AppStorageManager.shared)
        .environmentObject(ExchangeRate.shared)
        .environmentObject(IAPManager.shared)
        .environment(\.managedObjectContext, CoreDataPersistenceController.shared.context) // 加载 NSPersistentContainer
        .environment(\.backgroundContext, CoreDataPersistenceController.shared.backgroundContext) // 加载 NSPersistentContainer
        .preferredColorScheme(.dark)
}
