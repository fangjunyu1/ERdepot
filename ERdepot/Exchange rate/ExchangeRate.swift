//
//  ExchangeRate.swift
//  ERdepot
//
//  Created by 方君宇 on 2024/10/16.
//
import Foundation

// 通用汇率结构
struct ExchangeRateStruct {
    var sourceName: String  // 汇率来源
    var calculationMethod: String   // 汇率计算方法，默认为根据币种来源推算
    var jsonURL: String     // 汇率 JSON 地址
    var baseCurrency: String?    // 以某币种为基准单位，例如人民币CNY，统一使用该币种进行汇算各币种之间的差值。
    var syncDate: Date      // 汇率同步时间
    var availableCurrencies: Set<String> // 支持的汇率币种
    var exchangeRates: [String: CurrencyData]   // 基于人民币的汇率字典，以符号为键
    
    // ExchangeAmount 为输入的金额，CurrentCurrency为当前币种，ExchangeCurrency为需要转换的币种
    func conver(ExchangeAmount:Double, CurrentCurrency: String, ExchangeCurrency: String) -> Double {
        guard  // 因为exchangeRates字典可返回nil，因此添加判断，不小于0返回0
            let currentBaseRate = exchangeRates[CurrentCurrency]?.baseRate,
            let exchangeBaseRate = exchangeRates[ExchangeCurrency]?.baseRate,
            currentBaseRate > 0 else {
            return 0 // 或者抛出一个错误
        }
        return ExchangeAmount / currentBaseRate * exchangeBaseRate
    }
}


//  汇率数据
struct CurrencyData {
    let currencySymbol: String      // 汇率符号，例如"USD"
    var rate: Double                // 汇率比，例如7.1191
    var baseRate: Double            // 汇率基准比，例如以1人民币为单位，0.1404
}

// 汇率类
class ExchangeRate:ObservableObject {
    // 汇率单例模式
    static var ExchangeRateExamples = ExchangeRate()
    
    // 汇率仓库的金额
    @Published var ExchangeRateWarehouseAmount = 0.0
    // 汇率仓库换算货币
    @Published var ExchangeRateCurrencyConversion = "USD" {
        didSet {
            UserDefaults.standard.setValue(ExchangeRateCurrencyConversion, forKey: "ExchangeRateCurrencyConversion")
        }
    }
    // 汇率仓库各金额的存储
    @Published var ExchangeRateWarehousconvertedAmounts: [String: Double] = [:] {
        didSet {
            // 使用 JSONEncoder 将字典编码为 Data
            if let data = try? JSONEncoder().encode(ExchangeRateWarehousconvertedAmounts) {
                UserDefaults.standard.setValue(data, forKey: "ExchangeRateWarehousconvertedAmounts")
            }
        }
    }
    
    // 常用的汇率币种【目前限定为5种货币】
    @Published var CommonCurrencies:[String] = [] {
        didSet {
            UserDefaults.standard.setValue(CommonCurrencies, forKey: "CommonCurrencies")
        }
    }
    
    // 汇率来源
    // A certain foreign exchange market ：中国外汇交易中心-ERSource1.swift
    // ChinaForeignExchangeTradingCenter 实际的英文名称
    @Published var ExchangeRateSource = ["A certain foreign exchange market"]
    // 用户选择的汇率来源，默认为0，即 ExchangeRateSource[0]
    @Published var UserSelectedSource = 0 {
        didSet {
            UserDefaults.standard.setValue(UserSelectedSource, forKey: "UserSelectedSource")
            // 当用户切换汇率来源时，重新根据汇率来源调取相关的汇率数据
        }
    }
    
    // 汇率信息结构
    @Published var ExchangeRateStructInfo = ExchangeRateStruct(
        sourceName: "",
        calculationMethod: "",
        jsonURL: "",
        baseCurrency: nil,
        syncDate: Date(),
        availableCurrencies: [],
        exchangeRates: [:]
    )
    
    // 初始化
    private init() {
        print("初始化ExchangeRate结构")
        print("初始化时ExchangeRateStructInfo：\(self.ExchangeRateStructInfo)")
        // 加载汇率换算货币：CNY 或者其他
        loadExchangeRateCurrencyConversion()
        // 加载常用的五个币种
        print("加载常用的五个币种")
        loadCommonCurrencies()
        // 初始化用户选择的汇率来源
        print("初始化用户选择的汇率来源")
        loadUserSelectedSource()
        print("初始化用户的仓库金额")
        loadExchangeRateWarehouse()
        print("判断并加载汇率来源")
        judgeSource()
    }
    
    // 计算汇率仓库的储备金额
    func calculaterReserveAmount() {
        print("进入calculaterReserveAmount方法")
        // 重新将汇率仓库的储备金额置空，并尝试重新计算
        ExchangeRateWarehouseAmount = 0.0
        // 轮询常用货币中的各个币种
        for item in CommonCurrencies {
            print("常用货币：\(item)")
            print("常用货币保存的值：\(String(describing: ExchangeRateWarehousconvertedAmounts[item]))")
            print("常用货币在汇率表中的基准汇率：\(String(describing: ExchangeRateStructInfo.exchangeRates[item]?.baseRate))")
            // 获取汇率仓库存储金额的字典中有该币种的金额 value
            // 获取汇率来源的基准汇率数据并进行解包 baseRate
            if let value = ExchangeRateWarehousconvertedAmounts[item],
               let baseRate = ExchangeRateStructInfo.exchangeRates[item]?.baseRate {
                ExchangeRateWarehouseAmount += value / baseRate
            } else {
                print("\(item)的baseRate无效（为0或找不到），跳过此项计算")
            }
        }
        ExchangeRateWarehouseAmount = ExchangeRateWarehouseAmount * (ExchangeRateStructInfo.exchangeRates[ExchangeRateCurrencyConversion]?.baseRate ?? 0)
    }
    
    // 计算其他货币的转换值
    // inputAmount为输入的金额，currency为货币种类（USD）
    func calculateConvertedAmounts(inputAmount: Double, currency: String) -> [String: Double]{
        var tmpConvertedAmounts:[String: Double] = [:]
        // 轮询常用的五种货币单位
        for targetCurrency in ExchangeRate.ExchangeRateExamples.CommonCurrencies {
            // 如果目标货币跟当前（输入）的货币种类不同。
            if targetCurrency != currency {
                // 调取 conver 转换方法
                let convertedAmount = ExchangeRate.ExchangeRateExamples.ExchangeRateStructInfo.conver(
                    ExchangeAmount: inputAmount,        // 当前金额
                    CurrentCurrency: currency,          // 输入货币种类
                    ExchangeCurrency: targetCurrency    // 目标货币种类
                )
                // 最后将货币种类和兑换的金额返回给View视图,USD:100
                tmpConvertedAmounts[targetCurrency] = convertedAmount
            }
        }
        return tmpConvertedAmounts
    }
    
    // 判断用户选择的汇率数据来源
    func judgeSource() {
        print("判断用户选择的汇率数据来源")
        switch UserSelectedSource {
        case 0:
            // 调取中国外汇交易中心的数据
            print("调取中国外汇交易中心的数据")
            Task {
                await loadChinaForeignExchangeTradingCenter()
                
            }
            break
        default:
            print("judgeSource报错，退出judgeSource函数")
            break
        }
    }
    
    // ExchangeRateWarehousconvertedAmounts 汇率仓库各币种金额
    private func loadExchangeRateWarehouse() {
        // 适用于首次加载，判断 UserDefaults 中有没有汇率仓库各币种金额
        if let data = UserDefaults.standard.data(forKey: "ExchangeRateWarehousconvertedAmounts") {
            // 使用 JSONDecoder 解码为 [String: Double] 字典
            print("初始化 汇率仓库各币种金额 字典")
            if let decodedAmounts = try? JSONDecoder().decode([String: Double].self, from: data) {
                print("初始化 汇率仓库各币种金额 字典，解码赋值成功")
                print("解码内容decodedAmounts为：\(decodedAmounts)")
                ExchangeRateWarehousconvertedAmounts = decodedAmounts
            } else {
                print("初始化 汇率仓库各币种金额 字典，解码报错")
            }
        } else {
            // 如果没有存储数据，将其初始化为空字典
            ExchangeRateWarehousconvertedAmounts = [:]
            print("ExchangeRateWarehousconvertedAmounts 为空，初始化为空字典")
        }
        
    }
    
    // loadExchangeRateCurrencyConversion 读取汇率换算货币
    private func loadExchangeRateCurrencyConversion() {
        ExchangeRateCurrencyConversion = UserDefaults.standard.string(forKey: "ExchangeRateCurrencyConversion") ?? "USD"
    }
    
    private func loadUserSelectedSource() {
        print("判断用户选择的来源")
        // 适用于首次加载，判断 UserDefaults 中有没有用户选择的来源
        if UserDefaults.standard.object(forKey: "UserSelectedSource") == nil {
            // 如果为nil的话，将 UserDefaults 的值改为0
            print("UserDefaults中用户选择的来源为nil，改为0")
            UserDefaults.standard.setValue(0, forKey: "UserSelectedSource")
        }
        // 初始化时读取 UserDefaults 中的用户来源
        UserSelectedSource = UserDefaults.standard.integer(forKey: "UserSelectedSource")
        print("初始化时读取 UserDefaults 中的用户来源: \(UserSelectedSource)")
    }
    
    // 首页显示的常用币种
    private func loadCommonCurrencies() {
        print("进入首页显示的常用币种 loadCommonCurrencies 方法")
        if UserDefaults.standard.array(forKey: "CommonCurrencies") == nil {
            // 如果为nil的话，将 UserDefaults 的值改为 USD美元、EUR欧元、JPY日元、GBP英镑和HKD港元
            print("UserDefaults中常用币种为nil，改为USD美元、EUR欧元、JPY日元、GBP英镑和HKD港元")
            UserDefaults.standard.setValue(["USD","EUR","JPY","GBP","HKD"], forKey: "CommonCurrencies")
        }
        // 初始化时读取 UserDefaults 中的常用币种
        print("初始化时读取 UserDefaults 中的常用币种")
        CommonCurrencies = UserDefaults.standard.array(forKey: "CommonCurrencies") as? [String] ?? []
        print("CommonCurrencies:\(CommonCurrencies)")
    }
    
}
enum ExchangeRateError: Error {
    case WrongDataSource
    case SomeUnknowError
}
