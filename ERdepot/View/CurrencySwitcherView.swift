//
//  CurrencySwitcherView.swift
//  ERdepot
//
//  Created by 方君宇 on 2024/10/27.
//

import SwiftUI

struct CurrencySwitcherView: View {
    @Binding var selectedCurrency: String?
    @Binding var selectedIndexCurrency: Int
    @StateObject var exchangeRate = ExchangeRate.ExchangeRateExamples
    @Environment(\.colorScheme) var mode
    
    var body: some View {
        NavigationStack {
            // 在这里添加你的币种选择器视图
            List {
                ForEach(Array(exchangeRate.ExchangeRateStructInfo.exchangeRates.keys).sorted(),id: \.self) { keys in
                        Button(action: {
                            selectedCurrency = keys
                            exchangeRate.CommonCurrencies[selectedIndexCurrency] = keys
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
                                if keys == selectedCurrency {
                                    Image(systemName: "checkmark")
                                }
                            }
                        })
                        .foregroundColor(mode == .dark ? Color.white : Color.black)
                }
            }
            .navigationTitle(String(localized: "Switching Currency"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CurrencySwitcherView(selectedCurrency: .constant(""), selectedIndexCurrency: .constant(1))
}
