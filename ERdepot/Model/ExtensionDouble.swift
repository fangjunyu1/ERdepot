//
//  ExtensionDouble.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/4/15.
//

import Foundation

extension Double {
    func formattedWithTwoDecimalPlaces() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "0.00"
    }
}
