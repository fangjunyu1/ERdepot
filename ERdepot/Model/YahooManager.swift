//
//  YahooGoldPriceManager.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/5/24.
//
import SwiftUI
import CoreData

class YahooManager: ObservableObject {
    static let shared = YahooManager()
    private let viewContext = CoreDataPersistenceController.shared.context
    private let backgroundContext = CoreDataPersistenceController.shared.backgroundContext
    
    private init() {
        print("YahooManager 初始化方法，所在线程：\(Thread.current)")
        
        let calendar = Calendar.current
        
        // 初始化调用 Yahoo 的同步方法
        if calendar.isDateInToday(AppStorageManager.shared.YahooLastUpdateDate) {
            print("今天已经完成 Yahoo 接口的更新，不再更新")
            return
        } else {
            print("调用 Yahoo 数据接口")
            fetchYahooData()
        }
        
        NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: nil,
            queue: .main
        ) {[weak self] notification in
            // 只对 backgroundContext 发出的保存通知进行合并
            print("进入 NotificationCenter 监听方法")
            guard let context = notification.object as? NSManagedObjectContext,
                  context != self?.viewContext else {
                print("当前上下文不是 NSManagedObjectContext 类型或者属于前台上下文，退出监听")
                return
            }
            print("尝试将后台上下文合并到前台上下文")
            self?.viewContext.perform {
                self?.viewContext.mergeChanges(fromContextDidSave: notification)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // Yahoo 数据接口，获取最近1个月的数据，按日分隔。
    private let YahooApiURLArray:[String:URL] = [
        // yahoo 黄金接口
        "Gold":URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/GC=F?interval=1d&range=1mo")!,
        // yahoo 标普 500 股票指数接口
        "GSPC":URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/%5EGSPC")!,
        // yahoo 纳斯达克 100 股票指数接口
        "NDX":URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/%5ENDX")!,
        // yahoo 道琼斯工业平均 股票指数接口
        "DJI":URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/%5EDJI")!,
        // yahoo 日经 225 股票指数接口
        "N225":URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/%5EN225")!,
        // yahoo 恒生指数 股票指数接口
        "HSI":URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/%5EHSI")!,
        // yahoo 英国富时 100 股票指数接口
        "FTSE":URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/%5EFTSE")!,
        // yahoo 德国 DAX 股票指数接口
        "GDAXI":URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/%5EGDAXI")!,
        // yahoo 法国 CAC 40 股票指数接口
        "FCHI":URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/%5EFCHI")!,
        // yahoo 上证指数 股票指数接口
        "SS":URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/000001.SS")!,
        // yahoo 深证成指 股票指数接口
        "SZ":URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/399001.SZ")!,
    ]
    
    /// 获取 Yahoo 黄金数据
    final func fetchYahooData() {
        print("进入到fetchYahooData方法，所在线程：\(Thread.current)")
        
        // 遍历 Yahoo数据数组 创建数据任务
        for (urlName,url) in YahooApiURLArray {
            print("进入到Yahoo数据数组，所在线程：\(Thread.current)")
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                print("进入到URLSession方法，所在线程\(Thread.current)")
                // 检查是否有错误
                if let error = error {
                    print("Yahoo \(urlName)，请求出错：\(error.localizedDescription)")
                    return
                }
                
                // 检查响应数据
                if let data = data {
                    print("进入到URLSession方法的data响应数据，所在线程：\(Thread.current)")
                    if let htmlString = String(data: data, encoding: .utf8),
                       htmlString.contains("<html") {
                        print("返回的是 HTML 页面，非 JSON：\n\(htmlString)")
                        return
                    } else {
                        print("成功获取响应 Yahoo 的数据")
                        // print("获取的数据为\(String(data: data, encoding: .utf8) ?? "")")
                    }
                    
                    // 将数据解析为字符串（例如 JSON）
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    self.backgroundContext.perform {
                        do {
                            print("使用JSONDecoder解码，所在线程:\(Thread.current)")
                            /// 解码获取的 Yahoo 数据
                            let goldData = try decoder.decode(YahooModel.self, from: data)
                            guard let goldDataFirst = goldData.chart.result.first!?.meta else {
                                print("\(urlName) 数据没有元素")
                                return
                            }
                            
                            /// 黄金、股票指数数据
                            // 查询 Core Data 中 Yahoo 的数据条件
                            let fetchRequest: NSFetchRequest<Yahoo> = Yahoo.fetchRequest()
                            // 设置 Yahoo 数据的过滤条件
                            fetchRequest.predicate = NSPredicate(format: "symbol == %@", urlName)
                            // 获取 Core Data 中 Yahoo 的数据
                            let results = try self.backgroundContext.fetch(fetchRequest)
                            // 如果 Core Data中没有数据
                            if let existing = results.first {
                                // 更新已存在记录
                                existing.symbol = urlName
                                existing.updateTime = goldDataFirst.updateTime
                                existing.fullExchangeName = goldDataFirst.fullExchangeName
                                existing.regularMarketPrice = goldDataFirst.regularMarketPrice
                                existing.fiftyTwoWeekHigh = goldDataFirst.fiftyTwoWeekHigh
                                existing.fiftyTwoWeekLow = goldDataFirst.fiftyTwoWeekLow
                                existing.regularMarketDayHigh = goldDataFirst.regularMarketDayHigh
                                existing.regularMarketDayLow = goldDataFirst.regularMarketDayLow
                                existing.chartPreviousClose = goldDataFirst.chartPreviousClose
                                // print("\(urlName),更新一条新的数据")
                            } else {
                                // 插入新记录
                                let newYahooGoldPrice = Yahoo(context: self.backgroundContext)
                                newYahooGoldPrice.symbol = urlName
                                newYahooGoldPrice.updateTime = goldDataFirst.updateTime
                                newYahooGoldPrice.fullExchangeName = goldDataFirst.fullExchangeName
                                newYahooGoldPrice.regularMarketPrice = goldDataFirst.regularMarketPrice
                                newYahooGoldPrice.fiftyTwoWeekHigh = goldDataFirst.fiftyTwoWeekHigh
                                newYahooGoldPrice.fiftyTwoWeekLow = goldDataFirst.fiftyTwoWeekLow
                                newYahooGoldPrice.regularMarketDayHigh = goldDataFirst.regularMarketDayHigh
                                newYahooGoldPrice.regularMarketDayLow = goldDataFirst.regularMarketDayLow
                                newYahooGoldPrice.chartPreviousClose = goldDataFirst.chartPreviousClose
                                // print("\(urlName),插入一条新的数据")
                            }
                            
                            print("保存插入的 \(urlName) 数据")
                            print("保存 Yahoo 数据（非图表数据），所在线程:\(Thread.current)")
                            try self.backgroundContext.save()
                            
                            /// 获取的 Yahoo 图表数据
                            guard let goldPointDataFirst = goldData.chart.result.first! else {
                                print("Gold数据没有元素")
                                return
                            }
                            
                            /// 黄金、股票指数（图表）数据
                            // 查询 Core Data 中 Yahoo 的数据条件
                            let fetchPointRequest: NSFetchRequest<YahooPoint> = YahooPoint.fetchRequest()
                            // 设置 Yahoo 数据的过滤条件
                            fetchPointRequest.predicate = NSPredicate(format: "symbol == %@", urlName)
                            
                            // 获取 Core Data 中 Yahoo 的（图表）数据
                            let pointResults = try self.backgroundContext.fetch(fetchPointRequest)
                            print("在\(urlName)中，共删除\(pointResults.count) 条历史数据")
                            
                            pointResults.forEach { self.backgroundContext.delete($0) }
                            
                            // 保存删除的数据
                            try self.backgroundContext.save()
                            
                            print("开始进入到 Core Data 图表插入代码")
                            
                            func safeDouble(_ value: Double?) -> Double {
                                guard let v = value, v.isFinite else {
                                    if let value = value {
                                                print("value:\(value) 不是正常数值（非有限数）")
                                            } else {
                                                print("value 为 nil")
                                            }
                                            return 0.0
                                }
                                // print("v:\(v)")
                                return v
                            }
                            
                            if let goldPoint = goldPointDataFirst.indicators.quote.first {
                                
                                let timestamps = goldPointDataFirst.timestamp
                                let closes = goldPoint.close
                                let highs = goldPoint.high
                                let lows = goldPoint.low
                                let opens = goldPoint.open
                                let volumes = goldPoint.volume
                                
//                                print("本次插入的数据为:\(goldPointDataFirst)")
//                                print("timestamps最大长度: \(timestamps.count)")
//                                print("opens最大长度: \(opens.count)")
//                                print("highs最大长度: \(highs.count)")
//                                print("lows最大长度: \(lows.count)")
//                                print("closes最大长度: \(closes.count)")
//                                print("volumes最大长度: \(volumes.count)")
                                
                                /// 获取 Yahoo 图表数据的条目
                                let count = min(
                                    timestamps.count,
                                    opens.count,
                                    highs.count,
                                    lows.count,
                                    closes.count,
                                    volumes.count
                                )
                                // 插入新记录
                                for i in 0..<count {
                                    // print("创建 YahooPoint 对象")
                                    let newYahooGoldPrice = YahooPoint(context: self.backgroundContext)
                                    // print("创建 YahooPoint 对象完成")
                                    // print("最新的一条数据，symbol:\(urlName),timestamp:\(goldPointDataFirst.timestamp[i]),close:\(goldPoint.close[i] ?? 0.0),hight:\(goldPoint.high[i] ?? 0.0),low:\(goldPoint.low[i] ?? 0.0),open:\(goldPoint.open[i] ?? 0.0),volume:\(goldPoint.volume[i] ?? 0.0)")
                                    /// print("创建 YahooPoint 对象,urlName:\(urlName)")
                                    newYahooGoldPrice.symbol = urlName
                                    newYahooGoldPrice.time = timestamps[i]
                                    newYahooGoldPrice.close = safeDouble(closes[i])
                                    newYahooGoldPrice.high = safeDouble(highs[i])
                                    newYahooGoldPrice.low = safeDouble(lows[i])
                                    newYahooGoldPrice.open = safeDouble(opens[i])
                                    newYahooGoldPrice.volume = safeDouble(volumes[i])
                                }
                                
                                print("保存 Yahoo 数据（图表数据），所在线程:\(Thread.current)")
                                try self.backgroundContext.save()
                                
                                let newResults = try self.backgroundContext.fetch(fetchPointRequest) // 再 fetch 一次
                                print("将最新的 Yahoo 图表数据插入 Core Data 中。")
                                print("当前 Yahoo 图表数据共有 \(newResults.count) 条数据")
                            }
                            
                            // 更新 Yahoo黄金 数据日期
                            DispatchQueue.main.async {
                                AppStorageManager.shared.YahooLastUpdateDate = Date()
                                print("Yahoo 更新日期:\(AppStorageManager.shared.YahooLastUpdateDate)")
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
                            print("Yahoo 解码失败: \(error)")
                        }
                    }
                } else {
                    print("获取数据失败")
                }
            }
            
            // 启动任务
            task.resume()
        }
    }
}
