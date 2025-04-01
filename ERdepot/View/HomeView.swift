//
//  HomeView.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/3/31.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appStorage: AppStorageManager
    var body: some View {
        Button(action: {
            appStorage.isInit = false
        }, label: {
            Text("Back")
        })
    }
}

#Preview {
    HomeView()
        .environmentObject(AppStorageManager.shared)
}
