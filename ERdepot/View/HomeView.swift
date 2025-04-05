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
    @State private var isShowForeignCurrency = false
    @State private var isShowConversion = false
    @State private var isShowStatistics = false
    @State private var isShowChangeCurrency = false
    @State private var isShowSet = false
    let timeRange: [String] = ["1 Day","1 Week","1 Month","3 Months","6 Months", "1 Year","5 Years","10 Years","All"]
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                let width = geo.frame(in: .global).width * 0.95
                let height = geo.frame(in: .global).height
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 10)
                        // 仓库金额模块
                        VStack(spacing: 0) {
                            // 仓库金额
                            HStack {
                                Text("Warehouse amount")
                                    .font(.caption2)
                                    .foregroundColor(Color(hex: "FFFFFF"))
                                Spacer()
                            }
                            Spacer().frame(height: 10)
                            // 仓库金额 $999
                            HStack {
                                HStack{
                                    Text("¥  ") + Text("888,888.00")
                                }
                                .font(.title2)
                                .foregroundColor(.white)
                                Spacer()
                            }
                            Spacer().frame(height: 10)
                            // 仓库金额各币种进度
                            Group {
                                Text("JPY")
                                    .font(.footnote)
                                    .foregroundColor(Color(hex: "FFFFFF"))
                                Spacer().frame(height: 5)
                                HStack {
                                    Rectangle().frame(width: width * 0.8,height: 8)
                                        .foregroundColor(.purple)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(14)
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
                                                .font(.caption2)
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
                            // 管理外币按钮
                            Button(action: {
                                withAnimation {
                                    isShowForeignCurrency = true
                                    print("当前isShowForeignCurrency:\(isShowForeignCurrency)")
                                }
                            }, label: {
                                // 管理外币
                                VStack {
                                    // 外币图片
                                    HStack {
                                        Image("money")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40,height: 40)
                                        Spacer()
                                    }
                                    Spacer().frame(height: 14)
                                    // 管理
                                    HStack{
                                        Text("Manage")
                                            .font(.footnote)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    Spacer().frame(height: 14)
                                    // 外币
                                    HStack{
                                        Text("Foreign currency")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Spacer()
                                    }
                                    Spacer()
                                }
                                .padding(20)
                                .frame(width: 160,height: 140)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "0474FF"), color == .light ? .black : .gray]), // 渐变的颜色
                                        startPoint: .top, // 渐变的起始点
                                        endPoint: .bottom // 渐变的结束点
                                    )
                                )
                                .cornerRadius(10)
                                .overlay {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            // 书签
                                            Image(systemName: "bookmark.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50,height: 80)
                                                .foregroundColor(.white)
                                                .offset(y:-10)
                                                .clipped()
                                            Spacer()
                                                .frame(width: 14)
                                        }
                                        Spacer()
                                    }
                                }
                            })
                            Spacer().frame(width: 16)
                            // 更新时间，折算，统计
                            VStack {
                                // 更新时间
                                VStack {
                                    Text("Update time") + Text(" : ") + Text("2000-1-1")
                                }
                                .font(.footnote)
                                .frame(width: 160,height: 50)
                                .foregroundColor(.white)
                                .background(
                                    Color(hex: "1AAE0E")
                                        .opacity(color == .light ? 1 : 0.8)
                                )
                                .cornerRadius(10)
                                // 折算，统计
                                VStack(spacing: 0) {
                                    Button(action: {
                                        isShowConversion = true
                                    }, label: {
                                        HStack {
                                            Image(systemName: "repeat.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(Color(hex:"E8731E"))
                                                .background(.white)
                                                .frame(width: 20,height: 20)
                                                .cornerRadius(10)
                                            Spacer().frame(width: 20)
                                            Text("Conversion")
                                                .font(.footnote)
                                                .foregroundColor(color == .light ? .black : .white)
                                            Spacer()
                                            Text("1:7")
                                                .font(.footnote)
                                                .fontWeight(.medium)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.vertical,6)
                                        .padding(.horizontal,16)
                                        .frame(maxWidth: .infinity,maxHeight: .infinity)
                                    })
                                    Rectangle().frame(width: 140,height: 0.5)
                                        .padding(.leading,20)
                                        .foregroundColor(.gray)
                                    
                                    Button(action: {
                                        isShowStatistics = true
                                    }, label: {
                                        HStack {
                                            Image(systemName:"chart.bar.xaxis")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(Color(hex:"135FE0"))
                                                .frame(width: 20,height: 20)
                                            Spacer().frame(width: 20)
                                            Text("Statistics")
                                                .font(.footnote)
                                                .foregroundColor(color == .light ? .black : .white)
                                            Spacer()
                                        }
                                        .padding(.vertical,6)
                                        .padding(.horizontal,16)
                                        .frame(maxWidth: .infinity,maxHeight: .infinity)
                                    })
                                }
                                .frame(width: 160,height: 80)
                                .background(color == .light ? Color(hex: "F8F8F8") : Color(hex: "333333"))
                                .cornerRadius(10)
                            }
                        }
                        Spacer().frame(height: 20)
                        // 当前货币，收益
                        HStack {
                            // 当前货币
                            Button(action: {
                                isShowChangeCurrency = true
                            }, label: {
                                HStack {
                                    
                                    VStack {
                                        Spacer()
                                            .frame(height: 24)
                                        Image(color == .light ? "huobi" : "huobi1")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width:28,height: 28)
                                    }
                                    Spacer().frame(width: 14)
                                    VStack {
                                        Text("Current currency")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                        Spacer()
                                            .frame(height: 10)
                                        Text("CNY" as String)
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(color == .light ? .black : .white)
                                    }
                                }
                                .padding(20)
                                .frame(width: 160)
                                .contentShape(Rectangle())
                            })
                            Rectangle()
                                .frame(width:0.5,height:50)
                                .foregroundColor(.gray)
                            // 收益
                            
                            Button(action: {
                                
                            }, label: {
                                
                                HStack {
                                    VStack {
                                        Spacer()
                                            .frame(height: 24)
                                        Image(color == .light ? "shouyi" : "shouyi1")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width:28,height: 28)
                                    }
                                    Spacer().frame(width: 14)
                                    VStack {
                                        HStack {
                                            Text("Income")
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                        }
                                        .overlay {
                                            
                                            if #available(iOS 16.0, *) {
                                                Image(systemName: "arrow.down")
                                                    .fontWeight(.bold)
                                                    .foregroundColor(Color(hex: "ED3434"))
                                                    .offset(x:30)
                                            } else {
                                                // Fallback on earlier versions
                                                Image(systemName: "arrow.down")
                                                    .foregroundColor(Color(hex: "ED3434"))
                                                    .offset(x:30)
                                            }
                                        }
                                        Spacer()
                                            .frame(height: 10)
                                        Text("-20%")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color(hex: "ED3434"))
                                    }
                                }
                                .padding(20)
                                .frame(width: 160)
                                .contentShape(Rectangle())
                            })
                        }
                        .frame(width: 340, height: 60)
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
                                isShowSet = true
                            }, label: {
                                Image(systemName:"gearshape.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(color == .light ? .black : .white)
                            })
                        }
                    }
                    .sheet(isPresented: $isShowForeignCurrency) {
                        ForeignCurrencyView(isShowForeignCurrency: $isShowForeignCurrency)
                    }
                    .sheet(isPresented: $isShowConversion) {
                        ConversionView(isShowConversion: $isShowConversion)
                    }
                    .sheet(isPresented: $isShowStatistics) {
                        StatisticsView(isShowStatistics: $isShowStatistics)
                    }
                    .sheet(isPresented: $isShowChangeCurrency) {
                        ChangeCurrencyView(isShowChangeCurrency: $isShowChangeCurrency)
                    }
                    .sheet(isPresented: $isShowSet) {
                        SetView(isShowSet: $isShowSet)
                    }
                }
                .refreshable {
                    // 刷新方法
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
