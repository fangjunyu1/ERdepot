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
    let currentPrice: Double
    let marketCap: Int
    let marketCapRank: Int
    let totalVolume: Int
    let priceChangePercentage24h: Double
    let lastUpdated: Date

    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case totalVolume = "total_volume"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case lastUpdated = "last_updated"
    }
}
