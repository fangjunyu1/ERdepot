//
//  SwitchCurrentCurrency.swift
//  ERdepot
//
//  Created by 方君宇 on 2024/10/27.
//

import SwiftUI

struct SwitchCurrentCurrency: View {
    
    @StateObject private var exchangeRate = ExchangeRate.ExchangeRateExamples
    @Environment(\.colorScheme) var mode
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(exchangeRate.ExchangeRateStructInfo.exchangeRates.keys).sorted(),id: \.self) { keys in
                        Button(action: {
                            exchangeRate.ExchangeRateCurrencyConversion = keys
                            exchangeRate.calculaterReserveAmount()
                        }, label: {
                            HStack{
                                Image(keys)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30)
                                Text(LocalizedStringKey(keys))
                                Text(keys)
                                Spacer()
                                if exchangeRate.ExchangeRateCurrencyConversion == keys {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .foregroundColor(mode == .dark ? Color.white : Color.black)
                        })
                }
            }
        }
        .navigationTitle("Switch current currency")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SwitchCurrentCurrency()
}
