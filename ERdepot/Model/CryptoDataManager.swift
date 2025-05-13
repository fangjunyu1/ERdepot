//
//  CryptoDataManager.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/5/12.
//

import Foundation
import CoreData

class CryptoDataManager: ObservableObject {
    static let shared = CryptoDataManager()
    private init() {}
    
    private let apiURL = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=eur&order=market_cap_desc&per_page=50&page=1")!
    
    func updateIfNeeded(context: NSManagedObjectContext) {
        let calendar = Calendar.current
        if calendar.isDateInToday(AppStorageManager.shared.CryptocurrencylastUpdateDate) {
            print("今天已经完成加密货币的更新，不再更新")
            return
        }
        
        // 调用加密数据接口
        fetchCryptoData(context: context)
        // 更新加密数据日期
        AppStorageManager.shared.CryptocurrencylastUpdateDate = Date()
    }
    
    func fetchCryptoData(context: NSManagedObjectContext) {
        let task = URLSession.shared.dataTask(with: apiURL) {data, response, error in
            
            // 检查是否有错误
            if let error = error {
                print("请求出错：\(error.localizedDescription)")
                return
            }
            
            let decoder = JSONDecoder()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            decoder.dateDecodingStrategy = .formatted(formatter)
            
            // 获取加密外币的数据
            let fetchRequest: NSFetchRequest<CryptoCurrency> = CryptoCurrency.fetchRequest()
            
            // 检查响应数据
            if let data = data {
                do {
                    print("成功解码")
                    
                    let decoded = try decoder.decode([CryptoDTO].self, from: data)
                    
                    // 获取 Core Data 中的加密外币数据
                    let existingCryptos = try context.fetch(fetchRequest)
                    var existingDict = Dictionary(uniqueKeysWithValues: existingCryptos.compactMap{ ($0.id, $0) })
                    
                    for coin in decoded {
                        
                        // 下载加密货币的图片
                        self.DownloadCryptocurrencyImages(imageURL: coin.image, imageName: coin.symbol)
                        
                        // 如果 Core Data 中的加密外币中有当前外币
                        if (existingDict[coin.id] != nil) {
                            existingDict[coin.id]?.id = coin.id
                            existingDict[coin.id]?.symbol = coin.symbol
                            existingDict[coin.id]?.name = coin.name
                            existingDict[coin.id]?.image = coin.image
                            existingDict[coin.id]?.currentPrice = coin.currentPrice ?? 0
                            existingDict[coin.id]?.marketCap = Int64(coin.marketCap ?? 0)
                            existingDict[coin.id]?.marketCapRank = Int64(coin.marketCapRank ?? 0)
                            existingDict[coin.id]?.fullyDilutedValuation = Int64(coin.fullyDilutedValuation ?? 0)
                            existingDict[coin.id]?.totalVolume = coin.totalVolume ?? 0.0
                            existingDict[coin.id]?.high24h = coin.high24h ?? 0.0
                            existingDict[coin.id]?.low24h = coin.low24h ?? 0.0
                            existingDict[coin.id]?.priceChange24h = coin.priceChange24h ?? 0.0
                            existingDict[coin.id]?.priceChangePercentage24h = coin.priceChangePercentage24h ?? 0.0
                            existingDict[coin.id]?.marketCapChange24h = coin.marketCapChange24h ?? 0.0
                            existingDict[coin.id]?.marketCapChangePercentage24h = coin.marketCapChangePercentage24h ?? 0.0
                            existingDict[coin.id]?.circulatingSupply = coin.circulatingSupply ?? 0.0
                            existingDict[coin.id]?.totalSupply = coin.totalSupply ?? 0.0
                            existingDict[coin.id]?.maxSupply = coin.maxSupply ?? 0.0
                            existingDict[coin.id]?.ath = coin.ath ?? 0.0
                            existingDict[coin.id]?.athChangePercentage = coin.athChangePercentage ?? 0.0
                            existingDict[coin.id]?.athDate = coin.athDate ?? Date.distantPast
                            existingDict[coin.id]?.atl = coin.atl ?? 0.0
                            existingDict[coin.id]?.atlChangePercentage = coin.atlChangePercentage ?? 0.0
                            existingDict[coin.id]?.atlDate = coin.atlDate ?? Date.distantPast
                            existingDict[coin.id]?.roiTime = coin.roi?.times ?? 0.0
                            existingDict[coin.id]?.roiPercentage = coin.roi?.percentage ?? 0.0
                            existingDict[coin.id]?.roiCurrency = coin.roi?.currency ?? ""
                            existingDict[coin.id]?.lastUpdated = coin.lastUpdated ?? Date.distantPast
                        } else {
                            // 创建对应的加密外币
                            let crypto = CryptoCurrency(context: context)
                            existingDict[coin.id] = crypto
                            existingDict[coin.id]?.id = coin.id
                            existingDict[coin.id]?.symbol = coin.symbol
                            existingDict[coin.id]?.name = coin.name
                            existingDict[coin.id]?.image = coin.image
                            existingDict[coin.id]?.currentPrice = coin.currentPrice ?? 0
                            existingDict[coin.id]?.marketCap = Int64(coin.marketCap ?? 0)
                            existingDict[coin.id]?.marketCapRank = Int64(coin.marketCapRank ?? 0)
                            existingDict[coin.id]?.fullyDilutedValuation = Int64(coin.fullyDilutedValuation ?? 0)
                            existingDict[coin.id]?.totalVolume = coin.totalVolume ?? 0.0
                            existingDict[coin.id]?.high24h = coin.high24h ?? 0.0
                            existingDict[coin.id]?.low24h = coin.low24h ?? 0.0
                            existingDict[coin.id]?.priceChange24h = coin.priceChange24h ?? 0.0
                            existingDict[coin.id]?.priceChangePercentage24h = coin.priceChangePercentage24h ?? 0.0
                            existingDict[coin.id]?.marketCapChange24h = coin.marketCapChange24h ?? 0.0
                            existingDict[coin.id]?.marketCapChangePercentage24h = coin.marketCapChangePercentage24h ?? 0.0
                            existingDict[coin.id]?.circulatingSupply = coin.circulatingSupply ?? 0.0
                            existingDict[coin.id]?.totalSupply = coin.totalSupply ?? 0.0
                            existingDict[coin.id]?.maxSupply = coin.maxSupply ?? 0.0
                            existingDict[coin.id]?.ath = coin.ath ?? 0.0
                            existingDict[coin.id]?.athChangePercentage = coin.athChangePercentage ?? 0.0
                            existingDict[coin.id]?.athDate = coin.athDate ?? Date.distantPast
                            existingDict[coin.id]?.atl = coin.atl ?? 0.0
                            existingDict[coin.id]?.atlChangePercentage = coin.atlChangePercentage ?? 0.0
                            existingDict[coin.id]?.atlDate = coin.atlDate ?? Date.distantPast
                            existingDict[coin.id]?.roiTime = coin.roi?.times ?? 0.0
                            existingDict[coin.id]?.roiPercentage = coin.roi?.percentage ?? 0.0
                            existingDict[coin.id]?.roiCurrency = coin.roi?.currency ?? ""
                            existingDict[coin.id]?.lastUpdated = coin.lastUpdated ?? Date.distantPast
                        }
                    }
                    
                    // 从字典中取出 id：
                    let arrayIDs = Set(decoded.map {$0.id })
                    
                    // 从字典中筛选出不在 Core Data 中的对象：
                    let extraObjects = existingDict.filter { !arrayIDs.contains($0.key ?? "")}
                    for extraObject in extraObjects {
                        context.delete(extraObject.value)
                    }
                    
                    do {
                        try context.save()  // 删除后保存
                    } catch {
                        print("Error deleting task: \(error.localizedDescription)")
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
                    print("解码报错: \(error)")
                }
            }
            
        }
        // 启动任务
        task.resume()
    }
    
    let fileManager = FileManager.default
    // 下载加密货币图片
    func DownloadCryptocurrencyImages(imageURL: URL,imageName: String) {
        // 使用缓存目录（更适合长期存储）
        guard let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            print("无法获取缓存目录")
            return
        }
        let localImageURL = cacheDirectory.appendingPathComponent("\(imageName).png")
        if fileManager.fileExists(atPath: localImageURL.path) {
            print("\(imageName)照片已存在，跳过下载")
            return
        } else {
            print("\(imageName)照片不存在，下载\(imageName)照片")
            let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
                if let error = error {
                    print("下载失败：\(error.localizedDescription)")
                    return
                }
                guard let data = data else {
                    print("下载失败：无数据")
                    return
                }
                
                do {
                    // 将数据解析为字符串（例如 JSON）
                    try data.write(to: localImageURL)
                } catch {
                    print("预加载失败：\(error)")
                }
            }
            task.resume()   // 启动任务
        }
    }
    
}
