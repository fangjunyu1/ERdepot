//
//  StatisticsView.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/4/6.
//

import SwiftUI
import CoreData

struct StatisticsView: View {
    @Environment(\.colorScheme) var color
    @EnvironmentObject var appStorage: AppStorageManager
    @Binding var isShowStatistics: Bool
    
    // 汇率字典
    @State private var rateDict: [String:Double] = [:]
    @State private var currencyCount = 0.0
    
    // 仓库金额
    @State private var Amount = 0.0
    // 成本
    @State private var Cost = 0.0
    
    // 查询历史高点的状态，true表示查询结束
    @State private var queryHistoricalHighs = false
    
    // 历史高点
    @State private var historicalHighs = 0.00
    // 历史时间
    @State private var historicalTime: Date = Date(timeIntervalSince1970: 915379200)
    
    // 获取 Core Data 上下文
    @Environment(\.managedObjectContext) private var viewContext
    let backgroundContext = CoreDataPersistenceController.shared.backgroundContext
    
    @FetchRequest(
        fetchRequest: {
            let request = NSFetchRequest<UserForeignCurrency>(entityName: "UserForeignCurrency")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \UserForeignCurrency.symbol, ascending: true)]
            return request
        }()
    ) var userForeignCurrencies: FetchedResults<UserForeignCurrency>
    
    // 获取所有外币列表
    private func fetchListOfForeignCurrencies() -> [UserForeignCurrency] {
        
        // 使用正确的请求类型，直接请求 UserForeignCurrency 类型的实体
        let request: NSFetchRequest<UserForeignCurrency> = UserForeignCurrency.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "symbol", ascending: false)]
        
        do {
            let resultList =  try viewContext.fetch(request)
            return resultList
        } catch {
            print("Error fetching latest date: \(error)")
        }
        
        return []
    }
    
    // 获取最新时间
    private func fetchLatestDate() -> Date? {
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
    
    // 获取最新汇率
    private func fetchLatestRates() -> [Eurofxrefhist] {
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
    
    // 计算仓库的金额，成本和收益
    private func CalculateWarehouseAmount() {
        // 获取最新的汇率数据
        let latestRates = fetchLatestRates()
        rateDict = Dictionary(uniqueKeysWithValues: latestRates.map { ($0.symbol ?? "", $0.rate) })
        
        for userCurrency in userForeignCurrencies {
            if let symbol = userCurrency.symbol, let rate = rateDict[symbol],let localCurrency = rateDict[appStorage.localCurrency] {
                Amount += userCurrency.amount / rate * localCurrency
            }
        }
    }
    
    private func CalculateCosts() {
        for currency in userForeignCurrencies {
            if currency.purchaseAmount > 0 {
                Cost += currency.purchaseAmount
            }
        }
    }
    
    private var Benefit: Double {
        return Amount - Cost
    }
    
    // 轮训汇率的所有日期
    private func CalculatingHistoricalHighs() {
        
        // 查询状态改为 true
        queryHistoricalHighs = true
        print("查询状态改为\(queryHistoricalHighs)")
        
        // 用户所有外币
        var UserCurrency: [UserForeignCurrency] = []
        // 获取用户所有外币
        UserCurrency = fetchListOfForeignCurrencies()
        
        // 获取所有金额的外币
        // 获取所有汇率的日期，去重
        let rateDate = NSFetchRequest<NSDictionary>(entityName: "Eurofxrefhist")
        rateDate.resultType = .dictionaryResultType
        // 获取汇率的 date 字段
        rateDate.propertiesToFetch = ["date"]
        // 将获取到的汇率数据去重
        rateDate.returnsDistinctResults = true
        rateDate.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        backgroundContext.perform {
            
            do {
                print("开始调用 CalculatingHistoricalHighs 获取时间的方法")
                let startDate = Date()
                
                let rateDateresults = try backgroundContext.fetch(rateDate)
                // 遍历所有的汇率日期
                for rate in rateDateresults {
                    // 从字典中提取出 date 字段并确保它是 Date 类型
                    if let rateDate = rate["date"] as? Date {
                        let rateRequest =
                        // 调用 CalculateForeignCurrencyAmounts 方法，并传递正确的 Date 类型
                        CalculateForeignCurrencyAmounts(date: rateDate,userCurrencies: UserCurrency)
                    } else {
                        print("无法获取日期，跳过该条记录")
                    }
                }
                print("结束 CalculatingHistoricalHighs 方法的调用，用时:\(Date().timeIntervalSince(startDate))秒")
                DispatchQueue.main.async {
                    queryHistoricalHighs = false
                    print("查询状态改为\(queryHistoricalHighs)")
                    appStorage.reCountingHistoricalHighs = false
                    print("完成历史时间和高点的查询，改为\(queryHistoricalHighs)")
                }
            } catch {
                print("未获取到全部时间")
            }
            
            
        }
    }
    
    func CalculateForeignCurrencyAmounts(date: Date, userCurrencies: [UserForeignCurrency]) {
        
        // 临时变量，计算当天的最高值
        var calculateCount = 0.00
        
        // 获取当天的所有汇率数据
        let request = NSFetchRequest<Eurofxrefhist>(entityName: "Eurofxrefhist")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Eurofxrefhist.symbol, ascending: true)]
        // 添加过滤条件（可选）
        request.predicate = NSPredicate(format: "date == %@", date as NSDate)
        
        do {
            
            let result = try? backgroundContext.fetch(request)
            // 遍历所有的外币
            for currency in userCurrencies {
                // 获取对应外币的汇率
                if let result = result {
                    if let rate = result.filter({ $0.symbol == currency.symbol}).first?.rate, let localRate = result.first(where: { $0.symbol == appStorage.localCurrency })?.rate,rate > 0,
                       localRate > 0 {
                        let amount = currency.amount / rate * localRate

                        // 确保这个计算结果是正常数值（非 inf 非 nan）
                        if amount.isFinite {
                            calculateCount += amount
                        } else {
                            print("非法金额（inf 或 nan）在日期：\(date)，symbol: \(currency.symbol ?? "")")
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                if calculateCount >= appStorage.historicalHigh && calculateCount > 0 {
                    appStorage.historicalHigh = calculateCount
                    appStorage.historicalTime = date.timeIntervalSince1970
                }
            }
        } catch {
            print("backgroundContext发生了报错")
        }
    }
    // 格式化日期
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.frame(in: .global).width * 0.95
            let height = geo.frame(in: .global).height
            ScrollView(showsIndicators: false) {
                VStack {
                    Spacer()
                        .frame(height: 30)
                    HStack {
                        // 返回箭头
                        Button(action: {
                            isShowStatistics = false
                        }, label: {
                            if #available(iOS 16.0, *) {
                                Image(systemName: "chevron.left")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24,height: 24)
                                    .fontWeight(.bold)
                                    .foregroundColor(color == .light ? .black : .white)
                            } else {
                                Image(systemName: "chevron.left")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24,height: 24)
                                    .foregroundColor(color == .light ? .black : .white)
                            }
                        })
                        Spacer()
                    }
                    Spacer().frame(height: 24)
                    // 外币
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Statistics")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer().frame(height: 10)
                            Text("Statistics of foreign currency data.")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        VStack {
                            Image("count")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70)
                        }
                        
                    }
                    Spacer().frame(height: 20)
                    VStack(spacing: 0) {
                        Group {
                            // 仓库金额
                            HStack(spacing:0) {
                                Text("Warehouse amount")
                                Spacer()
                                
                                Text("\(currencySymbols[appStorage.localCurrency] ?? "")")
                                Spacer().frame(width: 8)
                                Text(Amount.formattedWithTwoDecimalPlaces())
                            }
                            .frame(height: 50)
                            Divider()
                            
                            // 成本
                            HStack(spacing:0) {
                                Text("Cost")
                                Spacer()
                                
                                Text("\(currencySymbols[appStorage.localCurrency] ?? "")")
                                Spacer().frame(width: 8)
                                Text(Cost.formattedWithTwoDecimalPlaces())
                            }
                            .frame(height: 50)
                            Divider()
                            
                            // 收益
                            HStack(spacing:0) {
                                Text("Profit")
                                Spacer()
                                
                                Text("\(currencySymbols[appStorage.localCurrency] ?? "")")
                                Spacer().frame(width: 8)
                                Text(Benefit.formattedWithTwoDecimalPlaces())
                            }
                            .frame(height: 50)
                        }
                        .padding(.horizontal,20)
                    }
                    .frame(width: width * 0.85)
                    .background(color == .light ? Color(hex: "ECECEC") : Color(hex: "2f2f2f"))
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .cornerRadius(10)
                    
                    // 分隔
                    Spacer().frame(height: 20)
                    
                    // 历史时间和历史高点
                    VStack(spacing: 0) {
                        Group {
                            // 历史时间
                            HStack(spacing:0) {
                                Text("HistoricalTime")
                                Spacer()
                                if queryHistoricalHighs {
                                    ProgressView("").offset(y:6).padding(.trailing,5)
                                }
                                Text(formattedDate(Date(timeIntervalSince1970: appStorage.historicalTime)))
                                
                            }
                            .frame(height: 50)
                            Divider()
                            
                            // 历史高点
                            HStack(spacing:0) {
                                Text("HistoricalHighs")
                                Spacer()
                                if queryHistoricalHighs {
                                    ProgressView("").offset(y:6).padding(.trailing,5)
                                }
                                Text("\(currencySymbols[appStorage.localCurrency] ?? "")")
                                Spacer().frame(width: 8)
                                Text(appStorage.historicalHigh.formattedWithTwoDecimalPlaces())
                            }
                            .frame(height: 50)
                        }
                        .padding(.horizontal,20)
                    }
                    .frame(width: width * 0.85)
                    .background(color == .light ? Color(hex: "ECECEC") : Color(hex: "2f2f2f"))
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .cornerRadius(10)
                }
                .frame(width: width * 0.85)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            // 调用获取仓库金额的方法
            CalculateWarehouseAmount()
            // 调用称成本金额
            CalculateCosts()
            // 当需要计算历史最高点时，调用对应方法
            if appStorage.reCountingHistoricalHighs {
                // 计算历史高点和历史时间
                CalculatingHistoricalHighs()
            }
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StatisticsView(isShowStatistics: .constant(true))
            StatisticsView(isShowStatistics: .constant(true))
                .preferredColorScheme(.dark)
        }
        .environmentObject(AppStorageManager.shared)
        .environmentObject(ExchangeRate.shared)
        .environmentObject(IAPManager.shared)
        .environment(\.managedObjectContext, CoreDataPersistenceController.shared.context) // 加载 NSPersistentContainer
        .environment(\.backgroundContext, CoreDataPersistenceController.shared.backgroundContext) // 加载 NSPersistentContainer
    }
}
