//
//  Cryptocurrency.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/5/11.
//

import SwiftUI
import CoreData

struct CryptocurrencyView: View {
    
    let fileManager = FileManager.default
    // 汇率字典
    @State private var rateDict: [String:Double] = [:]
        
    @Environment(\.colorScheme) var color
    @EnvironmentObject var appStorage: AppStorageManager
    @Binding var isShowCryptocurrency: Bool
    
    // 通过 @Environment 读取 viewContext
    @Environment(\.managedObjectContext) private var viewContext
    
    // 使用 @FetchRequest 获取数据
    @FetchRequest(
        fetchRequest: {
            let request = NSFetchRequest<CryptoCurrency>(entityName: "CryptoCurrency")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \CryptoCurrency.marketCapRank, ascending: true)]
            return request
        }()
    ) var cryptoCurrencys: FetchedResults<CryptoCurrency>
    
    // 获取最新的汇率日期
    func fetchLatestDate() -> Date? {
        let request = NSFetchRequest<NSDictionary>(entityName: "Eurofxrefhist")
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = ["date"]
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 1
        
        do {
            if let result = try viewContext.fetch(request).first,
               let latestDate = result["date"] as? Date {
                return latestDate
            }
        } catch {
            print("Error fetching latest date: \(error)")
        }
        return nil
    }
    
    // 获取最新的汇率比
    func fetchLatestRates() -> [Eurofxrefhist] {
        guard let latestDate = fetchLatestDate() else { return [] }
        
        let request = NSFetchRequest<Eurofxrefhist>(entityName: "Eurofxrefhist")
        request.predicate = NSPredicate(format: "date == %@", latestDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "symbol", ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching latest rates: \(error)")
            return []
        }
    }
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
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
                            isShowCryptocurrency = false
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
                    // 外币
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Cryptocurrency")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer().frame(height: 10)
                            Text("BTC  ETH")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        VStack {
                            Image("Cryptocurrency")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70)
                        }
                    }
                    Spacer().frame(height:20)
                    if !cryptoCurrencys.isEmpty {
                        Image("noData")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                    } else {
                        ForEach(cryptoCurrencys) { cryptoCurrency in
                            if let id = cryptoCurrency.id,let imageUrl = cryptoCurrency.image,let symbol  = cryptoCurrency.symbol {
                                let marketCapRank = cryptoCurrency.marketCapRank
                                let currentPrice = cryptoCurrency.currentPrice * (rateDict[appStorage.localCurrency] ?? 0)
                                let priceChangePercentage24h = cryptoCurrency.priceChangePercentage24h
                                // 国旗列表
                                HStack {
                                    Text("\(marketCapRank)")
                                    Spacer().frame(width: 20)
                                    
                                    
                                    if let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
                                        let localImageURL = cacheDirectory.appendingPathComponent("\(symbol).png")
                                        if let data = try? Data(contentsOf: localImageURL),let image = UIImage(data:data) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 30, height: 30)
                                                .cornerRadius(10)
                                                .onAppear {
                                                    print("本地缓存:\(symbol)图片")
                                                }
                                           
                                        } else {
                                            AsyncImage(url: imageUrl) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 30, height: 30)
                                                    .cornerRadius(10)
                                            } placeholder: {
                                                ProgressView() // 显示加载占位符
                                                    .onAppear {
                                                            print("使用AsyncImage加载远程图片")
                                                        // 该图片可能未实现缓存，尝试缓存该图片
                                                        CryptoDataManager.shared.DownloadCryptocurrencyImages(imageURL: imageUrl, imageName: symbol)
                                                    }
                                            }
                                        }
                                    }
                                    
                                    
                                    Spacer().frame(width: 20)
                                    // price_change_percentage_24h
                                    VStack(alignment: .leading,spacing:0) {
                                        Text(symbol.uppercased())
                                            .font(.footnote)
                                            .fontWeight(.bold)
                                            .frame(alignment: .center)
                                        HStack {
                                            Text(formatter.string(from: NSNumber(value:priceChangePercentage24h)) ?? "") + Text("%")
                                        }
                                        .padding(.horizontal,5)
                                        .padding(.vertical,2)
                                        .foregroundColor(.white)
                                        .background(priceChangePercentage24h > 0 ? Color.green : Color.red)
                                            .font(.caption2)
                                            .cornerRadius(3)
                                    }
                                    Spacer()
                                    HStack {
                                        Text("\(currencySymbols[appStorage.localCurrency] ?? "$")")
                                        Text("\(currentPrice.formattedWithTwoDecimalPlaces())")
                                    }
                                    .foregroundColor(Color(hex: "333333"))
                                }
                                .padding(.horizontal,20)
                                .frame(width: width * 0.85,height: 50)
                                .background(color == .light ? Color(hex: "ECECEC") : Color(hex: "2f2f2f"))
                                .cornerRadius(10)
                            }
                        }
                    }
                    
                    Spacer()
                        .frame(height: 30)
                    VStack {
                        HStack {
                            Text("Data source")
                            Text("CoinGecko")
                        }
                        Spacer().frame(height: 5)
                        HStack {
                            Text("Update time")
                            Text(appStorage.CryptocurrencylastUpdateDate,format: Date.FormatStyle.dateTime)
                        }
                    }
                    .foregroundColor(.gray)
                    .font(.caption2)
                    Spacer()
                        .frame(height: 20)
                }
                .frame(width: width * 0.85)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            // 获取最新的汇率数据
            var latestRates = fetchLatestRates()
            rateDict = Dictionary(uniqueKeysWithValues: latestRates.map { ($0.symbol ?? "", $0.rate) })
        }
    }
}

#Preview {
    CryptocurrencyView(isShowCryptocurrency: .constant(true))
        .environmentObject(AppStorageManager.shared)
        .environment(\.managedObjectContext, CoreDataPersistenceController.shared.context) // 加载 NSPersistentContainer
}
