//
//  HomeView.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/3/31.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) var color
    @EnvironmentObject var appStorage: AppStorageManager
    @State private var selectedTime: Int = 0
    let timeRange: [String] = ["1 Day","1 Week","1 Month","3 Months","6 Months", "1 Year","5 Years","10 Years","All"]
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                let width = geo.frame(in: .global).width * 0.95
                VStack(spacing: 0) {
                    Spacer().frame(height: 30)
                    // 仓库金额模块
                    VStack {
                        // 仓库金额
                        HStack {
                            Text("Warehouse amount")
                                .font(.footnote)
                                .foregroundColor(Color(hex: "FFFFFF"))
                            Spacer()
                        }
                        Spacer().frame(height: 10)
                        // 仓库金额 $999
                        HStack {
                            Text("¥ 888,888.00")
                                .font(.title)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        Spacer().frame(height: 10)
                        // 仓库金额各币种进度
                        Group {
                            Text("JPY")
                                .font(.footnote)
                                .foregroundColor(Color(hex: "FFFFFF"))
                            HStack {
                                Rectangle().frame(width: width * 0.8,height: 10)
                                    .foregroundColor(.purple)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(20)
                    .background(color == .light ? .black : Color(hex: "1f1f1f"))
                    .cornerRadius(10)
                    .frame(width: width * 0.95)
                    .zIndex(1)
                    
                    // 图表
                    VStack {
                        Spacer()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(timeRange.indices, id: \.self) { time in
                                    Button(action: {
                                        selectedTime = time
                                    }, label: {
                                        Text("\(timeRange[time])")
                                            .font(.footnote)
                                            .fontWeight(.medium)
                                            .padding(.vertical,8)
                                            .padding(.horizontal,12)
                                            .foregroundColor(time == selectedTime ? .white : color == .light ? .black : Color(hex: "eeeeee"))
                                            .background(time == selectedTime ? Color(hex: "5D5D5D") : color == .light ? Color(hex: "FFFFFF") : Color(hex: "999999"))
                                            .cornerRadius(10)
                                    })
                                }
                            }
                        }
                    }
                    .padding(10)
                    .frame(width: width * 0.9, height: 250)
                    .background(color == .light ? Color(hex: "F6F6F6") : Color(hex: "444444"))
                    .cornerRadius(10)
                    .offset(y: -10)
                    .zIndex(0)
                    
                    Spacer().frame(height: 15)
                    Rectangle().frame(width: 0.9 * width, height: 0.5)
                        .foregroundColor(.gray)
                    Spacer().frame(height: 15)
                    // 外币，更新时间，折算，统计
                    HStack {
                        // 外币
                        VStack {
                            
                        }
                        .padding(10)
                        .frame(width: 160,height: 160)
                    }
                    
                    Spacer()
                }
                .frame(width: width)
                .frame(maxWidth: .infinity,maxHeight: .infinity)
                .navigationTitle("ERdepot")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            #if DEBUG
                            appStorage.isInit = false
                            #endif
                        }, label: {
                            Image(color == .light ? "icon3" : "icon2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24) // 控制图片尺寸
                        })
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            
                        }, label: {
                            Image(systemName:"gearshape.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(color == .light ? .black : .white)
                        })
                    }
                }
            }
        }
        .navigationViewStyle(.stack) 
    }
}

#Preview {
    HomeView()
        .environmentObject(AppStorageManager.shared)
}
