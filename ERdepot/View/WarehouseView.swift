//
//  WarehouseView.swift
//  ERdepot
//
//  Created by 方君宇 on 2024/10/16.
//
// 仓库页面

import SwiftUI

struct WarehouseView: View {
    // 语言提示
    @AppStorage("languageTips") private var languageTips = false
    
    // 监听输入框
    @FocusState private var isFocused: Bool
    
    // 打开设置页面
    @State private var isShowingSettings = false
    @StateObject private var exchangeRate = ExchangeRate.ExchangeRateExamples
    
    // 用于控制弹出币种选择视图的状态
    @State private var isShowingCurrencySwitcher = false
    // 当前选择的币种
    @State private var selectedCurrency: String?
    // 当前选择的币种索引
    @State private var selectedIndexCurrency: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 汇率标题和设置按钮
                HStack {
                    Text("ERdepot")
                        .font(.system(size: 24))
                    Spacer()
                    Button(action: {
                        isShowingSettings = true
                    }, label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 20))
                    })
                }
                // 添加标题和汇率列表的间隔
                Spacer().frame(height: 20)
                // 汇率数据展示列表
                VStack {
                    List{
                        ForEach(Array(exchangeRate.CommonCurrencies.enumerated()), id:\.0) { index,item in
                            HStack {
                                // 货币国旗
                                Image("\(item)")
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(8)
                                    .frame(width: 60,height: 40)
                                // 货币本地化名称和货币单位
                                VStack(alignment: .leading) {
                                    Text(LocalizedStringKey(item))
                                        .font(.system(size: 14))
                                        .fontWeight(.semibold)
                                    // 货币单位
                                    Text("\(item)")
                                        .font(.system(size: 14))
                                        .foregroundStyle(Color(hex: "#898989"))
                                }
                                Spacer()
                                TextField(String(format: "%.2f",exchangeRate.ExchangeRateWarehousconvertedAmounts[item] ?? 0.00),text: Binding(
                                    get: {
                                        exchangeRate.ExchangeRateWarehousconvertedAmounts[item] == 0 || exchangeRate.ExchangeRateWarehousconvertedAmounts[item] == nil ? "" :
                                        String(format:"%.2f", exchangeRate.ExchangeRateWarehousconvertedAmounts[item] ?? 0)
                                    }, set: { newValue in
                                        // 将当前输入的金额赋值给inputValue
                                        exchangeRate.ExchangeRateWarehousconvertedAmounts[item] = Double(newValue) ?? 0.00
                                        // 每次输入变动时重新计算转换值
                                        exchangeRate.calculaterReserveAmount()
                                    }
                                ))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing) // 让输入文字靠右
                                .frame(maxWidth: .infinity,alignment: .trailing)
                                .focused($isFocused)
                            }
                            .listRowInsets(EdgeInsets()) // 移除默认的边距
                            .listRowSeparator(.hidden) // 去掉分隔线
                            .frame(height: 60)
                            .swipeActions(edge: .leading) {
                                Button {
                                    selectedCurrency = item
                                    isShowingCurrencySwitcher = true
                                    selectedIndexCurrency = index
                                } label: {
                                    Text("Switching Currency")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                    .listStyle(PlainListStyle()) // 更改列表样式
                }
                .frame(height: 300)
                // 替换首页的同步按钮 30 高
                Spacer().frame(height: 20)
                // 储备金额题目
                HStack {
                    Text("Reserve amount")
                        .font(.system(size: 24))
                    Spacer()
                }
                .frame(height: 45)
                .contentShape(Rectangle())
                .padding(.vertical, 0)
                VStack(alignment: .leading) {
                    // 储备金额
                    HStack {
                        VStack{
                            Text(LocalizedStringKey(ExchangeRate.ExchangeRateExamples.ExchangeRateCurrencyConversion))
                                .foregroundStyle(Color(hex:"#898989"))
                                .font(.system(size: 14))
                            Spacer().frame(height: 5)
                            Text(ExchangeRate.ExchangeRateExamples.ExchangeRateCurrencyConversion)
                                .fontWeight(.semibold)
                                .font(.system(size: 14))
                        }
                        Spacer().frame(width: 10)
                        Text(LocalizedStringKey(String(format: "%.2f",exchangeRate.ExchangeRateWarehouseAmount)))
                            .font(.system(size: 24))
                            .foregroundStyle(Color.white)
                            .padding(.horizontal,10)
                            .padding(.vertical,10)
                            .background(Color(hex:"0097FE"))
                            .cornerRadius(8)
                    }
                }
                .padding()
                .frame(height: 45)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                Spacer().frame(height: 30)
                // 右侧汇率信息说明：汇率同步时间，来源等等。
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Exchange rate synchronization time")
                            .fontWeight(.semibold)
                        Text(
                            exchangeRate.ExchangeRateStructInfo.syncDate.formatted(date: .long, time: .shortened))
                        Spacer().frame(height: 10)
                        Text("Exchange rate synchronization source")
                            .fontWeight(.semibold)
                        Text(LocalizedStringKey(exchangeRate.ExchangeRateStructInfo.sourceName))
                        Spacer().frame(height: 10)
                        Text("Exchange rate calculation method")
                            .fontWeight(.semibold)
                        Text(LocalizedStringKey(exchangeRate.ExchangeRateStructInfo.calculationMethod))
                        Spacer()
                    }
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#828282"))
                }
                Spacer()
            }
            .onTapGesture {
                isFocused = false
            }
            .navigationTitle(Text("ERdepot"))
            .navigationBarTitleDisplayMode(.inline)
            .containerRelativeFrame(.horizontal) { size, axis in size * 0.9 }
        }
        .sheet(isPresented: $isShowingSettings) {
            Settings()
        }
        // 币种选择视图
        .sheet(isPresented: $isShowingCurrencySwitcher) {
            CurrencySwitcherView(selectedCurrency: $selectedCurrency,selectedIndexCurrency: $selectedIndexCurrency)
        }
        .overlay(
            languageTips ?
            ZStack {
                Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
                VStack{
                    VStack {
                        Text("After restarting the app")
                        Text("update the language configuration")
                    }
                    .font(.system(size: 18))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white)
                    .frame(height: 80)
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(stops: [
                        Gradient.Stop(color: Color.clear, location: 0),
                        Gradient.Stop(color: .blue, location: 0.2),
                        Gradient.Stop(color: .blue, location: 0.8),
                        Gradient.Stop(color: Color.clear, location: 1),
                    ], startPoint: .leading, endPoint: .trailing)
                    )
                    
                    Spacer()
                        .frame(height: 20)
                    Button(action: {
                        languageTips = false
                    }, label: {
                        Text("OK")
                            .foregroundColor(Color.white)
                            .fontWeight(.semibold)
                            .frame(width: 150,height: 45)
                            .contentShape(Rectangle())
                            .background(Color.blue)
                            .cornerRadius(10)
                    })
                }
                .frame(width: 300,height: 280)
                .background(
                    Image("language")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(20)
                )
            }   : nil
        )
        .onAppear{
            print("languageTips:\(languageTips)")
        }
    }
}
#Preview {
    WarehouseView()
}
