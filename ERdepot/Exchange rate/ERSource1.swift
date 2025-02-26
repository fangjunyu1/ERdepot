//
//  ERSource1.swift
//  ERdepot
//
//  Created by 方君宇 on 2024/10/24.
//
//
//
// “中国外汇交易中心：https://iftp.chinamoney.com.cn/chinese/bkccpr/
// 获取“中国外汇交易中心”汇率信息： https://iftp.chinamoney.com.cn/r/cms/www/chinamoney/data/fx/ccpr.json

import Foundation
// 汇率JSON串请求地址
let ChinaForeignExchangeTradingCenter = "https://iftp.chinamoney.com.cn/r/cms/www/chinamoney/data/fx/ccpr.json"

// JSON串 结构框架
struct ForexDataStruct:Codable {
    var head: ForexDataStruct_Head
    var data: ForexDataStruct_Data
    var records: [ForexDataStruct_Info]
}
// Head 结构
struct ForexDataStruct_Head: Codable {
    var version: String
    var provider: String
    var req_code: String
    var rep_code: String
    var rep_message: String
    var ts: Int
    var producer: String
}
// Data 结构
struct ForexDataStruct_Data: Codable {
    var lastDateEn: String
    var lastDate: String
    var pairChange: String
}
// Info结构
struct ForexDataStruct_Info: Codable {
    var vrtCode: String
    var price: String
    var bp: String
    var vrtName: String
    var vrtEName: String
    var foreignCName: String
    var bpDouble: Double
    var approvedTime: String
    var approvedTimeEn: String
    var showDate: String
    var showDateForCn: String
    var lastMonthAvgPrice: String
    var monthPrice: String
    var quarterPrice: String
    var yearPrice: String
    var isShowBp: Bool
    var show: Bool
    var url: String
    var bannerPic: String
    var bannerCss: String
}

// 从 中国外汇交易中心 获取最新的JSON文件
func loadChinaForeignExchangeTradingCenter() async {
    
    let localURL = URL.documentsDirectory.appendingPathComponent("ccpr.json")
    
    print("进入中国外汇交易中心，开始获取最新的JSON文件")
    guard let url = URL(string: ChinaForeignExchangeTradingCenter) else {
        print("进入中国外汇交易中心，JSON URL报错")
        return
    }
    do {
        // 通过 URLSession 获取JSON文件
        print("【中国外汇交易中心】通过 URLSession 获取JSON文件")
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // 将加载的文件保存在Documents
        print("将加载的最新文件保存到DocumentsDirectory路径中")
        try data.write(to: localURL)
        
        // 将JSON文件解码为对应的 ForexDataStruct 结构
        print("【中国外汇交易中心】将JSON文件解码为对应的 ForexDataStruct 结构")
        let decodedResponse = try JSONDecoder().decode(ForexDataStruct.self, from: data)
        
        // 将解码后的数据转换为通用的 ExchangeRateStruct
        print("【中国外汇交易中心】将解码后的数据转换为通用的 ExchangeRateStruct")
        let exchangeRateStruct = convertForexDataStruct(from: decodedResponse)
        print("转码后的数据：exchangeRateStruct：\(exchangeRateStruct)")
        
        // 更新单例中的 ExchangeRateStruct
        DispatchQueue.main.async {
            ExchangeRate.ExchangeRateExamples.ExchangeRateStructInfo = exchangeRateStruct
            // 重新计算汇率仓库的数值
            ExchangeRate.ExchangeRateExamples.calculaterReserveAmount()
        }
    } catch {
        print("从中国外汇交易中心获取以及解码数据失败")
        print("开始从本地获取JSON文件")
        
        // 在本地查找Documents中的JSON文件
        if let localData = try? Data(contentsOf: localURL) {
            print("从 Documents 目录读取 JSON 文件")
            decodeAndProcessLocalJSON(data: localData)
        } else if let bundleFileURL = Bundle.main.url(forResource: "ccpr", withExtension: "json") {
            // 如果 Documents 中没有，再读取 Bundle 中的文件
            print("从 Bundle 读取 JSON 文件")
            if let bundleData = try? Data(contentsOf: bundleFileURL) {
                decodeAndProcessLocalJSON(data: bundleData)
            } else {
                print("本地文件解码失败！")
            }
        }
    }
}
func decodeAndProcessLocalJSON(data: Data) {
    let decoder = JSONDecoder()
    do {
        let decoded = try decoder.decode(ForexDataStruct.self, from: data)
        let exchangeRateStruct = convertForexDataStruct(from:decoded)
        // 更新单例中的 ExchangeRateStruct
        DispatchQueue.main.async {
            ExchangeRate.ExchangeRateExamples.ExchangeRateStructInfo = exchangeRateStruct
            // 重新计算汇率仓库的数值
            ExchangeRate.ExchangeRateExamples.calculaterReserveAmount()
        }
    } catch {
        print("本地 JSON 文件解码失败")
    }
}

func convertForexDataStruct(from forexData: ForexDataStruct) -> ExchangeRateStruct{
    print("进入 convertForexDataStruct 转换结构")
    // 提取可用的币种符号
    var availableCurrencies = Set(forexData.records.map{$0.foreignCName})
    availableCurrencies.insert("CNY")
    // 构建汇率字典
    var exchangeRatesDictionar: [String:CurrencyData] = [:]
    exchangeRatesDictionar["CNY"] = CurrencyData(currencySymbol: "CNY", rate: 1, baseRate: 1)
    // 转换时间
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm" // 请根据实际的日期字符串格式进行设置
    dateFormatter.timeZone = TimeZone.current // 设置为本地时区
    
    var convertDate: Date = Date()   // 转换后的时间
    let lastDateString = forexData.data.lastDate    // 获取汇率时间的字符串
    
    if let tempDate = dateFormatter.date(from: lastDateString) {
        print("时间转码成功，convertDate：\(tempDate) 本地时间：\(dateFormatter.string(from: tempDate))")
        convertDate = tempDate
    }
    
    for record in forexData.records {
        guard let rate = Double(record.price), rate > 0 else { continue }
        // 通过 vrtCode 或 vrtName 推断汇率方向
        let baseRate: Double
        // 如果是 CNY/其他货币，直接用 rate，因为 1 CNY = rate 外币
        if record.vrtEName.contains("CNY/") {
            baseRate = rate
        } else {
            // 如果是 CNY/日元，需要调整为 100 / rate，因为 1 CNY = rate 日币
            // 日币在这里比较特殊
            if record.vrtEName.contains("100JPY/CNY") {
                baseRate = 100 / rate
            } else {
                // 如果是 其他货币/CNY，需要调整为 1.0 / rate，因为 1 外币 = rate CNY
                baseRate = 1.0 / rate
            }
        }
        let currencyData = CurrencyData(
            currencySymbol: record.foreignCName,
            rate: rate,
            baseRate: baseRate
        )
        print("currencyData:\(currencyData)")
        exchangeRatesDictionar[record.foreignCName] = currencyData
    }
    
    return ExchangeRateStruct(
        sourceName: "A certain foreign exchange market",
        calculationMethod: "Calculated based on the currency source",
        jsonURL: "https://iftp.chinamoney.com.cn/r/cms/www/chinamoney/data/fx/ccpr.json",
        baseCurrency: "CNY",
        syncDate: convertDate,
        availableCurrencies: availableCurrencies,
        exchangeRates: exchangeRatesDictionar)
}
