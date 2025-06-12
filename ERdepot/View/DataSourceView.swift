//
//  DataSourceView.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/6/11.
//

import SwiftUI

struct DataSourceView: View {
    @Environment(\.colorScheme) var color
    @Environment(\.dismiss) var dismiss
    var body: some View {
        
        NavigationView {
            GeometryReader { geo in
                let width = geo.frame(in: .local).width * 0.95
                let height = geo.frame(in: .local).height
                    
                ScrollView(showsIndicators: false) {
                    
                    Spacer()
                        .frame(height: 10)
                    
                    // 标题
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Data sources")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        Spacer()
                    }
                    
                    Spacer()
                        .frame(height: 30)
                    
                    // 外汇数据
                    VStack(spacing: 16) {
                        Text("Forex Data")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Foreign exchange data comes from the European Central Bank")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Image("ecu")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140)
                        Link(destination:
                            URL(string: "https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html")!
                        ) {
                            Text("Website link")
                                .fontWeight(.medium)
                                .padding(.vertical,6)
                                .padding(.horizontal,30)
                                .foregroundColor(.white)
                                .background(color == .light ? .black : Color(hex: "2f2f2f"))
                                .cornerRadius(4)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 50)
                    
                    // 加密货币
                    VStack(spacing: 16) {
                        Text("Cryptocurrency")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Cryptocurrency from CoinGecko")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Image("CoinGecko")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200)
                            .cornerRadius(6)
                        Link(destination:
                            URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=eur&order=market_cap_desc&per_page=50&page=1")!
                        ) {
                            Text("Interface link")
                                .fontWeight(.medium)
                                .padding(.vertical,6)
                                .padding(.horizontal,30)
                                .foregroundColor(.white)
                                .background(color == .light ? .black : Color(hex: "2f2f2f"))
                                .cornerRadius(4)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 50)
                    
                    // 每日金价、股票指数
                    VStack(spacing: 16) {
                        Text("Daily gold prices, stock indices")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Daily gold prices and stock indices are sourced from Yahoo Finance")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Image("YahooFinance")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140)
                            .cornerRadius(20)
                        // 每日金价-接口链接
                        Text("Daily gold price")
                            .foregroundColor(.gray)
                        Link(destination:
                            URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/GC=F?interval=1d&range=1mo")!
                        ) {
                            Text("Interface link")
                                .fontWeight(.medium)
                                .padding(.vertical,6)
                                .padding(.horizontal,30)
                                .foregroundColor(.white)
                                .background(color == .light ? .black : Color(hex: "2f2f2f"))
                                .cornerRadius(4)
                        }
                        // 股票指数-接口链接
                        Text("Stock index")
                            .foregroundColor(.gray)
                        Link(destination:
                            URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/%5EGSPC")!
                        ) {
                            Text("Interface link")
                                .fontWeight(.medium)
                                .padding(.vertical,6)
                                .padding(.horizontal,30)
                                .foregroundColor(.white)
                                .background(color == .light ? .black : Color(hex: "2f2f2f"))
                                .cornerRadius(4)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 30)
                    
                    Text("Some of the data for this project comes from the European Central Bank (ECB), CoinGecko and Yahoo Finance. Thanks to these platforms for their long-term selfless sharing of public data, helping developers and users easily access reliable financial information.")
                        .multilineTextAlignment(.center)
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    Spacer()
                        .frame(height: 50)
                }
                .frame(width: width * 0.85)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
//        .navigationBarBackButtonHidden(true) // 隐藏返回按钮
    }
}

#Preview {
    DataSourceView()
        .environmentObject(IAPManager.shared)
        .environmentObject(AppStorageManager.shared)
    //        .environment(\.locale, .init(identifier: "de")) // 设置为阿拉伯语
}
