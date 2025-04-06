//
//  ExchangeRate.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/4/6.
//

import Foundation

class ExchangeRate :ObservableObject {
    // 下载文件的URL
    static let shared = ExchangeRate()
    private let fileURL = URL(string: "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.zip")!
    
    func downloadExchangeRates() {
        print("进入下载方法 downloadExchangeRates")
        let task = URLSession.shared.downloadTask(with: fileURL) { localURL, response, error in
            if let error = error {
                print("下载失败: \(error)")
                return
            }
            if let localURL = localURL,let response = response,let suggestedFilename = response.suggestedFilename {
                print("response:\(response)")
                print("suggestedFilename:\(suggestedFilename)")
                let fileExtension = (suggestedFilename as NSString).pathExtension
                print("fileExtension:\(fileExtension)")
                print("文件下载到临时路径：\(localURL)")
                
                // 保存到永久路径
                let fileManager = FileManager.default
                let destinationURL = fileManager.temporaryDirectory.appendingPathComponent("eurofxref-hist.\(fileExtension)")
                do {
                    try fileManager.moveItem(at: localURL, to: destinationURL)
                    print("文件已保存到：\(destinationURL)")
                } catch {
                    print("移动文件时出错：\(error)")
                }
            } else { return }
            // 下载完成后解压文件并处理
            //            self.processDownloadedFile(localURL)
        }
        task.resume()   // 启动下载任务
    }
    
    //    func processDownloadedFile(_ localURL: URL) {
    //            // 解压缩文件
    //            let zipFilePath = localURL.path
    //            let unzipDestination = FileManager.default.temporaryDirectory.appendingPathComponent("eurofxref")
    //
    //            // 解压缩代码（可以使用第三方库，如 SSZipArchive）
    //            do {
    //                // 解压缩操作，解压到临时文件夹
    //                try FileManager.default.unzipItem(at: URL(fileURLWithPath: zipFilePath), to: unzipDestination)
    //
    //                // 处理CSV文件
    //                if let csvURL = unzipDestination.appendingPathComponent("eurofxref-hist.csv").path {
    //                    processCSVData(csvURL)
    //                }
    //            } catch {
    //                print("解压失败: \(error)")
    //            }
    //        }
    //    func processCSVData(_ filePath: String) {
    //            // 读取并解析CSV文件
    //            do {
    //                let csvString = try String(contentsOfFile: filePath)
    //                let lines = csvString.split(separator: "\n")
    //
    //                // 处理每一行
    //                for line in lines {
    //                    let columns = line.split(separator: ",")
    //                    if columns.count > 1 {
    //                        // 解析日期和各货币的汇率
    //                        let dateString = String(columns[0])
    //                        let dateFormatter = DateFormatter()
    //                        dateFormatter.dateFormat = "yyyy-MM-dd"
    //
    //                        if let date = dateFormatter.date(from: dateString) {
    //                            // 处理汇率数据
    //                            var exchangeRates: [String: Double] = [:]
    //                            for (index, column) in columns.dropFirst().enumerated() {
    //                                let currencyCode = CurrencyCodes[index]
    //                                let rate = Double(column) ?? 0.0
    //                                exchangeRates[currencyCode] = rate
    //                            }
    //
    //                            // 保存到Core Data
    //                            saveExchangeRates(date: date, rates: exchangeRates)
    //                        }
    //                    }
    //                }
    //            } catch {
    //                print("读取CSV失败: \(error)")
    //            }
    //        }
    //
    //    func saveExchangeRates(date: Date, rates: [String: Double]) {
    //            // 这里你需要用Core Data保存汇率数据
    //            // 假设你有一个ExchangeRate实体，它包含日期、货币代码和对应的汇率
    //
    //            let context = PersistenceController.shared.container.viewContext
    //            for (currency, rate) in rates {
    //                let exchangeRate = ExchangeRate(context: context)
    //                exchangeRate.date = date
    //                exchangeRate.currency = currency
    //                exchangeRate.rateToEuro = rate
    //            }
    //
    //            do {
    //                try context.save()
    //            } catch {
    //                print("保存数据失败: \(error)")
    //            }
    //        }
}
