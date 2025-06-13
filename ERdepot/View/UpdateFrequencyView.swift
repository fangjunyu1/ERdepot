//
//  UpdatefrequencyView.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/6/11.
//

import SwiftUI

enum UpdateFrequency: String, CaseIterable, Identifiable {
    case everyDay = "Every day"
    case everyHour = "Every hour"
    case everyMinute = "Every minute"
    case every30Seconds = "Every 30 seconds"
    case every10Seconds = "Every 10 seconds"
    case everyAppLaunch = "Every time you open the app"
    
    var id: String { self.rawValue }
}

struct UpdateFrequencyView: View {
    @Environment(\.colorScheme) var color
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appStorage: AppStorageManager
    @EnvironmentObject var autoUpdater:AutoUpdater
    var body: some View {
        
        NavigationView {
            GeometryReader { geo in
                let width = geo.frame(in: .local).width * 0.95
                let height = geo.frame(in: .local).height
                    
                VStack {
                    
                    Spacer()
                        .frame(height: 10)
                    
                    // 标题
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Update frequency")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        Spacer()
                    }
                    
                    Spacer()
                        .frame(height: 30)
                    
                    VStack {
                        ForEach(UpdateFrequency.allCases) { item in
                            Button(action: {
                                // 修改更新频率
                                appStorage.updateFrequency = item
                                // 重新判断定时器
                                print("重新判断定时器")
                                autoUpdater.startTimer()
                            },label: {
                                HStack {
                                    Text(LocalizedStringKey(item.rawValue)).foregroundColor(color == .light ? .black : .white)
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .foregroundColor(color == .light ? Color(hex: "0742D2") : .white)
                                        .opacity(item == appStorage.updateFrequency ? 1: 0)
                                }
                                .frame(height:24)
                            })
                            if item != UpdateFrequency.everyAppLaunch {
                                
                                Divider()
                            }
                        }
                    }
                    .padding(.vertical,10)
                    .padding(.horizontal,10)
                    .background(color == .light ? .white : Color(hex: "2f2f2f"))
                    .cornerRadius(10)
                    
                    Spacer().frame(height:30)
                    
                    Text("Since this application uses a free and open interface, a low update frequency may be judged as abnormal behavior, resulting in limited interface access. It is recommended to set the update frequency to once a minute or higher to maintain a stable connection.")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    Spacer().frame(height:14)
                    
                    Text("Please note: The data of cryptocurrencies, daily gold prices and stock indices support setting the update frequency; while the foreign exchange rate data comes from the European Central Bank, which is non-real-time information and the update frequency cannot be adjusted.")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                .frame(width: width * 0.85)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(color == .light ? Color(hex: "F3F3F3") : .black)
            .onAppear {
                print("当前更新频率为:\(appStorage.updateFrequency)")
            }
        }
//        .navigationBarBackButtonHidden(true) // 隐藏返回按钮
    }
}

#Preview {
    UpdateFrequencyView()
        .environmentObject(IAPManager.shared)
        .environmentObject(AppStorageManager.shared)
    //        .environment(\.locale, .init(identifier: "de")) // 设置为阿拉伯语
}
