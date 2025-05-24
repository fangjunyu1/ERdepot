//
//  YahooGoldPriceModel.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/5/24.
//

import SwiftUI

struct YahooGoldPriceModel: Codable {
    let chart: YahooGoldPriceChart
}

struct YahooGoldPriceChart: Codable {
    let resuklt: [YahooGoldPriceResult]
}

struct YahooGoldPriceResult: Codable {
    let meta: YahooGoldPriceMeta
    let timestamp: [Int]
    let indicators: YahooGoldPriceIndicators
}

struct YahooGoldPriceMeta: Codable {
    let fullExchangeName: String    // 交易所名称
    let updateTime: Date    // 更新日期
    let regularMarketPrice: Double  // 当前价格
    let fiftyTwoWeekHigh: Double    // 52周最高价
    let fiftyTwoWeekLow: Double     // 52周最低价
    let regularMarketDayHigh: Double    // 今日最高价
    let regularMarketDayLow: Double     // 今日最低价
    let chartPreviousClose:Double   // 前一交易日收盘价
}

struct YahooGoldPriceIndicators: Codable {
    let quote: [YahooGoldPriceQuote]
}

struct YahooGoldPriceQuote: Codable {
    let open: [Double?]
    let low: [Double?]
    let close: [Double?]
    let high: [Double?]
    let volume: [Double?]
}
