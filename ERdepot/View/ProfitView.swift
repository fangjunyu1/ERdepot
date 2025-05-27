//
//  ProfitView.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/4/6.
//

import SwiftUI
import CoreData

struct ProfitView: View {
    
    @Environment(\.colorScheme) var color
    @EnvironmentObject var appStorage: AppStorageManager
    @Binding var isShowProfit: Bool
    
    // 汇率字典
    @State private var rateDict: [String:Double] = [:]
    
    // 输入金额
    @State private var inputAmounts: [String: String] = [:]
    // 收益率
    @State private var yield: [String: Double] = [:]
    // 收益金额
    @State private var amountOfIncome: [String: Double] = [:]
    // 当前价值
    @State private var currentValue: [String: Double] = [:]
    
    // 多个输入框的聚集
    @FocusState private var focusedField: CurrencyField?
    enum CurrencyField: Hashable {
        case symbol(String)
    }
    
    // 获取 Core Data 上下文
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        fetchRequest: {
            let request = NSFetchRequest<UserForeignCurrency>(entityName: "UserForeignCurrency")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \UserForeignCurrency.symbol, ascending: true)]
            return request
        }()
    ) var userForeignCurrencies: FetchedResults<UserForeignCurrency>
    
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
    
    func handleInputChange(for symbol: String, newValue: String) {
        print("计算货币:\(symbol)")
        var cleanedValue = newValue.replacingOccurrences(of: ",", with: "")  // 移除千分位分隔符
        let existing = userForeignCurrencies.first(where: { $0.symbol == symbol })
        
        // 新增或更新
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        print("cleanedValue:\(cleanedValue)")
        if let number = formatter.number(from: cleanedValue) {
            print("number计算成功")
            let value = number.doubleValue
            if let existing = existing {
                // 修改
                existing.purchaseAmount = value
                print("当前的购买金额改为:\(existing.purchaseAmount)")
            }
        } else if cleanedValue.isEmpty {
            if let existing = existing {
                // 修改
                existing.purchaseAmount = 0.00
                print("当前的购买金额改为:\(existing.purchaseAmount)")
            }
        } else {
            print("number计算失败")
        }
        
        
        if cleanedValue.isEmpty || Int(cleanedValue) == 0 {
            inputAmounts[symbol] = ""
        } else if let doubleValue = Double(cleanedValue) {
            print("string计算成功")
            let string = formatter.string(from: NSNumber(value:doubleValue))
            inputAmounts[symbol] = string
            print("string:\(string ?? "")")
        } else {
            print("string计算失败")
        }
        
        try? viewContext.save()
        
        // 计算收益率和收益金额
        CalculateIncomeData()
    }
    
    // 计算收益
    func CalculateIncomeData() {
        print("进入计算收益方法")
        for currency in userForeignCurrencies {
            print("货币：\(currency.symbol ?? "")")
            if let symbol = currency.symbol,let rate = rateDict[symbol],let localRate = rateDict[appStorage.localCurrency] {
                print("inputAmounts[symbol]:\(inputAmounts[symbol])")
                // 买入金额
                var inputAmount = inputAmounts[symbol]?.replacingOccurrences(of: ",", with: "")  // 移除千分位分隔符
                
                // 新增或更新
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.maximumFractionDigits = 2
                formatter.minimumFractionDigits = 2
                
                // 购入金额
                let buyAmount = Double(inputAmount ?? "0") ?? 0
                
                // 当前金额
                let currentAmount = currency.amount / rate * localRate
                print("当前金额为:\(currentAmount)，汇率为:\(rate)")
                
                currentValue[currency.symbol ?? ""] = currentAmount
                
                // 收益率 = （ 当前金额 - 买入金额 ）/ 买入金额
                if buyAmount != 0 {
                    yield[symbol] = (currentAmount - buyAmount) / buyAmount
                } else {
                    yield[symbol] = 0
                }
                print("收益率：\(yield[symbol] ?? 0)")
                // 收益金额 = 当前金额 - 买入金额
                if buyAmount != 0 {
                    amountOfIncome[symbol] = currentAmount - buyAmount
                } else {
                    amountOfIncome[symbol] = 0
                }
                print("收益金额：\(amountOfIncome[symbol] ?? 0)")
            } else {
                print("货币赋值报错：\(currency.symbol)")
                print("汇率赋值报错：\(rateDict[currency.symbol ?? ""])")
                for rate in rateDict {
                    print("货币:\(rate.key)")
                    print("汇率:\(rate.value)")
                }
            }
        }
        print("结束计算收益方法")
    }
    var body: some View {
        GeometryReader { geo in
            let width = geo.frame(in: .local).width * 0.95
            let height = geo.frame(in: .local).height
            ScrollView(showsIndicators: false) {
                VStack {
                    Spacer()
                        .frame(height: 30)
                    HStack {
                        // 返回箭头
                        Button(action: {
                            isShowProfit = false
                        }, label: {
                            if #available(iOS 16.0, *) {
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24,height: 24)
                                    .fontWeight(.bold)
                                    .foregroundColor(color == .light ? .black : .white)
                            } else {
                                Image(systemName: "chevron.down")
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
                            Text("Profit")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer().frame(height: 10)
                            Text("Calculate all foreign currency gains.")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        VStack {
                            Image("growth")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70)
                        }
                        
                    }
                    Spacer()
                        .frame(height: 20)
                    // 显示已有的外币记录
                    if userForeignCurrencies.isEmpty {
                        Image("noData")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                        Spacer()
                            .frame(height:20)
                        Text("You need to add foreign currencies to set costs and view revenue in the corresponding foreign currencies.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    } else {
                        ForEach(userForeignCurrencies,id:\.self) { currency in
                            if let symbol = currency.symbol {
                                // 当前外币和购买金额
                                VStack {
                                    HStack {
                                        Image(symbol)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 60, height: 36)
                                            .cornerRadius(10)
                                        Spacer().frame(width: 20)
                                        VStack(alignment: .leading) {
                                            Text("\(symbol)")
                                                .foregroundColor(.gray)
                                            Spacer().frame(height: 4)
                                            Text(LocalizedStringKey(symbol))
                                        }
                                        .font(.caption2)
                                        Spacer()
                                        Text(currency.amount.formattedWithTwoDecimalPlaces())
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal,20)
                                    .frame(width: width * 0.85,height: 50)
                                    .background(color == .light ? Color(hex: "ECECEC") : Color(hex: "2f2f2f"))
                                    .cornerRadius(10)
                                    .zIndex(2)
                                    // 当前外币
                                    HStack {
                                        Image(appStorage.localCurrency)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 48, height: 30)
                                            .cornerRadius(10)
                                        Spacer().frame(width: 20)
                                        VStack(alignment: .leading) {
                                            Text("\(appStorage.localCurrency)")
                                                .foregroundColor(Color(hex: "E1E1E1"))
                                            Spacer().frame(height: 4)
                                            Text(LocalizedStringKey(appStorage.localCurrency))
                                                .foregroundColor(.white)
                                        }
                                        .font(.caption2)
                                        Spacer()
                                        TextField("0.00", text: Binding(get: {
                                            inputAmounts[symbol] ?? ""
                                        }, set: { newValue in
                                            inputAmounts[symbol] = newValue
                                        }))
                                        .foregroundColor(.white)
                                        .keyboardType(.decimalPad) // 数字小数点键盘
                                        .focused($focusedField, equals: .symbol(symbol)) // 添加这一行
                                        .multilineTextAlignment(.trailing)
                                        .padding(.leading,10)
                                        .onChange(of: focusedField) { newFocus in
                                            // 当失去焦点，处理文本框关于 CoreData 方法
                                            if newFocus != .symbol(symbol) {
                                                handleInputChange(for: symbol, newValue: inputAmounts[symbol] ?? "")
                                            }
                                        }
                                    }
                                    .padding(.top,5)
                                    .padding(.horizontal,10)
                                    .frame(width: width * 0.8,height: 55)
                                    .background(Color(hex: "6C6C6C"))
                                    .cornerRadius(10)
                                    .offset(y: -15)
                                    .zIndex(1)
                                    if let inputAmount = inputAmounts[symbol],!inputAmount.isEmpty {
                                        // 收益率和收益金额
                                        HStack {
                                            // 当前价值
                                            VStack(alignment: .center) {
                                                Text("Current value")
                                                    .foregroundColor(Color(hex: "cccccc"))
                                                Spacer().frame(height: 4)
                                                HStack {
                                                    Text("\(currencySymbols[appStorage.localCurrency] ?? "")")
                                                    Text("\((currentValue[symbol] ?? 0.0).formattedWithTwoDecimalPlaces())")
                                                }
                                                .foregroundColor(.white)
                                            }
                                            .font(.caption2)
                                            Spacer()
                                            // 收益率
                                            VStack(alignment: .center) {
                                                Text("Yield")
                                                    .foregroundColor(Color(hex: "cccccc"))
                                                Spacer().frame(height: 4)
                                                HStack {
                                                    Text("\((yield[symbol] ?? 0).formatted(.percent.precision(.fractionLength(0...2))))")
                                                }
                                                .foregroundColor(.white)
                                            }
                                            .font(.caption2)
                                            Spacer()
                                            // 收益
                                            VStack(alignment: .center) {
                                                Text("Income")
                                                    .foregroundColor(Color(hex: "cccccc"))
                                                Spacer().frame(height: 4)
                                                HStack {
                                                    Text("\(currencySymbols[appStorage.localCurrency] ?? "")")
                                                    Text("\((amountOfIncome[symbol] ?? 0.0).formattedWithTwoDecimalPlaces())")
                                                }
                                                .foregroundColor(.white)
                                            }
                                            .font(.caption2)
                                        }
                                        .padding(.top,5)
                                        .padding(.horizontal,20)
                                        .frame(width: width * 0.75,height: 55)
                                        .background(Color(hex: "1f1f1f"))
                                        .cornerRadius(10)
                                        .offset(y: -30)
                                        .zIndex(0)
                                    }
                                }
                            }
                        }
                        Text("Below is the cost of purchasing foreign currency. You need to enter the cost to calculate the profit.")
                            .foregroundColor(.gray)
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(width: width * 0.85)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onTapGesture {
            // 取消TextField的聚焦
            focusedField = nil
        }
        .onAppear {
            
            // 获取最新的汇率数据
            var latestRates = fetchLatestRates()
            rateDict = Dictionary(uniqueKeysWithValues: latestRates.map { ($0.symbol ?? "", $0.rate) })
            
            for currency in userForeignCurrencies {
                if let symbol = currency.symbol {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    formatter.maximumFractionDigits = 2
                    formatter.minimumFractionDigits = 2
                    if currency.purchaseAmount == 0 {
                        inputAmounts[symbol] = ""
                    } else {
                        inputAmounts[symbol] =  formatter.string(from: NSNumber(value: currency.purchaseAmount)) ?? ""
                    }
                }
            }
            
            // 计算收益率和收益金额
            CalculateIncomeData()
        }
    }
}

#Preview {
    ProfitView(isShowProfit: .constant(true))
        .environmentObject(AppStorageManager.shared)
        .environment(\.managedObjectContext, CoreDataPersistenceController.shared.context) // 加载 NSPersistentContainer
}
