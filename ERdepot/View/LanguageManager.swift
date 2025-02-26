//
//  LanguageManager.swift
//  ERdepot
//
//  Created by 方君宇 on 2024/10/27.
//

import Foundation
import SwiftUI
import UIKit

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    private init() {
        // 从系统中获取首个语言选项，如果没有则返回 en
        let systemLanguage = UserDefaults.standard.array(forKey: "AppleLanguages")?.first as? String ?? "en"
        print("系统语言为:\(systemLanguage)")
        // 设置当前语言，将系统的语言选项（可能包含本地化区域语言代码）映射为基础语言代码：   zh-TW -> zh-hant
        self.currentLanguage = standardizeLanguageCode(systemLanguage)
    }
    
    // storedLanguage 默认为英语 en
    @AppStorage("currentLanguage") private var storedLanguage: String = "en"
    
    // 获取当前语言，标准化以便统一处理
    var currentLanguage: String {
        get {
            // 返回 storedLanguage 存储的语言内容
            return storedLanguage
        }
        set {
            // 将设置的语言映射为基础语言代码，保存在 storedLanguage 中。
            storedLanguage = standardizeLanguageCode(newValue)
            UserDefaults.standard.set([newValue], forKey: "AppleLanguages")
        }
    }
    
    // 语言映射表，基础语言代码和对应的本地化名称。
    @Published var languageMap: [String: String] = [
        "ar": "Arabic",
        "ca": "Catalan",
        "cs": "Czech",
        "da": "Danish",
        "de": "German",
        "el": "Greek",
        "en": "English",
        "es": "Spanish",
        "fi": "Finnish",
        "fr": "French",
        "he": "Hebrew",
        "hi": "Hindi",
        "hr": "Croatian",
        "hu": "Hungarian",
        "id": "Indonesian",
        "it": "Italian",
        "ja": "Japanese",
        "ko": "Korean",
        "ms": "Malay",
        "nl": "Dutch",
        "no": "Norwegian Bokmål",
        "pl": "Polish",
        "pt": "Portuguese",
        "ro": "Romanian",
        "ru": "Russian",
        "sk": "Slovak",
        "sv": "Swedish",
        "th": "Thai",
        "tr": "Turkish",
        "uk": "Ukrainian",
        "vi": "Vietnamese",
        "zh": "Chinese Simplified",
        "zh-Hant": "Chinese Traditional"
    ]
    
    // 生成去除区域代码的可用语言列表
    var availableLanguages: [(LocalizedStringKey, String)] {
        let uniqueLanguages = Dictionary(languageMap.map { ($0.value, standardizeLanguageCode($0.key)) }, uniquingKeysWith: { first, _ in first })
        return uniqueLanguages
            .map { (LocalizedStringKey($0.key), $0.value) }
            .sorted { String(describing: $0.0) < String(describing: $1.0) }
    }
    
    // 返回当前语言代码的本地化名称
    func getCurrentLanguageName() -> String {
        return languageMap[currentLanguage] ?? "Unknown"
    }
    
    // 标准化语言代码（将本地化区域代码映射为基础代码）
    private func standardizeLanguageCode(_ code: String) -> String {
        switch code {
        case "zh-HK", "zh-TW", "zh-Hant", "zh-Hant-HK", "zh-Hant-TW":
            return "zh-Hant"
        case "zh-CN", "zh-Hans", "zh-Hans-CN":
            return "zh"
        case "en-GB", "en-US", "en-AU", "en-CA", "en-IN", "en-CN":
            return "en"
        case "pt-BR", "pt-PT":
            return "pt"
        case "fr-CA", "fr-CH":
            return "fr"
        case "de-CH", "de-AT":
            return "de"
        case "es-MX", "es-ES":
            return "es"
        default:
            return code
        }
    }
}
