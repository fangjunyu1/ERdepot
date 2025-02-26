//
//  ContentView.swift
//  ERdepot
//
//  Created by 方君宇 on 2024/10/15.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    @State private var selectedTab = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            // 首页视图
            HomeView()
                .tabItem {
                    Image(systemName: "chart.bar") // 对应图标
                    Text("Home") // 首页标题
                }
                .tag(0)
            
            // 仓库视图
            WarehouseView()
                .tabItem {
                    Image(systemName: "archivebox") // 对应图标
                    Text("Warehouse")  // 仓库标题
                }
                .tag(1)
        }
    }
}

#Preview {
    ContentView()
}
