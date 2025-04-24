//
//  extensionBundle.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/4/24.
//

import Foundation
extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    var appBuild: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}
