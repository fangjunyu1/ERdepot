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
    
    // 输入金额
    @State private var inputAmounts: [String: String] = [:]
    
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
                    ForEach(userForeignCurrencies,id:\.self) { currency in
                        // 当前外币和购买金额
                        VStack {
                            HStack {
                                Image(currency.symbol ?? "")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 36)
                                    .cornerRadius(10)
                                Spacer().frame(width: 20)
                                VStack(alignment: .leading) {
                                    Text("\(currency.symbol ?? "")")
                                        .foregroundColor(.gray)
                                    Spacer().frame(height: 4)
                                    Text(LocalizedStringKey(currency.symbol ?? ""))
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
                            .zIndex(1)
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
                                    inputAmounts[currency.symbol ?? ""] ?? ""
                                }, set: { newValue in
                                    inputAmounts[currency.symbol ?? ""] = newValue
                                }))
                                .foregroundColor(.white)
                                .keyboardType(.decimalPad) // 数字小数点键盘
                                .focused($focusedField, equals: .symbol(currency.symbol ?? "")) // 添加这一行
                                .multilineTextAlignment(.trailing)
                                .padding(.leading,10)
                                .onChange(of: focusedField) { newFocus in
                                    // 当失去焦点，处理文本框关于 CoreData 方法
                                    if newFocus != .symbol(currency.symbol ?? "") {
                                        handleInputChange(for: currency.symbol ?? "", newValue: inputAmounts[currency.symbol ?? ""] ?? "")
                                    }
                                }
                            }
                            .padding(.top,5)
                            .padding(.horizontal,10)
                            .frame(width: width * 0.75,height: 55)
                            .background(Color(hex: "6C6C6C"))
                            .cornerRadius(10)
                            .offset(y: -15)
                            .zIndex(0)
                        }
                        Spacer()
                            .frame(height: 10)
                    }
                    Spacer().frame(height: 50)
                    Text("Below is the cost of purchasing foreign currency. You need to enter the cost to calculate the profit.")
                        .foregroundColor(.gray)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
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
        }
    }
}

#Preview {
    ProfitView(isShowProfit: .constant(true))
        .environmentObject(AppStorageManager.shared)
        .environment(\.managedObjectContext, CoreDataPersistenceController.shared.context) // 加载 NSPersistentContainer
}
