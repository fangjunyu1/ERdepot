//
//  Countrys.swift
//  ERdepot
//
//  Created by 方君宇 on 2024/10/15.
//

import Foundation

struct Countrys {
    var countryList: [String] = []
    
    init() {
        // 获取文件数据
        if let url = Bundle.main.url(forResource: "countries", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decodedCountries = try JSONDecoder().decode([String].self, from: data)
                self.countryList = decodedCountries
                print("Access to decode countries.")
            } catch {
                print("Failed to decode countries: \(error.localizedDescription)")
            }
        }
    }
}
