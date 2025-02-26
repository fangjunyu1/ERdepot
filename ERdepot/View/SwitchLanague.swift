//
//  SwitchLanague.swift
//  ERdepot
//
//  Created by 方君宇 on 2024/10/27.
//

import SwiftUI

struct SwitchLanague: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    @AppStorage("currentLanguage") private var currentLanguage: String = "en"
    @Environment(\.colorScheme) var mode
    @AppStorage("languageTips") private var languageTips = false
    
    
    var body: some View {
        NavigationStack {
            List(languageManager.availableLanguages, id: \.1) { lang in
                Button(action: {
                    print("languageTips切换为true")
                    languageTips = true
                    currentLanguage = lang.1
                    languageManager.currentLanguage = lang.1
                }, label: {
                    HStack {
                        Text(lang.0)
                        Spacer()
                        // 如果当前语言与按钮对应的语言相同，显示 `checkmark`
                        if languageManager.currentLanguage == lang.1 {
                            Image(systemName: "checkmark")
                        }
                    }
                    .foregroundColor(mode == .dark ? Color.white : Color.black)
                })
            }
        }
        .navigationTitle("Switch language")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SwitchLanague()
}
