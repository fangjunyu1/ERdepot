//
//  HomeView.swift
//  ERdepot
//
//  Created by 方君宇 on 2024/10/16.
//
// 首页

import SwiftUI
struct HomeView: View {
    // 语言提示
    @AppStorage("languageTips") private var languageTips = false
    
    // 记录当前输入的值
    @State private var inputValue = 0.00
    // 记录当前输入的货币
    @State private var currentCurrency: String = ""
    // 记录转换后的金额
    @State private var convertedAmounts: [String: Double] = [:]
    // 监听输入框
    @FocusState private var isFocused: Bool
    
    // 同步汇率按钮的旋转
    @State private var isRotating = false
    // 同步汇率按钮的调用
    @State private var isDisabled = false
    
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
                    Text("Exchange Rate of the Day")
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
                                TextField("\(exchangeRate.ExchangeRateStructInfo.exchangeRates[item]?.rate ?? 0.00)",text: Binding(
                                    get: {
                                        // 如果当前币种跟输入币种一致
                                        if inputValue == 0 {
                                            return ""
                                        } else if currentCurrency == item {
                                            // 显示输入的金额
                                            return String(inputValue)
                                        } else {
                                            // 查询返回的币种金额
                                            let tmpAmount = convertedAmounts[item]
                                            return String(format: "%.2f",tmpAmount ?? 0.00)
                                        }
                                    },
                                    set: { newValue in
                                        // 将当前输入的金额赋值给inputValue
                                        inputValue = Double(newValue) ?? 0.00
                                        // 将当前的货币单位（USD）赋值给 currentCurrency 变量
                                        currentCurrency = item
                                        // 每次输入变动时重新计算转换值
                                        if let inputAmount = Double(newValue) {
                                            convertedAmounts = exchangeRate.calculateConvertedAmounts(inputAmount: inputAmount, currency: item)
                                        }
                                    }
                                ))
                                .foregroundColor(item != currentCurrency ? Color(hex: "8B8B8B") : Color(hex: "378FEB") )
                                .fontWeight(item == currentCurrency ? .bold : .medium)
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
                // 按钮和汇率列表的间隔 40 高
                Spacer().frame(height: 20)
                // 按钮 80 高
                Button(action: {
                    
                    // 禁用按钮
                    isDisabled = true
                    exchangeRate.judgeSource()
                    // 触发旋转动画
                    withAnimation(.easeInOut(duration: 1.0)) {
                        isRotating = true
                    }
                    
                    // 恢复按钮状态
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        isRotating = false
                        
                        withAnimation(.easeInOut(duration: 1.0)) {
                            isDisabled = false
                        }
                    }
                    
                }, label: {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 60))
                        .rotationEffect(.degrees(isRotating ? 360 : 0)) // 旋转效果
                        .foregroundColor(isDisabled ? .gray : .blue) // 变灰色
                        .padding()
                })
                .disabled(isDisabled)
                .padding()
                // 点击按钮触觉反馈
                .sensoryFeedback(.increase, trigger: isDisabled)
                .frame(maxWidth: .infinity,maxHeight: 90)
                .contentShape(Rectangle())
                // 按钮和右侧信息 30 高
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
                .frame(height: 130)
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
        .onChange(of: isShowingCurrencySwitcher){
            print("进入视图，重新计算convertedAmounts")
            for item in exchangeRate.CommonCurrencies {
                convertedAmounts = exchangeRate.calculateConvertedAmounts(inputAmount: inputValue, currency: item)
            }
            
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
    }
}
#Preview {
    HomeView()
}
