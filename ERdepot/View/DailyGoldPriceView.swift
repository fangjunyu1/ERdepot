//
//  DailyGoldPrice.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/5/11.
//

import SwiftUI
import CoreData

struct DailyGoldPriceView: View {
    // 通过 @Environment 读取 viewContext
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) var color
    @EnvironmentObject var appStorage: AppStorageManager
    @Binding var bindingSheet: Bool
    // 查询 Core Data 中 Yahoo 黄金的数据条件
    
    @FetchRequest(
        fetchRequest: {
            let request = NSFetchRequest<Yahoo>(entityName: "Yahoo")
            // 筛选 Yahoo 中黄金的数据
            request.predicate = NSPredicate(format: "symbol == %@", "Gold")
            request.sortDescriptors = [NSSortDescriptor(key: "updateTime", ascending: false)]
            return request
        }()
    ) var goldPrices: FetchedResults<Yahoo>
    
    // 汇率字典
    @State private var rateDict: [String:Double] = [:]
    // 获取最新的汇率数据
    func convertGoldPrice(_ num: Double) -> Double {
        let goldPrice = num
        if appStorage.GoldPriceUnit == "per gram" {
            return goldPrice / 31.1035 / (rateDict["USD"] ?? 1) * (rateDict[appStorage.localCurrency] ?? 1)
        } else if appStorage.GoldPriceUnit == "per kilogram" {
            return goldPrice / 31103.5 / (rateDict["USD"] ?? 1) * (rateDict[appStorage.localCurrency] ?? 1)
        } else if appStorage.GoldPriceUnit == "per ounce" {
            return goldPrice / (rateDict["USD"] ?? 1) * (rateDict[appStorage.localCurrency] ?? 1)
        } else if appStorage.GoldPriceUnit == "per tola" {
            return goldPrice / 2.6675 / (rateDict["USD"] ?? 1) * (rateDict[appStorage.localCurrency] ?? 1)
        } else {
            return goldPrice
        }
    }
    
    let calendar = Calendar.current
    
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai") // 设置为中国时区
        return formatter
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
    
    var amplitude: Double {
        let current = goldPrices.first?.regularMarketPrice ?? 0
        let previous = goldPrices.first?.chartPreviousClose ?? 0
        let change = (current - previous) / previous * 100
        return change.isFinite ? change : 0
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
                            bindingSheet = false
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
                    // 每日金价
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Daily gold price")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer().frame(height: 10)
                            Text("Gold futures")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        VStack {
                            Image("gold")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70)
                        }
                    }
                    Spacer()
                        .frame(height: 20)
                    if goldPrices.isEmpty {
                        Image("noData")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                        Spacer()
                            .frame(height:20)
                        Text("The data may not be available or the data source may not support the current network environment, resulting in a failure in obtaining data.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Spacer().frame(height:20)
                        
                        // 隐藏“显示历史数据”按钮
//                        Button(action: {
//                            
//                        },label: {
//                            Text("Display historical data")
//                                .font(.subheadline)
//                                .foregroundColor(.white)
//                                .padding(.vertical,10)
//                                .padding(.horizontal,14)
//                                .background(Color(hex: "373737"))
//                                .cornerRadius(3)
//                        })
                    } else {
                        // 每克黄金价格
                        VStack(alignment: .leading) {
                            Text(LocalizedStringKey(appStorage.GoldPriceUnit))
                                .foregroundColor(.gray)
                                .font(.caption2)
                            Spacer().frame(height: 5)
                            HStack {
                                Text("\(currencySymbols[appStorage.localCurrency] ?? "$")")
                                    .fontWeight(.medium)
                                let convertedPrice = convertGoldPrice(goldPrices.first?.regularMarketPrice ?? 0)
                                if convertedPrice == 0 {
                                    Text("--")
                                        .fontWeight(.bold)
                                } else {
                                    Text("\(convertedPrice.formattedWithTwoDecimalPlaces())")
                                        .fontWeight(.bold)
                                }
                                HStack {
                                    Image(systemName: amplitude > 1 ?  "arrow.up" : "arrow.down")
                                        .font(.caption2)
                                    Text("\(amplitude.formattedWithTwoDecimalPlaces())%")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .padding(.vertical,5)
                                .padding(.horizontal,8)
                                .background(amplitude > 1 ? Color(hex: "9D0000") : Color(hex: "01946B"))
                                .cornerRadius(3)
                            }
                            .font(.largeTitle)
                        }
                        Spacer()
                            .frame(height: 20)
                        
                        // 市场时间
                        HStack {
                            Text("Market time")
                            Spacer()
                            Text("\(formatter.string(from: goldPrices.first?.updateTime ?? Date.distantPast))")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal,20)
                        .frame(width: width * 0.85,height: 50)
                        .background(color == .light ? Color(hex: "ECECEC") : Color(hex: "2f2f2f"))
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .cornerRadius(10)
                        
                        Spacer().frame(height:10)
                        
                        // 今日最高价，今日最低价，前日收盘价
                        VStack(spacing:0) {
                            Group {
                                // 今日最高价
                                HStack {
                                    Text("Today's highest price")
                                    Spacer()
                                    let convertedPriceDayHigh = convertGoldPrice(goldPrices.first?.regularMarketDayHigh ?? 0.0)
                                    HStack(spacing:3) {
                                        Text("\(currencySymbols[appStorage.localCurrency] ?? "$")")
                                        Text("\(convertedPriceDayHigh.formattedWithTwoDecimalPlaces())")
                                    }
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                }
                                .frame(height: 50)
                                
                                Divider()
                                
                                // 今日最低价
                                HStack {
                                    Text("Today's lowest price")
                                    Spacer()
                                    let convertedPriceDayLow = convertGoldPrice(goldPrices.first?.regularMarketDayLow ?? 0.0)
                                    HStack(spacing:3) {
                                        Text("\(currencySymbols[appStorage.localCurrency] ?? "$")")
                                        Text("\(convertedPriceDayLow.formattedWithTwoDecimalPlaces())")
                                    }
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                }
                                .frame(height: 50)
                                
                                Divider()
                                
                                // 前日收盘价
                                HStack {
                                    Text("Previous day's closing price")
                                    Spacer()
                                    let convertedPricePrevious = convertGoldPrice(goldPrices.first?.chartPreviousClose ?? 0.0)
                                    HStack(spacing:3) {
                                        Text("\(currencySymbols[appStorage.localCurrency] ?? "$")")
                                        Text("\(convertedPricePrevious.formattedWithTwoDecimalPlaces())")
                                    }
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                }
                                .frame(height: 50)
                            }
                            .padding(.horizontal,20)
                        }
                        .frame(width: width * 0.85)
                        .background(color == .light ? Color(hex: "ECECEC") : Color(hex: "2f2f2f"))
                        .cornerRadius(10)
                        
                        Spacer().frame(height:10)
                        
                        // 过去一年最高价，过去一年最低价
                        VStack(spacing:0) {
                            Group {
                                // 过去一年最高价
                                HStack {
                                    Text("Past year's highest price")
                                    Spacer()
                                    let convertedPriceYearHigh = convertGoldPrice(goldPrices.first?.fiftyTwoWeekHigh ?? 0.0)
                                    HStack(spacing:3) {
                                        Text("\(currencySymbols[appStorage.localCurrency] ?? "$")")
                                        Text("\(convertedPriceYearHigh.formattedWithTwoDecimalPlaces())")
                                    }
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                }
                                .frame(height: 50)
                                
                                Divider()
                                
                                // 过去一年最低价
                                HStack {
                                    Text("Past year's lowest price")
                                    Spacer()
                                    let convertedPriceYearLow = convertGoldPrice(goldPrices.first?.fiftyTwoWeekLow ?? 0.0)
                                    HStack(spacing:3) {
                                        Text("\(currencySymbols[appStorage.localCurrency] ?? "$")")
                                        Text("\(convertedPriceYearLow.formattedWithTwoDecimalPlaces())")
                                    }
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                }
                                .frame(height: 50)
                            }
                            .padding(.horizontal,20)
                        }
                        .frame(width: width * 0.85)
                        .background(color == .light ? Color(hex: "ECECEC") : Color(hex: "2f2f2f"))
                        .cornerRadius(10)
                        
                        Spacer().frame(height:10)
                        
                        // 交易所名称
                        HStack {
                            Text("Exchange name")
                            Spacer()
                            Text(LocalizedStringKey(goldPrices.first?.fullExchangeName ?? "--"))
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal,20)
                        .frame(width: width * 0.85,height: 50)
                        .background(color == .light ? Color(hex: "ECECEC") : Color(hex: "2f2f2f"))
                        .cornerRadius(10)
                        Spacer()
                            .frame(height: 30)
                        VStack {
                            HStack {
                                Text("Data sources")
                                Text("Yahoo Finance")
                            }
                            .foregroundColor(.gray)
                            .font(.caption2)
                            Spacer().frame(height: 5)
                            HStack {
                                Text("Update time")
                                Text(appStorage.YahooLastUpdateDate,format: Date.FormatStyle.dateTime)
                            }
                        }
                        .foregroundColor(.gray)
                        .font(.caption2)
                    }
                    
                    Spacer()
                        .frame(height: 20)
                }
                .frame(width: width * 0.85)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            let latestRates = fetchLatestRates()
            rateDict = Dictionary(uniqueKeysWithValues: latestRates.map { ($0.symbol ?? "", $0.rate) })
        }
    }
}


#Preview {
    // 清理必须放在 return 之前！
    //        if let bundleID = Bundle.main.bundleIdentifier {
    //            UserDefaults.standard.removePersistentDomain(forName: bundleID)
    //        }
    @StateObject var yahooGManager = YahooManager.shared
    DailyGoldPriceView(bindingSheet: .constant(true))
        .environmentObject(AppStorageManager.shared)
        .environment(\.managedObjectContext, CoreDataPersistenceController.shared.context) // 加载 NSPersistentContainer
        .environmentObject(yahooGManager)
}
