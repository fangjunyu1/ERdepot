//
//  ForeignCurrencyView.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/4/5.
//

import SwiftUI
import CoreData

struct CurrencyInput: Identifiable {
    let id: String   // symbol
    var value: String
}

struct ForeignCurrencyView: View {
    @Environment(\.colorScheme) var color
    @EnvironmentObject var appStorage: AppStorageManager
    @Binding var isShowForeignCurrency: Bool
    @State private var textField: String = ""
    // 输入金额
    @State private var inputAmounts: [String: String] = [:]
    // 获取 Core Data 上下文
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        fetchRequest: {
            let request = NSFetchRequest<UserForeignCurrency>(entityName: "UserForeignCurrency")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \UserForeignCurrency.symbol, ascending: true)]
            return request
        }()
    ) var userForeignCurrencies: FetchedResults<UserForeignCurrency>
    
    @FocusState private var focusedField: CurrencyField?
    
    // CurrencyInput数组
    @State private var inputs: [CurrencyInput] = []
    
    enum CurrencyField: Hashable {
        case symbol(String)
    }
    
    func handleInputChange(for symbol: String, newValue: String) {
        
        // 修改外币储蓄后，重新计算历史最高点
        appStorage.reCountingHistoricalHighs = true
        
        print("计算货币:\(symbol)")
        let cleanedValue = newValue.replacingOccurrences(of: ",", with: "")  // 移除千分位分隔符
        let existing = userForeignCurrencies.first(where: { $0.symbol == symbol })
        //
        // 删除
        if newValue.isEmpty {
            if let existing = existing {
                viewContext.delete(existing)
                try? viewContext.save()
            }
            return
        }
        
        // 新增或更新
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        if let number = formatter.number(from: cleanedValue) {
            print("number计算成功")
            let value = number.doubleValue
            if let existing = existing {
                // 修改
                existing.amount = value
            } else {
                // 新增
                let newCurrency = UserForeignCurrency(context: viewContext)
                newCurrency.symbol = symbol
                newCurrency.amount = value
            }
        } else {
            print("number计算失败")
        }
        
        
        if let doubleValue = Double(cleanedValue) {
            print("string计算成功")
            let string = formatter.string(from: NSNumber(value:doubleValue))
            inputAmounts[symbol] = string
            print("string:\(string ?? "")")
        }
        
        try? viewContext.save()
    }
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.frame(in: .local).width * 0.95
            let height = geo.frame(in: .local).height
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    Spacer()
                        .frame(height: 30)
                    HStack {
                        // 返回箭头
                        Button(action: {
                            isShowForeignCurrency = false
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
                    // 外币顶部内容
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Foreign currency")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer().frame(height: 10)
                            Text("Manage your foreign currency savings.")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        VStack {
                            Image("dollar")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70)
                        }
                    }
                    Spacer()
                        .frame(height: 20)
                    // 显示已有的外币记录
                    ForEach(userForeignCurrencies,id:\.self) { currency in
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
                            TextField("0.0", text: Binding(get: {
                                inputAmounts[currency.symbol ?? ""] ?? ""
                            }, set: { newValue in
                                inputAmounts[currency.symbol ?? ""] = newValue
                            }))
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
                        .padding(.horizontal,20)
                        .frame(width: width * 0.85,height: 50)
                        .background(color == .light ? Color(hex: "ECECEC") : Color(hex: "2f2f2f"))
                        .cornerRadius(10)
                        .transition(.move(edge: .bottom).combined(with: .opacity)) // 添加过渡
                        Spacer()
                            .frame(height: 10)
                    }
                    .animation(.easeInOut, value: userForeignCurrencies.count) // 对列表数量变化做动画
                    // 当 Core Data 有数据，添加与其他列表之间的间隔。
                    if !userForeignCurrencies.isEmpty {
                        Spacer().frame(height: 20)
                    }
                    // 其他
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Others")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer().frame(height: 10)
                        }
                        Spacer()
                    }
                    // 除已有外币意外的所有外币
                    ForEach(appStorage.listOfSupportedCurrencies, id: \.self) { currency in
                        if userForeignCurrencies.first(where: { $0.symbol == currency }) == nil {
                            // 国旗列表
                            HStack {
                                Image("\(currency)")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 36)
                                    .cornerRadius(10)
                                Spacer().frame(width: 20)
                                VStack(alignment: .leading) {
                                    Text(verbatim:"\(currency)")
                                        .foregroundColor(.gray)
                                    Spacer().frame(height: 4)
                                    Text(LocalizedStringKey(currency))
                                }
                                .font(.caption2)
                                Spacer()
                                TextField("0.0", text: Binding(get: {
                                    inputAmounts[currency] ?? ""
                                }, set: { newValue in
                                    inputAmounts[currency] = newValue
                                }))
                                .keyboardType(.decimalPad) // 数字小数点键盘
                                .focused($focusedField, equals: .symbol(currency)) // 添加这一行
                                .multilineTextAlignment(.trailing)
                                .padding(.leading,10)
                                .onChange(of: focusedField) { newFocus in
                                    // 当失去焦点，处理文本框关于 CoreData 方法
                                    if newFocus != .symbol(currency) {
                                        handleInputChange(for: currency, newValue: inputAmounts[currency] ?? "")
                                    }
                                }
                            }
                            .padding(.horizontal,20)
                            .frame(width: width * 0.85,height: 50)
                            .background(color == .light ? Color(hex: "ECECEC") : Color(hex: "2f2f2f"))
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .cornerRadius(10)
                            Spacer()
                                .frame(height: 10)
                        }
                    }
                    .animation(.easeInOut, value: userForeignCurrencies.count) // 对列表数量变化做动画
                    Spacer()
                        .frame(height: 20)
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
                    inputAmounts[symbol] =  formatter.string(from: NSNumber(value: currency.amount)) ?? ""
                }
            }
        }
    }
}

#Preview {
    ForeignCurrencyView(isShowForeignCurrency: .constant(true))
        .environmentObject(AppStorageManager.shared)
        .environment(\.managedObjectContext, CoreDataPersistenceController.shared.context) // 加载 NSPersistentContainer
}
