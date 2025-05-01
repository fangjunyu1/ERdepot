//
//  HomeView.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/3/31.
//

import SwiftUI
import StoreKit
import CoreData

struct HomeView: View {
    @Environment(\.colorScheme) var color
    @EnvironmentObject var appStorage: AppStorageManager
    @EnvironmentObject var exchangeRate: ExchangeRate
    @State private var selectedTime: Int = 1
    @State private var isShowForeignCurrency = false
    @State private var isShowConversion = false
    @State private var isShowStatistics = false
    @State private var isShowChangeCurrency = false
    @State private var isShowSet = false
    @State private var isShowProfit = false
    @State private var chartPoints: [ExchangeRateChartPoint] = []
    @State private var refreshID = UUID() {
        didSet {
            print("修改ID，刷新视图")
            print("refreshID:\(oldValue)")
        }
    }
    // 分页指示器索引
    @State private var selectedIndex = 0
    
    let timeRange: [String] = ["1 Week","1 Month","3 Months","6 Months", "1 Year","5 Years","10 Years","All"]
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd"
        return formatter
    }()
    
    // 可循环的颜色数组
    let colorPalette: [Color] = [
        .red, .purple, .blue, .green, .orange, .pink, .yellow, .teal, .mint
    ]
    // 汇率字典
    @State private var rateDict: [String:Double] = [:]
    @State private var currencyCount = 0.0
    // 获取 Core Data 上下文
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        fetchRequest: {
            let request = NSFetchRequest<UserForeignCurrency>(entityName: "UserForeignCurrency")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \UserForeignCurrency.symbol, ascending: true)]
            return request
        }()
    ) var userForeignCurrencies: FetchedResults<UserForeignCurrency>
    
    // 计算总金额的计算属性
    var totalAmount: (Int,Double) {
        // 获取最新的汇率数据
        let latestRates = fetchLatestRates()
        rateDict = Dictionary(uniqueKeysWithValues: latestRates.map { ($0.symbol ?? "", $0.rate) })
        
        // 计算所有外币的金额
        var total = 0.0
        for userCurrency in userForeignCurrencies {
            if let symbol = userCurrency.symbol, let rate = rateDict[symbol],let localCurrency = rateDict[appStorage.localCurrency] ,rate > 0, localCurrency > 0 {
                total += userCurrency.amount / rate * localCurrency
            }
        }
        
        currencyCount = total
        // 将 totalAmount 拆分为整数部分和小数部分
        if total.isFinite {
            let integerPart = Int(total)
            let decimalPart = total - Double(integerPart)
            return (integerPart,decimalPart)
        } else {
            return (0,0.0)
        }
    }
    
    // 计算汇率仓库的收益
    var calculatePenefits: Double {
        // 可计算收益的外币价值
        var foreignCurrencyValue = 0.0
        // 可计算收益的外币购入价值
        var foreignCurrencyPurchasePrice = 0.0
        for userCurrency in userForeignCurrencies {
            if userCurrency.purchaseAmount > 0 {
                // 叠加当前外币价值
                // 计算公式为，外币金额 / 兑换欧元的汇率 * 本币的汇率
                foreignCurrencyValue += userCurrency.amount / (rateDict[userCurrency.symbol ?? ""] ?? 0) * (rateDict[appStorage.localCurrency] ?? 0)
                // 叠加可计算收益的外币购入价值
                foreignCurrencyPurchasePrice += userCurrency.purchaseAmount
            }
        }
        
        // 如果有外币购入金额，计算收益率
        if foreignCurrencyPurchasePrice > 0 {
            return (foreignCurrencyValue - foreignCurrencyPurchasePrice) / foreignCurrencyPurchasePrice * 100
        } else {
            return 0.0  // 没有外币购入时，收益率为 0
        }
    }
    
    func fetchLatestDate() -> Date? {
        let request = NSFetchRequest<NSDictionary>(entityName: "Eurofxrefhist")
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = ["date"]
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 1
        
        do {
            if let result = try viewContext.fetch(request).first,
               let latestDate = result["date"] as? Date {
                return latestDate
            }
        } catch {
            print("Error fetching latest date: \(error)")
        }
        return nil
    }
    
    func fetchLatestRates() -> [Eurofxrefhist] {
        guard let latestDate = fetchLatestDate() else { return [] }
        
        let request = NSFetchRequest<Eurofxrefhist>(entityName: "Eurofxrefhist")
        request.predicate = NSPredicate(format: "date == %@", latestDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "symbol", ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching latest rates: \(error)")
            return []
        }
    }
    
    func dateRange(for selectedTime: Int) -> Date? {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTime {
        case 0: return calendar.date(byAdding: .day, value: -7, to: now)
        case 1: return calendar.date(byAdding: .month, value: -1, to: now)
        case 2: return calendar.date(byAdding: .month, value: -3, to: now)
        case 3: return calendar.date(byAdding: .month, value: -6, to: now)
        case 4: return calendar.date(byAdding: .year, value: -1, to: now)
        case 5: return calendar.date(byAdding: .year, value: -5, to: now)
        case 6: return calendar.date(byAdding: .year, value: -10, to: now)
        default: return nil // All
        }
    }
    
    func generateHistoricalChartData(scope: Int) {
        print("进入generateHistoricalChartData方法")
        let calendar = Calendar.current
        let context = viewContext
        let startDate = dateRange(for: scope)
        var chartData: [ExchangeRateChartPoint] = []
        // 获取用户外币列表
        var userCurrencyList: [String:Double] = [:]
        let userRequest = NSFetchRequest<UserForeignCurrency>(entityName: "UserForeignCurrency")
        do {
            let userCurrencies = try context.fetch(userRequest)
            for currency in userCurrencies {
                if let symbol = currency.symbol {
                    userCurrencyList[symbol] = currency.amount
                    print("当前用户外币:\(symbol)，金额为：\(currency.amount)")
                }
            }
        } catch {
            print("Error fetching user currency: \(error)")
            return
        }

        // 获取汇率数据请求
        let request = NSFetchRequest<Eurofxrefhist>(entityName: "Eurofxrefhist")
        if let start = startDate {
            request.predicate = NSPredicate(format: "date >= %@", start as NSDate)
        }
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            let coreDate = Date()
            
            var results = try context.fetch(request)
            
            if results.isEmpty {
                print("Core Data中没有汇率数据")
            }
            print("获取CoreData数据用时:\(Date().timeIntervalSince(coreDate))")
            let grouped = Dictionary(grouping: results, by: { $0.date ?? Date.distantPast })
            print("Dictionary分组用时:\(Date().timeIntervalSince(coreDate))")
            let sortedDates = grouped.keys.sorted()
            print("Dictionary排序用时:\(Date().timeIntervalSince(coreDate))")
            print("排序时间为:\(sortedDates)")
            for date in sortedDates {
                if let dailyRate = grouped[date] {
                    var total: Double = 0
                    for (symbol, amount) in userCurrencyList {
                        if let rate = dailyRate.first(where: { $0.symbol == symbol})?.rate, let localRate =  dailyRate.first(where: { $0.symbol == appStorage.localCurrency })?.rate, rate > 0, localRate > 0{
                            total +=  amount / rate * localRate
                        }
                    }
                    chartData.append(ExchangeRateChartPoint(date: date, totalValue: total))
                }
            }
            print("完成所有时间的总额:\(Date().timeIntervalSince(coreDate)))")
            
            // 抽样最多50个点
                    if chartData.count > 50 {
                        let step = chartData.count / 50
                        chartData = stride(from: 0, to: chartData.count, by: step).map { chartData[$0] }
                    }

                    self.chartPoints = chartData
        } catch {
            print("Error fetching exchange rates: \(error)")
        }
    }
    
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
                                HStack(spacing:0){
                                    Text(currencySymbols[appStorage.localCurrency] ?? "USD")
                                    Text("  ")
                                    Text("\(totalAmount.0)")
                                    // 显示小数部分（格式化为两位小数）
                                    Text(String(format: "%.2f", totalAmount.1).dropFirst(1)) // 去掉小数点符号
                                        .foregroundColor(.gray)  // 小数部分使用灰色字体
                                }
                                .font(.title2)
                                .foregroundColor(.white)
                                Spacer()
                            }
                            Spacer().frame(height: 10)
                            // 仓库金额各币种进度
                            HStack(spacing:3) {
                                if userForeignCurrencies.isEmpty {
                                    VStack(spacing: 0) {
                                        Text("")
                                            .font(.footnote)
                                            .opacity(0)
                                        Rectangle().frame(width: width * 0.8,height: 8)
                                            .foregroundColor(.purple)
                                            .cornerRadius(6)
                                    }
                                } else {
                                    ForEach(Array(userForeignCurrencies.enumerated()), id:\.0){ index,currency in
                                        if let symbol = currency.symbol,let rate = rateDict[currency.symbol ?? ""],let localCurrency = rateDict[appStorage.localCurrency],rate > 0, localCurrency > 0 {
                                            let ratio = currency.amount  / rate * localCurrency / currencyCount
                                            let barColor = colorPalette[index % colorPalette.count]
                                            VStack(spacing: 0) {
                                                if ratio >= 0.05 {
                                                    Text(symbol)
                                                        .font(.footnote)
                                                        .foregroundColor(Color(hex: "FFFFFF"))
                                                } else {
                                                    Rectangle().frame(width:1,height:15)
                                                        .opacity(0)
                                                }
                                                Rectangle().frame(width: width * ratio * 0.8,height: 8)
                                                    .foregroundColor(barColor)
                                                    .cornerRadius(6)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(14)
                        .background(color == .light ? .black : Color(hex: "1f1f1f"))
                        .cornerRadius(10)
                        .frame(width: width * 0.95)
                        .zIndex(1)
                        
                        // 图表
                        VStack(spacing:0) {
                            Spacer()
                            ExchangeRateChart(dataPoints: chartPoints)
                                .padding(.vertical,12)
                                .padding(.horizontal,14)
                                .frame(height: 180)
                                .background(color == .light ? .white : Color(hex: "111111"))
                                .cornerRadius(4)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(timeRange.indices, id: \.self) { time in
                                        Button(action: {
                                            selectedTime = time
                                            generateHistoricalChartData(scope: time)
                                        }, label: {
                                            Text(LocalizedStringKey(timeRange[time]))
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                                .padding(.vertical,8)
                                                .padding(.horizontal,12)
                                                .foregroundColor(time == selectedTime ? .white : color == .light ? .black : Color(hex: "eeeeee"))
                                                .background(time == selectedTime ? Color(hex: "5D5D5D") : color == .light ? Color(hex: "FFFFFF") : Color(hex: "888888"))
                                                .cornerRadius(10)
                                        })
                                        .disabled(time == selectedTime)
                                    }
                                }
                            }
                            .padding(.horizontal,10)
                            .padding(.bottom,10)
                        }
                        .frame(width: width * 0.9, height: 240)
                        .background(color == .light ? .white : .black)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .offset(y:-10)
                        .zIndex(0)
//                        .overlay {
//                            VStack {
//                                Rectangle()
//                                    .frame(maxWidth: .infinity)
//                                    .frame(height: 10)
//                                    .foregroundColor(color == .light ? .white : .black)
//                                    .offset(y:0)
//                                Spacer()
//                            }
//                        }
                        
                        Spacer().frame(height: 15)
                        Rectangle().frame(width: 0.9 * width, height: 0.5)
                            .foregroundColor(.gray)
                        Spacer().frame(height: 15)
                        // TabView列表：外币、更新时间、数字货币、大宗商品
                        TabView(selection: $selectedIndex) {
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
                                    VStack(spacing:0) {
                                        // 外币图片
                                        HStack {
                                            Image("money")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 33,height: 33)
                                            Spacer()
                                        }
                                        Spacer().frame(height: 10)
                                        // 管理
                                        HStack{
                                            Text("Manage")
                                                .font(.footnote)
                                                .fontWeight(.medium)
                                                .foregroundColor(.white)
                                            Spacer()
                                        }
                                        Spacer().frame(height: 10)
                                        // 外币
                                        HStack{
                                            Text("Foreign currency")
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .lineLimit(2) // 限制为单行
                                                .minimumScaleFactor(0.5) // 最小缩放到 30%
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical,10)
                                    .padding(.horizontal,20)
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
                                        if exchangeRate.isload {
                                            ProgressView("")
                                                .offset(y:5)
                                                .tint(.white)
                                            
                                        } else {
                                            Text("Update time") + Text(":") +
                                            Text(formatter.string(from: exchangeRate.latestDate ?? Date(timeIntervalSince1970: 1743696000)))  // 显示格式化后的日期
                                        }
                                    }
                                    .font(.footnote)
                                    .frame(width: 160,height: 50)
                                    .foregroundColor(.white)
                                    .background(
                                        Color(hex: "1AAE0E")
                                            .opacity(color == .light ? 1 : 0.8)
                                    )
                                    .cornerRadius(10)
                                    .lineLimit(2) // 限制为单行
                                    .minimumScaleFactor(0.5) // 最小缩放到 30%
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
                                                    .lineLimit(1) // 限制为单行
                                                    .minimumScaleFactor(0.5) // 最小缩放到 30%
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
                                                    .lineLimit(1) // 限制为单行
                                                    .minimumScaleFactor(0.5) // 最小缩放到 30%
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
                            .tag(0)
                            
                            // 数字货币、大宗商品
                            VStack {
                                
                            }
                            .tag(1)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height:160)
                        // 自定义分页指示器，偏移位置
                        HStack(spacing: 8) {
                            ForEach(0...1, id: \.self) { index in
                                Circle()
                                    .fill(index == selectedIndex ? Color.gray : Color.white)
                                    .frame(width: 8, height: 8)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray, lineWidth: 1)
                                    )

                            }
                        }
                        Spacer().frame(height: 20)
                        // 当前币种，收益
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
                                            .fixedSize()
                                        Spacer()
                                            .frame(height: 10)
                                        Text(verbatim:"\(appStorage.localCurrency)")
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
                                isShowProfit = true
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
                                            Text("Profit")
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                        }
                                        .overlay {
                                            
                                            if #available(iOS 16.0, *) {
                                                if calculatePenefits == 0 {
                                                    Image(systemName: "arrow.up")
                                                        .offset(x:30)
                                                        .opacity(0)
                                                }
                                                else if calculatePenefits > 0 {
                                                    Image(systemName: "arrow.up")
                                                        .fontWeight(.bold)
                                                        .foregroundColor(Color(hex: "0B8B2C"))
                                                        .offset(x:30)
                                                } else {
                                                    Image(systemName: "arrow.down")
                                                        .fontWeight(.bold)
                                                        .foregroundColor(Color(hex: "ED3434"))
                                                        .offset(x:30)
                                                }
                                            } else {
                                                // Fallback on earlier versions
                                                Image(systemName: "arrow.down")
                                                    .foregroundColor(Color(hex: "ED3434"))
                                                    .offset(x:30)
                                            }
                                        }
                                        Spacer()
                                            .frame(height: 10)
                                        if calculatePenefits == 0 {
                                            Text("--")
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .foregroundColor(.gray)
                                        } else {
                                            Text("\(String(format:"%.2f",calculatePenefits))%")
                                                .font(.title3)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color(hex: calculatePenefits > 0 ? "0B8B2C" :"ED3434"))
                                                .fixedSize()
                                        }
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
                    .sheet(isPresented: $isShowForeignCurrency,onDismiss: {
                        // refreshID = UUID()
                        print("从管理外币视图外汇，重新绘制折线图")
                        generateHistoricalChartData(scope: selectedTime)
                    }) {
                        ForeignCurrencyView(isShowForeignCurrency: $isShowForeignCurrency)
                    }
                    .sheet(isPresented: $isShowConversion) {
                        ConversionView(isShowConversion: $isShowConversion)
                    }
                    .sheet(isPresented: $isShowStatistics) {
                        StatisticsView(isShowStatistics: $isShowStatistics)
                    }
                    .sheet(isPresented: $isShowChangeCurrency,onDismiss: {
                        generateHistoricalChartData(scope: selectedTime)
                    }) {
                        ChangeCurrencyView(isShowChangeCurrency: $isShowChangeCurrency, selectionType: .localCurrency)
                    }
                    .sheet(isPresented: $isShowSet) {
                        SetView(isShowSet: $isShowSet)
                    }
                    .sheet(isPresented: $isShowProfit) {
                        ProfitView(isShowProfit: $isShowProfit)
                    }
                }
                .refreshable {
                    // 调用下载方法
                    exchangeRate.downloadExchangeRates()
                    // 重新绘制图表
                    generateHistoricalChartData(scope: selectedTime)
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            // 首次打开应用，调用评分
            if !appStorage.RequestRating {
                appStorage.RequestRating = true
                SKStoreReviewController.requestReview()
            }
            // 获取最新的汇率数据
            var latestRates = fetchLatestRates()
            
            // 如果最新日期为nil，更新最新日期
            if exchangeRate.latestDate == nil {
                exchangeRate.updateLatestDate()
            }
            // 更新日期并更新折线图
            if calendar.isDate(Date(), inSameDayAs: Date(timeIntervalSince1970: appStorage.exchangeRateUpdateDate)) {
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone(identifier: "Asia/Shanghai") // 设置为中国时间
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                print("今天\(formatter.string(from: Date(timeIntervalSince1970: appStorage.exchangeRateUpdateDate))) 已经更新过汇率，不在更新。")
                generateHistoricalChartData(scope: selectedTime)
            } else {
                print("今天首次打开应用，更新汇率数据")
                exchangeRate.downloadExchangeRates()
                print("将今天的日期更新到同步日期，今天不再更新汇率，除非手动更新。")
                appStorage.exchangeRateUpdateDate = Date().timeIntervalSince1970
                generateHistoricalChartData(scope: selectedTime)
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
            HomeView()
                .preferredColorScheme(.dark)
        }
//        .environment(\.locale, .init(identifier: "de")) // 设置为阿拉伯语
        .environmentObject(AppStorageManager.shared)
        .environmentObject(ExchangeRate.shared)
        .environmentObject(IAPManager.shared)
        .environment(\.managedObjectContext, CoreDataPersistenceController.shared.context) // 加载 NSPersistentContainer
    }
}
