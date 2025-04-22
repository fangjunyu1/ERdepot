//
//  ExchangeRateChartPoint.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/4/22.
//

import Foundation
/// 汇率历史条目（用于图表）
struct ExchangeRateChartPoint: Identifiable {
    let id = UUID()
    let date: Date
    let totalValue: Double  // 所有外币的本币总价值
    static let previewData: [ExchangeRateChartPoint] = [
        ExchangeRateChartPoint(date: Date(timeIntervalSince1970: 1744300800), totalValue: 2000),
        ExchangeRateChartPoint(date: Date(timeIntervalSince1970: 1744387200), totalValue: 2050),
        ExchangeRateChartPoint(date: Date(timeIntervalSince1970: 1744473600), totalValue: 2100),
        ExchangeRateChartPoint(date: Date(timeIntervalSince1970: 1744560000), totalValue: 2080),
        ExchangeRateChartPoint(date: Date(timeIntervalSince1970: 1744646400), totalValue: 2150),
        ExchangeRateChartPoint(date: Date(timeIntervalSince1970: 1744732800), totalValue: 2200),
        ExchangeRateChartPoint(date: Date(timeIntervalSince1970: 1744819200), totalValue: 2180),
        ExchangeRateChartPoint(date: Date(timeIntervalSince1970: 1744905600), totalValue: 2250),
        ExchangeRateChartPoint(date: Date(timeIntervalSince1970: 1744992000), totalValue: 2300),
        ExchangeRateChartPoint(date: Date(timeIntervalSince1970: 1745078400), totalValue: 2280),
        ExchangeRateChartPoint(date: Date(timeIntervalSince1970: 1745164800), totalValue: 2350),
        ExchangeRateChartPoint(date: Date(timeIntervalSince1970: 1745251200), totalValue: 2400),
        ExchangeRateChartPoint(date: Date(timeIntervalSince1970: 1745337600), totalValue: 2450),
        ExchangeRateChartPoint(date: Date(timeIntervalSince1970: 1745424000), totalValue: 2500),
        ExchangeRateChartPoint(date: Date(timeIntervalSince1970: 1745510400), totalValue: 2480),
        ExchangeRateChartPoint(date: Date(timeIntervalSince1970: 1745596800), totalValue: 2530)
    ]
}
