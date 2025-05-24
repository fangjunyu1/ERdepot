//
//  YahooGoldPriceManager.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/5/24.
//
import SwiftUI
import CoreData

class YahooGoldPriceManager: ObservableObject {
    static let shared = YahooGoldPriceManager()
    private init() {
        print("进入 Yahoo黄金 方法")
        // 初始化调用 Yahoo黄金 的同步方法
//        let calendar = Calendar.current
//        if calendar.isDateInToday(AppStorageManager.shared.GoldlastUpdateDate) {
//            print("今天已经完成 Yahoo黄金 的更新，不再更新")
//            return
//        } else {
//            print("调用 Yahoo黄金 数据接口")
//            // 调用 Yahoo黄金 数据接口
//            fetchahooGoldPrice()
//            // 更新 Yahoo黄金 数据日期
//            AppStorageManager.shared.GoldlastUpdateDate = Date()
//            print("Yahoo黄金 更新日期:\(AppStorageManager.shared.CryptocurrencylastUpdateDate)")
//        }
        fetchahooGoldPrice()
    }
    
    // Yahoo黄金 接口，获取最近1个月的数据，按日分隔。
    private let apiURL = URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/GC=F?interval=1d&range=1mo")!
    
    func fetchahooGoldPrice() {
        let context = CoreDataPersistenceController.shared.context
        // 创建数据任务
        let task = URLSession.shared.dataTask(with: apiURL) { data, response, error in
            
            // 检查是否有错误
            if let error = error {
                print("Yahoo黄金，请求出错：\(error.localizedDescription)")
                return
            }
            
            // 检查响应数据
            if let data = data {
//                if let jsonString = String(data: data, encoding: .utf8) {
//                    print("原始 JSON 字符串: \(jsonString)")
//                }
                if let htmlString = String(data: data, encoding: .utf8),
                   htmlString.contains("<html") {
                    print("返回的是 HTML 页面，非 JSON：\n\(htmlString)")
                    return
                }
                
                // 将数据解析为字符串（例如 JSON）
                var decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                do {
                    let goldData = try decoder.decode(YahooGoldPriceModel.self, from: data)
                    print("获取Gold数据成功！")
                    guard let goldDataFirst = goldData.chart.result.first!?.meta else {
                        print("Gold数据没有元素")
                        return
                    }
                    
                    // 查询 Core Data 中 Yahoo 黄金的数据条件
                    let fetchRequest: NSFetchRequest<YahooGoldPrice> = YahooGoldPrice.fetchRequest()
                    // 获取 Core Data 中 Yahoo 黄金的数据
                    let results = try context.fetch(fetchRequest)
                    // 如果 Core Data中没有数据
                    if let existing = results.first {
                        // 更新已存在记录
                        existing.updateTime = goldDataFirst.updateTime
                        existing.fullExchangeName = goldDataFirst.fullExchangeName
                        existing.regularMarketPrice = goldDataFirst.regularMarketPrice
                        existing.fiftyTwoWeekHigh = goldDataFirst.fiftyTwoWeekHigh
                        existing.fiftyTwoWeekLow = goldDataFirst.fiftyTwoWeekLow
                        existing.regularMarketDayHigh = goldDataFirst.regularMarketDayHigh
                        existing.regularMarketDayLow = goldDataFirst.regularMarketDayLow
                        existing.chartPreviousClose = goldDataFirst.chartPreviousClose
                    } else {
                        // 插入新记录
                        let newYahooGoldPrice = YahooGoldPrice(context: context)
                        newYahooGoldPrice.updateTime = goldDataFirst.updateTime
                        newYahooGoldPrice.fullExchangeName = goldDataFirst.fullExchangeName
                        newYahooGoldPrice.regularMarketPrice = goldDataFirst.regularMarketPrice
                        newYahooGoldPrice.fiftyTwoWeekHigh = goldDataFirst.fiftyTwoWeekHigh
                        newYahooGoldPrice.fiftyTwoWeekLow = goldDataFirst.fiftyTwoWeekLow
                        newYahooGoldPrice.regularMarketDayHigh = goldDataFirst.regularMarketDayHigh
                        newYahooGoldPrice.regularMarketDayLow = goldDataFirst.regularMarketDayLow
                        newYahooGoldPrice.chartPreviousClose = goldDataFirst.chartPreviousClose
                    }
                    
                } catch DecodingError.keyNotFound(let key, let context) {
                    print("---1---")
                    print("Key '\(key)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch DecodingError.typeMismatch(let type, let context) {
                    print("---2---")
                    print("Type '\(type)' mismatch:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch DecodingError.valueNotFound(let type, let context) {
                    print("---3---")
                    print("Value '\(type)' not found:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch DecodingError.dataCorrupted(let context) {
                    print("---4---")
                    print("Data corrupted:", context.debugDescription)
                    print("codingPath:", context.codingPath)
                } catch {
                    print("Yahoo黄金解码失败: \(error)")
                }
            } else {
                print("获取数据失败")
            }
        }
        
        // 启动任务
        task.resume()
    }
    
}
