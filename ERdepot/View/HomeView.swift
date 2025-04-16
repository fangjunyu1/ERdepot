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
    @State private var selectedTime: Int = 0
    @State private var isShowForeignCurrency = false
    @State private var isShowConversion = false
    @State private var isShowStatistics = false
    @State private var isShowChangeCurrency = false
    @State private var isShowSet = false
    @State private var isShowProfit = false
    let timeRange: [String] = ["1 Week","1 Month","3 Months","6 Months", "1 Year","5 Years","10 Years","All"]
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd"
        return formatter
    }()
    
    
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
        let rateDict = Dictionary(uniqueKeysWithValues: latestRates.map { ($0.symbol ?? "", $0.rate) })
        
        // 计算所有外币的金额
        var total = 0.0
        for userCurrency in userForeignCurrencies {
            if let symbol = userCurrency.symbol, let rate = rateDict[symbol],let localCurrency = rateDict[appStorage.localCurrency] {
                total += userCurrency.amount / rate * localCurrency
            } else {
                print("计算出问题了")
            }
        }
        
        // 将 totalAmount 拆分为整数部分和小数部分
        let integerPart = Int(total)
        let decimalPart = total - Double(integerPart)
        
        return (integerPart,decimalPart)
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
                                            Text(LocalizedStringKey(timeRange[time]))
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                                .padding(.vertical,8)
                                                .padding(.horizontal,12)
                                                .foregroundColor(time == selectedTime ? .white : color == .light ? .black : Color(hex: "eeeeee"))
                                                .background(time == selectedTime ? Color(hex: "5D5D5D") : color == .light ? Color(hex: "FFFFFF") : Color(hex: "999999"))
                                                .cornerRadius(10)
                                        })
                                        .disabled(time == selectedTime)
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
                                    Text("Update time") + Text(":") +
                                    Text(formatter.string(from: exchangeRate.latestDate ?? Date(timeIntervalSince1970: 1743696000)))  // 显示格式化后的日期
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
                    .sheet(isPresented: $isShowProfit) {
                        ProfitView(isShowProfit: $isShowProfit)
                    }
                }
                .refreshable {
                    // 调用下载方法
                    exchangeRate.downloadExchangeRates()
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
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppStorageManager.shared)
        .environmentObject(ExchangeRate.shared)
        .environmentObject(IAPManager.shared)
        .environment(\.managedObjectContext, CoreDataPersistenceController.shared.context) // 加载 NSPersistentContainer
}
