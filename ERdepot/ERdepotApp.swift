//
//  ERdepotApp.swift
//  ERdepot
//
//  Created by 方君宇 on 2024/10/15.
//

import SwiftUI

@main
struct ERdepotApp: App {
    @State private var Initializers = Initializer()
    @ObservedObject var shared = IAPManager.shared
    
    var body: some Scene {
        WindowGroup {
            if !Initializers.privacyPolicy {
                privacyPolicyPage(privacyPolicy: $Initializers.privacyPolicy)
            } else {
                ContentView()
                    .onAppear {
                        print("进入Content,onAppear代码块")
                        Task {
                            await shared.loadProduct()
                            await shared.handleTransactions()
                        }
                    }
            }
        }
    }
}
