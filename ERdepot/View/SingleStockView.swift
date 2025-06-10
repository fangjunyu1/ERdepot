////
////  SingleStockView.swift
////  ERdepot
////
////  Created by 方君宇 on 2025/6/10.
////
//
//import SwiftUI
//import CoreData
//
//struct SingleStockView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//    @Environment(\.colorScheme) var color
//    @EnvironmentObject var appStorage: AppStorageManager
//    
//    
//    
//    var body: some View {
//        GeometryReader { geo in
//            let width = geo.frame(in: .local).width
//            let height = geo.frame(in: .local).height
//            VStack {
//                if stockMarkets.isEmpty {
//                    Image("noData")
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 200, height: 200)
//                    Spacer()
//                        .frame(height:20)
//                    Text("The data may not be available or the data source may not support the current network environment, resulting in a failure in obtaining data.")
//                        .font(.footnote)
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.center)
//                    
//                } else {
//                    // 股票指数
//                    HStack {
//                        let stockMarketNum = stockMarkets.first?.regularMarketPrice ?? 0
//                        if stockMarketNum == 0 {
//                            Text("--")
//                                .fontWeight(.bold)
//                        } else {
//                            Text("\(stockMarketNum.formattedWithTwoDecimalPlaces())")
//                                .fontWeight(.bold)
//                            HStack {
//                                Image(systemName: amplitude > 1 ?  "arrow.up" : "arrow.down")
//                                    .font(.caption2)
//                                Text("\(amplitude.formattedWithTwoDecimalPlaces())%")
//                                    .font(.caption2)
//                                    .fontWeight(.bold)
//                            }
//                            .foregroundColor(.white)
//                            .padding(.vertical,5)
//                            .padding(.horizontal,8)
//                            .background(amplitude > 1 ? Color(hex: "9D0000") : Color(hex: "01946B"))
//                            .cornerRadius(3)
//                        }
//                    }
//                    .font(.largeTitle)
//                    
//                    // 市场时间
//                    HStack {
//                        Text("Market time")
//                        Spacer()
//                        Text("\(formatter.string(from: stockMarkets.first?.updateTime ?? Date.distantPast))")
//                            .font(.footnote)
//                            .foregroundColor(.gray)
//                    }
//                    .padding(.horizontal,20)
//                    .frame(width: width * 0.85,height: 50)
//                    .background(color == .light ? Color(hex: "ECECEC") : Color(hex: "2f2f2f"))
//                    .transition(.move(edge: .top).combined(with: .opacity))
//                    .cornerRadius(10)
//                    
//                    Spacer().frame(height:10)
//                    
//                    // 今日最高价，今日最低价，前日收盘价
//                    VStack(spacing:0) {
//                        Group {
//                            // 今日最高价
//                            HStack {
//                                Text("Today's highest price")
//                                Spacer()
//                                let StockIndexDayHigh: Double = stockMarkets.first?.regularMarketDayHigh ?? 0.0
//                                Text("\(StockIndexDayHigh.formattedWithTwoDecimalPlaces())")
//                                    .font(.footnote)
//                                    .foregroundColor(.gray)
//                            }
//                            .frame(height: 50)
//                            
//                            Divider()
//                            
//                            // 今日最低价
//                            HStack {
//                                Text("Today's lowest price")
//                                Spacer()
//                                let StockIndexDayLow: Double = stockMarkets.first?.regularMarketDayLow ?? 0.0
//                                Text("\(StockIndexDayLow.formattedWithTwoDecimalPlaces())")
//                                    .font(.footnote)
//                                    .foregroundColor(.gray)
//                            }
//                            .frame(height: 50)
//                            
//                            Divider()
//                            
//                            // 前日收盘价
//                            HStack {
//                                Text("Previous day's closing price")
//                                Spacer()
//                                let StockIndexPrevious: Double = stockMarkets.first?.chartPreviousClose ?? 0.0
//                                Text("\(StockIndexPrevious.formattedWithTwoDecimalPlaces())")
//                                    .font(.footnote)
//                                    .foregroundColor(.gray)
//                            }
//                            .frame(height: 50)
//                        }
//                        .padding(.horizontal,20)
//                    }
//                    .frame(width: width * 0.85)
//                    .background(color == .light ? Color(hex: "ECECEC") : Color(hex: "2f2f2f"))
//                    .cornerRadius(10)
//                    
//                    Spacer().frame(height:10)
//                    
//                    // 过去一年最高价，过去一年最低价
//                    VStack(spacing:0) {
//                        Group {
//                            // 过去一年最高价
//                            HStack {
//                                Text("Past year's highest price")
//                                Spacer()
//                                let StockIndexYearHigh: Double = stockMarkets.first?.fiftyTwoWeekHigh ?? 0.0
//                                Text("\(StockIndexYearHigh.formattedWithTwoDecimalPlaces())")
//                                    .font(.footnote)
//                                    .foregroundColor(.gray)
//                            }
//                            .frame(height: 50)
//                            
//                            Divider()
//                            
//                            // 过去一年最低价
//                            HStack {
//                                Text("Past year's lowest price")
//                                Spacer()
//                                let StockIndexYearHigh: Double = stockMarkets.first?.fiftyTwoWeekLow ?? 0.0
//                                Text("\(StockIndexYearHigh.formattedWithTwoDecimalPlaces())")
//                                    .font(.footnote)
//                                    .foregroundColor(.gray)
//                            }
//                            .frame(height: 50)
//                        }
//                        .padding(.horizontal,20)
//                    }
//                    .frame(width: width * 0.85)
//                    .background(color == .light ? Color(hex: "ECECEC") : Color(hex: "2f2f2f"))
//                    .cornerRadius(10)
//                    
//                    Spacer().frame(height:10)
//                    
//                    // 交易所名称
//                    HStack {
//                        Text("Exchange name")
//                        Spacer()
//                        Text(LocalizedStringKey(stockMarkets.first?.fullExchangeName ?? "--"))
//                            .font(.footnote)
//                            .foregroundColor(.gray)
//                    }
//                    .padding(.horizontal,20)
//                    .frame(width: width * 0.85,height: 50)
//                    .background(color == .light ? Color(hex: "ECECEC") : Color(hex: "2f2f2f"))
//                    .cornerRadius(10)
//                    Spacer()
//                        .frame(height: 30)
//                    VStack {
//                        HStack {
//                            Text("Data source")
//                            Text("Yahoo Finance")
//                        }
//                        .foregroundColor(.gray)
//                        .font(.caption2)
//                        Spacer().frame(height: 5)
//                        HStack {
//                            Text("Update time")
//                            Text(appStorage.YahooLastUpdateDate,format: Date.FormatStyle.dateTime)
//                        }
//                    }
//                    .foregroundColor(.gray)
//                    .font(.caption2)
//                }
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//        }
//    }
//}
//
//#Preview {
//    SingleStockView(symbol: .constant("GSPC"))
//        .environmentObject(AppStorageManager.shared)
//        .environment(\.managedObjectContext, CoreDataPersistenceController.shared.context) // 加载 NSPersistentContainer
//        .environmentObject(YahooManager.shared)
//}
