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
        do {
            let csvString = try String(contentsOfFile: filePath)
            // 每一行列表
            var lines = csvString.split(separator: "\n")
            
            // 设置货币列表
            let CurrencyCodes = lines[0].split(separator: ",").dropFirst().map { String($0) }
            // 设置汇率列表，移除首行
            lines.removeFirst()
            
            // 处理每一行
            for line in lines {
                // 处理每一行的对应字段
                let columns = String(line).split(separator: ",")
                if columns.count > 1 {
                    // 解析日期和各货币的汇率
                    // 设置每一行的第一个字段为日期
                    let dateString = String(columns[0])
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    if let date = dateFormatter.date(from: dateString) {
                        // 处理汇率数据
                        var exchangeRates: [String: Double] = [:]
                        // 移除每一行的第一个日期字段后，使用 enumerated() 设置序号
                        for (currencyCode, column) in zip(CurrencyCodes, columns.dropFirst()) {
                            let rate = Double(column) ?? 0.0
                            exchangeRates[currencyCode] = rate
                        }
                        
                        // 保存到Core Data
                        saveExchangeRates(date: date, rates: exchangeRates)
                    } else {
                        print("处理汇率数据时，日期解码失败")
                    }
                }
            }
            
            // 检查数据
            fetchExchangeRates()
        } catch {
            print("读取CSV失败: \(error)")
        }
    }
    
    func saveExchangeRates(date: Date, rates: [String: Double]) {
        
        
        // 遍历汇率数据并插入到 Core Data
        for (currency, rate) in rates {
            let exchangeRate = Eurofxrefhist(context: context)
            exchangeRate.date = date
            exchangeRate.currencySymbol = currency
            exchangeRate.exchangeRate = rate
        }
        
        do {
            try context.save()
            print("汇率数据保存成功")
        } catch {
            print("保存数据失败: \(error)")
        }
    }
    
    func fetchExchangeRates() {
        let fetchRequest: NSFetchRequest<Eurofxrefhist> = Eurofxrefhist.fetchRequest()
        let components = DateComponents(year: 2025, month: 4, day: 9)
        let calendar = Calendar.current
        let date = calendar.date(from: components)!
        
        // 通过 CVarArg 将 date 转换为合适的类型
        fetchRequest.predicate = NSPredicate(format: "date == %@", date as CVarArg)
        
        do {
            
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                print("没有找到2025年4月9日的数据")
            } else {
                // 如果查询结果不为空，输出并处理数据
                for result in results {
                    // 在这里处理找到的数据
                    print("汇率数据: \(result.currencySymbol) - \(result.exchangeRate) at \(result.date!)")
                }
            }
        } catch {
            print("获取数据失败: \(error)")
        }
    }
}
