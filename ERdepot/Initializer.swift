//
//  Initializer.swift
//  ERdepot
//
//  Created by 方君宇 on 2024/10/16.
//
import SwiftUI
import Foundation

struct Initializer {
    // 判断是否接受隐私政策
    var privacyPolicy: Bool {
        didSet {
            UserDefaults.standard.setValue(privacyPolicy, forKey: "privacyPolicy")
        }
    }
    
    // 初始化时判断UserDefaults的privacyPolicy是否为true，为true则
    init() {
        let isAccepted = UserDefaults.standard.bool(forKey: "privacyPolicy")
        @Sendable func requestNetworkPermission() async {
            // 发送一个轻量的网络请求
            guard let url = URL(string: "https://www.fangjunyu.com") else { return }
            do {
                let (_,_) = try await URLSession.shared.data(from: url)
            } catch {
                print("网络请求失败：\(error)")
            }
        }
        privacyPolicy = isAccepted
        Task {
            await requestNetworkPermission()  // 快速的网络请求
        }
    }
}
