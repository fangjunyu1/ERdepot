//
//  YahooGoldPriceManager.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/5/24.
//
import SwiftUI

class YahooGoldPriceManager: ObservableObject {
    static let shared = YahooGoldPriceManager()
    private init() {}
    
    private let apiURL = URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/GC=F?interval=1d&range=1mo")!
    
    func
}
