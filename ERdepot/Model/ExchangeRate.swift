//
//  ExchangeRate.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/4/6.
//

import Foundation
import Zip
import CoreData

class ExchangeRate :ObservableObject {
    // 下载文件的URL
    static let shared = ExchangeRate()
    private let fileURL = URL(string: "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.zip")!
    
    // 创建 NSPersistentContainer
    private var container: NSPersistentContainer
    private var context: NSManagedObjectContext
    
    private let fetchRequest: NSFetchRequest<Eurofxrefhist> = Eurofxrefhist.fetchRequest()
    // 初始化方法
    init() {
        // 创建并加载 NSPersistentContainer
        container = NSPersistentContainer(name: "ExchangeRateDataModel")
        
        // 加载持久化存储
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // 获取 Core Data 上下文
        context = container.viewContext
    }
    
    func downloadExchangeRates() {
        print("进入下载方法 downloadExchangeRates")
        let task = URLSession.shared.downloadTask(with: fileURL) { localURL, response, error in
            if let error = error {
                print("下载失败: \(error)")
                self.loadExchangeRatesFromBundle()
                return
            }
            if let localURL = localURL,let response = response,let suggestedFilename = response.suggestedFilename {
                print("\(suggestedFilename)")
                // 保存到永久路径
                let fileManager = FileManager.default
                let destinationURL = fileManager.temporaryDirectory.appendingPathComponent(suggestedFilename)
                // 删除之前下载的文件
                do {
                    try fileManager.removeItem(at: destinationURL)
                    print("文件删除成功")
                } catch {
                    print("删除文件失败: \(error)")
                }
                
                // 移动下载的文件到临时文件夹
                do {
                    try fileManager.moveItem(at: localURL, to: destinationURL)
                    print("文件已保存到：\(destinationURL)")
                    
                    // 下载完成后解压文件并处理
                    self.processDownloadedFile(destinationURL)
                } catch {
                    print("移动文件时出错：\(error)")
                }
            } else {
                print("在解包localURL、response的过程中出错了。")
            }
            
        }
        task.resume()   // 启动下载任务
    }
    
    // 无网络的情况下，从Bundle中加载文件
    func loadExchangeRatesFromBundle() {
        print("尝试从 Bundle 加载 eurofxref-hist 文件")
        
        if let bundleURL = Bundle.main.url(forResource: "eurofxref-hist", withExtension: "csv") {
            print("从 Bundle 找到文件，路径为：\(bundleURL)")
            // 处理CSV文件
            self.processCSVData(bundleURL.path)
        } else {
            print("在 Bundle 中未找到 eurofxref-hist.csv 文件")
        }
    }
    
    // 下载新的压缩包后，从 临时文件夹 中加载文件
    func processDownloadedFile(_ destinationURL: URL) {
        do {
            print("进入processDownloadedFile方法")
            
            // 选择临时目录作为解压目标
            let destinationDirectory = FileManager.default.temporaryDirectory
            try Zip.unzipFile(destinationURL, destination: destinationDirectory, overwrite: true, password: "")
            
            let files = try FileManager.default.contentsOfDirectory(at: destinationDirectory, includingPropertiesForKeys: nil)
            print("临时文件的列表为：")
            // 打印文件列表
            for file in files {
                print(file.lastPathComponent) // 打印文件名
                if file.lastPathComponent == "eurofxref-hist.csv" {
                    print("进入csv判定：\(file.path)")
                    processCSVData(file.path)
                }
            }
        } catch {
            print("Error during zipping: \(error)")
        }
    }
    
    func processCSVData(_ filePath: String) {
        // 读取并解析CSV文件
        let startDate = Date()
        print("开始解析CSV文件")
        do {
            let csvString = try String(contentsOfFile: filePath)
            // 按行拆分CSV数据
            var lines = csvString.split(separator: "\n")
            guard !lines.isEmpty else {
                print("CSV 文件没有数据")
                return
            }
            
            // CSV 第一行：货币列表（去除第一列日期）
            let CurrencyCodes = lines[0].split(separator: ",").dropFirst().map { String($0) }
            // 将CSV的外币列表同步到 App Storage Manager 中。
            AppStorageManager.shared.listOfSupportedCurrencies = CurrencyCodes
            print("CSV的外币列表同步到 App Storage Manager 的listOfSupportedCurrencies 中，\(AppStorageManager.shared.listOfSupportedCurrencies)")
            /// 移除标题行
            lines.removeFirst()
            
            // 初始化日期格式器
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let existingDates = fetchExistingDates() // 获取已存在日期
            
            // 构造用于批量插入的数据数组
            var records: [[String: Any]] = []
            
            // 处理每一行
            for line in lines {
                // 处理每一行的对应字段
                let columns = String(line).split(separator: ",")
                // 至少要有日期和一个汇率数据
                if columns.count > 1 {
                    // 设置每一行的第一个字段为日期
                    let dateString = String(columns[0])
                    guard let date = dateFormatter.date(from: dateString) else {
                        print("处理汇率数据时，日期解码失败")
                        continue
                    }
                    
                    // 如果该日期已经存在，跳过
                    if existingDates.contains(date) {
                        print("已包含\(date)日期的汇率数据，跳过插入。")
                        continue
                    }
                    
                    // 移除每一行的第一个日期字段后，使用 enumerated() 设置序号
                    for (currencyCode, column) in zip(CurrencyCodes, columns.dropFirst()) {
                        let rate = Double(column) ?? 0.0
                        let record: [String: Any] = [
                            "date": date,
                            "currencySymbol": currencyCode,
                            "exchangeRate": rate
                        ]
                        records.append(record)
                    }
                }
            }
            print("CSV 解析完成，共解析出 \(records.count) 条记录")
            
            if records.isEmpty {
                print("无新增记录，跳过插入")
            } else {
                // 直接使用 NSBatchInsertRequest 批量插入 Core Data
                batchInsertExchangeRates(records: records)
            }
            
            let endDate = Date()
            print("所有汇率数据处理完成，用时:\(endDate.timeIntervalSince(startDate))秒")
        } catch {
            print("读取CSV失败: \(error)")
        }
    }
    
    /// 提前获取 Core Data 中已有的日期集合
    func fetchExistingDates() -> Set<Date> {
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Eurofxrefhist")
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = ["date"]   // 指定 date 字段
        fetchRequest.returnsDistinctResults = true  // 去重
        
        do {
            let results = try context.fetch(fetchRequest)
            let dates = results.compactMap { $0["date"] as? Date}
            // 返回Set类型
            return Set(dates)
        } catch {
            print("获取已有日期失败: \(error)")
            return []
        }
    }
    
    // 获取
    func fetchLatestDate() -> Date? {
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Eurofxrefhist")
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = ["date"]
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first?["date"] as? Date
        } catch {
            print("获取最新日期失败: \(error)")
            return nil
        }
    }
    
    func batchInsertExchangeRates(records: [[String: Any]]) {
        guard !records.isEmpty else {
            print("批量插入跳过：没有数据")
            return
        }
        // 使用后台上下文进行插入，确保 UI 不会卡顿
        let backgroundContext = container.newBackgroundContext()
        
        let fetchRequest: NSFetchRequest<Eurofxrefhist> = Eurofxrefhist.fetchRequest()
        backgroundContext.perform {
            // 构造批量插入请求，实体名称对应你的 Core Data 模型中定义的实体
            let batchInsertRequest = NSBatchInsertRequest(entityName: "Eurofxrefhist", objects: records)
            do {
                try backgroundContext.execute(batchInsertRequest)
                print("批量插入成功，共 \(records.count) 条记录")
                
                let results = try self.context.fetch(fetchRequest)
                print("Core Data中一共有 \(results.count)条记录") // 处理结果
            } catch {
                print("批量插入失败：\(error)")
            }
        }
    }
}
