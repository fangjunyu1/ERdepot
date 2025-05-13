//
//  CryptoDTO.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/5/8.
//

import Foundation

struct CryptoDTO: Codable {
    let id: String
    let symbol: String
    let name: String
    let image: URL
    let currentPrice: Double?
    let marketCap: Int?
    let marketCapRank: Int?
    let fullyDilutedValuation: Int?
    let totalVolume: Double?
    let high24h: Double?
    let low24h: Double?
    let priceChange24h: Double?
    let priceChangePercentage24h: Double?
    let marketCapChange24h: Double?
    let marketCapChangePercentage24h: Double?
    let circulatingSupply: Double?
    let totalSupply: Double?
    let maxSupply: Double?
    let ath: Double?
    let athChangePercentage: Double?
    let athDate: Date?
    let atl: Double?
    let atlChangePercentage: Double?
    let atlDate: Date?
    let roi: ROI?
    let lastUpdated: Date?

    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image, ath, atl, roi
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case fullyDilutedValuation = "fully_diluted_valuation"
        case totalVolume = "total_volume"
        case high24h = "high_24h"
        case low24h = "low_24h"
        case priceChange24h = "price_change_24h"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case marketCapChange24h = "market_cap_change_24h"
        case marketCapChangePercentage24h = "market_cap_change_percentage_24h"
        case circulatingSupply = "circulating_supply"
        case totalSupply = "total_supply"
        case maxSupply = "max_supply"
        case athChangePercentage = "ath_change_percentage"
        case athDate = "ath_date"
        case atlChangePercentage = "atl_change_percentage"
        case atlDate = "atl_date"
        case lastUpdated = "last_updated"
    }
}

struct ROI: Codable {
    let times: Double
    let currency: String
    let percentage: Double
}
