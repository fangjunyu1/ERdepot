//
//  StockIndex.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/5/11.
//

import SwiftUI
import CoreData

struct StockIndexView: View {
    // 通过 @Environment 读取 viewContext
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) var color
    @EnvironmentObject var appStorage: AppStorageManager
    @Binding var bindingSheet: Bool
    
    // 当前股市指数
    @State private var stockMarket:stockMarketEnum = .GSPC {
        didSet {
            print("修改股票指数列表，当前股票指数列表为：\(oldValue)")
            fetchData()
        }
    }
    // 股票指数列表
    //    var stockMarketList:[String:String] = [
    //        "GSPC":"S&P 500",
    //        "NDX":"Nasdaq 100",
    //        "DJI":"Dow Jones Industrial Average",
    //        "N225":"Nikkei 225",
    //        "HSI":"Hang Seng Index",
    //        "FTSE":"FTSE 100",
    //        "GDAXI":"DAX",
    //        "FCHI":"CAC 40",
    //        "SS":"Shanghai Composite Index",
    //        "SZ":"Shenzhen Component Index"
    //    ]
    
    @State private var stockMarkets: [Yahoo] = []
    
    let calendar = Calendar.current
    
    var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Shanghai") // 设置为中国时区
        return formatter
    }
    
    var amplitude: Double {
        let current = stockMarkets.first?.regularMarketPrice ?? 0
        let previous = stockMarkets.first?.chartPreviousClose ?? 0
        let change = (current - previous) / previous * 100
        return change.isFinite ? change : 0
    }
    
    func fetchData() {
        let request: NSFetchRequest<Yahoo> = Yahoo.fetchRequest()
        request.predicate = NSPredicate(format: "symbol == %@", stockMarket.caseName)
        request.sortDescriptors = [NSSortDescriptor(key: "updateTime", ascending: false)]
        do {
            stockMarkets = try viewContext.fetch(request)
        } catch {
            print("❌ Fetch failed: \(error)")
        }
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
                    // 股市指数
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Stock index")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer().frame(height: 14)
                            Menu {
                                ForEach(stockMarketEnum.allCases.filter{ $0 != stockMarket}) { stock in
                                    Button(LocalizedStringKey(stock.rawValue)) {
                                        stockMarket = stock
                                    }
                                }
                                
                            } label: {
                                Text(LocalizedStringKey(stockMarket.rawValue))
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.vertical,5)
                                    .padding(.horizontal,14)
                                    .background(Color(hex: "333333"))
                                    .cornerRadius(4)
                            }
                        }
                        Spacer()
                        VStack {
                            Image("stock")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    
                    VStack {
                        if stockMarkets.isEmpty {
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
                            
                        } else {
                            // 股票指数
                            HStack {
                                let stockMarketNum = stockMarkets.first?.regularMarketPrice ?? 0
                                if stockMarketNum == 0 {
                                    Text("--")
                                        .fontWeight(.bold)
                                } else {
                                    Text("\(stockMarketNum.formattedWithTwoDecimalPlaces())")
                                        .fontWeight(.bold)
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
                            }
                            .font(.largeTitle)
                            
                            // 市场时间
                            HStack {
                                Text("Market time")
                                Spacer()
                                Text("\(formatter.string(from: stockMarkets.first?.updateTime ?? Date.distantPast))")
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
                                        let StockIndexDayHigh: Double = stockMarkets.first?.regularMarketDayHigh ?? 0.0
                                        Text("\(StockIndexDayHigh.formattedWithTwoDecimalPlaces())")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(height: 50)
                                    
                                    Divider()
                                    
                                    // 今日最低价
                                    HStack {
                                        Text("Today's lowest price")
                                        Spacer()
                                        let StockIndexDayLow: Double = stockMarkets.first?.regularMarketDayLow ?? 0.0
                                        Text("\(StockIndexDayLow.formattedWithTwoDecimalPlaces())")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(height: 50)
                                    
                                    Divider()
                                    
                                    // 前日收盘价
                                    HStack {
                                        Text("Previous day's closing price")
                                        Spacer()
                                        let StockIndexPrevious: Double = stockMarkets.first?.chartPreviousClose ?? 0.0
                                        Text("\(StockIndexPrevious.formattedWithTwoDecimalPlaces())")
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
                                        let StockIndexYearHigh: Double = stockMarkets.first?.fiftyTwoWeekHigh ?? 0.0
                                        Text("\(StockIndexYearHigh.formattedWithTwoDecimalPlaces())")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(height: 50)
                                    
                                    Divider()
                                    
                                    // 过去一年最低价
                                    HStack {
                                        Text("Past year's lowest price")
                                        Spacer()
                                        let StockIndexYearHigh: Double = stockMarkets.first?.fiftyTwoWeekLow ?? 0.0
                                        Text("\(StockIndexYearHigh.formattedWithTwoDecimalPlaces())")
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
                                Text(LocalizedStringKey(stockMarkets.first?.fullExchangeName ?? "--"))
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
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear(perform: fetchData)
                }
                .frame(width: width * 0.9)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    stockMarket = appStorage.stockMarket
                }
            }
        }
    }
}

#Preview {
    StockIndexView(bindingSheet: .constant(true))
        .environmentObject(AppStorageManager.shared)
        .environment(\.managedObjectContext, CoreDataPersistenceController.shared.context) // 加载 NSPersistentContainer
        .environmentObject(YahooManager.shared)
}
