//
//  ConversionView.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/4/6.
//

import SwiftUI
import CoreData
struct ConversionView: View {
    @Environment(\.colorScheme) var color
    @EnvironmentObject var appStorage: AppStorageManager
    @Binding var isShowConversion: Bool
    
    // 输入金额
    @State private var inputAmounts: [String: String] = [:]
    
    // 获取 Core Data 上下文
    @Environment(\.managedObjectContext) private var viewContext
    
    // 多个输入框的聚集
    @FocusState private var focusedField: CurrencyField?
    enum CurrencyField: Hashable {
        case symbol(String)
    }
    
    // 转换动画
    @State private var transitionAnimation = false
    // 转换动画角度
    @State private var transformAnimationAngle = 0.0
    
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
    
    func handleInputChange(for symbol: String, newValue: String) {
        print("计算货币:\(symbol)")
        var cleanedValue = newValue.replacingOccurrences(of: ",", with: "")  // 移除千分位分隔符
        
        // 新增或更新
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        print("cleanedValue:\(cleanedValue)")
        if let number = formatter.number(from: cleanedValue) {
            print("number计算成功")
            let value = number.doubleValue
            
        } else if cleanedValue.isEmpty {
            
        } else {
            print("number计算失败")
        }
        
        
        if let doubleValue = Double(cleanedValue) {
            print("string计算成功")
            let string = formatter.string(from: NSNumber(value:doubleValue))
            inputAmounts[symbol] = string
            print("string:\(string ?? "")")
        } else if cleanedValue.isEmpty {
            inputAmounts[symbol] = "0.00"
        }else {
            print("string计算失败")
        }
        
        print("Core Datab保存")
        try? viewContext.save()
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
                            isShowConversion = false
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
                            Text("Conversion")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer().frame(height: 10)
                            Text("Calculate exchange rates between currencies.")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        VStack {
                            Image("exchange")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70)
                        }
                        
                    }
                    Spacer().frame(height: 20)
                    ForEach(Array(appStorage.convertForeignCurrency.enumerated()), id: \.1) { index,symbol in
                        GeometryReader { itemGeo in
                            let midY = itemGeo.frame(in: .global).midY
                            let screenHeight = UIScreen.main.bounds.height
                            let centerY = screenHeight / 2 - 80
                             let distance = abs(midY - centerY)
                            let scale = max(0.8, 1.1 - (distance / screenHeight)) // 自定义缩放算法
                            HStack {
                                Image("\(symbol)")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 110, height: 70)
                                    .clipped()
                                Spacer().frame(width: 20)
                                VStack(alignment: .leading) {
                                    Text("\(symbol)")
                                        .foregroundColor(.gray)
                                    Spacer().frame(height: 4)
                                    Text(LocalizedStringKey(symbol))
                                }
                                .font(.footnote)
                                Spacer()
                                TextField("0.0", text: Binding(get: {
                                    inputAmounts[symbol] ?? ""
                                }, set: { newValue in
                                    inputAmounts[symbol] = newValue
                                }))
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
                            .padding(.trailing,20)
                            .background(color == .light ? Color(hex: "ECECEC") : Color(hex: "2f2f2f"))
                            .cornerRadius(5)
                            .scaleEffect(scale)
                        }
                        .frame(width: width * 0.85,height: 70)
                        
                        Spacer().frame(height: 20)
                        
                        // 在第一个货币下面插入转换按钮
                        if index == 0 {
                            HStack {
                                Spacer()
                                Button(action: {
                                    // 第一个货币和第二个货币转换
                                    var tmpCurrency = appStorage.convertForeignCurrency[0]
                                    appStorage.convertForeignCurrency[0] = appStorage.convertForeignCurrency[1]
                                    appStorage.convertForeignCurrency[1] = tmpCurrency
                                    
                                    
                                    // 调用转换动画
                                    withAnimation(.easeInOut(duration: 1)) {
                                        transformAnimationAngle = 360
                                    }
                                    // 动画完成后重置为 0（延迟和动画时长一致）
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        transformAnimationAngle = 0
                                    }
                                    
                                }, label: {
                                    Circle()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(Color(hex: "262CCC"))
                                        .overlay {
                                            if #available(iOS 16.0, *) {
                                                Image(systemName: "arrow.down.left.arrow.up.right")
                                                    .fontWeight(.bold)
                                                    .font(.title2)
                                                    .foregroundColor(.white)
                                                    .rotationEffect(Angle(degrees: transformAnimationAngle))
                                            } else {
                                                // Fallback on earlier versions
                                                Image(systemName: "arrow.down.left.arrow.up.right")
                                                    .font(.title2)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                })
                                Spacer()
                            }
                        }
                        
                    }
                    Spacer().frame(height: 100)
                }
                .frame(width: width * 0.85)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onTapGesture {
            // 点击视图，取消文本库选中
            focusedField = nil
        }
        
    }
}

#Preview {
    ConversionView(isShowConversion: .constant(true))
        .environmentObject(AppStorageManager.shared)
}
