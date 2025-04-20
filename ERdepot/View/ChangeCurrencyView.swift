//
//  ChangeCurrencyView.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/4/6.
//

import SwiftUI

// 更换外币类型的枚举
enum CurrencySelectionType {
    case localCurrency
    case convertCurrency(index: Int) // 可传入需要更换的下标
}

struct ChangeCurrencyView: View {
    @Environment(\.colorScheme) var color
    @EnvironmentObject var appStorage: AppStorageManager
    @Environment(\.dismiss) var dismiss
    @Binding var isShowChangeCurrency: Bool
    
    let selectionType: CurrencySelectionType
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.frame(in: .global).width * 0.95
            let height = geo.frame(in: .global).height
            ScrollView(showsIndicators: false) {
            VStack {
                Spacer()
                    .frame(height: 30)
                HStack {
                    // 返回箭头
                    Button(action: {
                        // isShowChangeCurrency = false
                        dismiss()
                    }, label: {
                        if #available(iOS 16.0, *) {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24,height: 24)
                                .fontWeight(.bold)
                                .foregroundColor(color == .light ? .black : .white)
                        } else {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24,height: 24)
                                .foregroundColor(color == .light ? .black : .white)
                        }
                    })
                    Spacer()
                }
                Spacer().frame(height: 24)
                // 外币
                HStack {
                    VStack(alignment: .leading) {
                        Text("Change Currency")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer().frame(height: 10)
                        Text("Change the current currency.")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    VStack {
                        Image("banknotes")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70)
                    }
                }
                Spacer().frame(height:20)
                ForEach(appStorage.listOfSupportedCurrencies, id: \.self) {
                    currency in
                        // 国旗列表
                        HStack {
                            Image("\(currency)")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 36)
                                .cornerRadius(10)
                            Spacer().frame(width: 20)
                            VStack(alignment: .leading) {
                                Text(verbatim:"\(currency)")
                                    .foregroundColor(.gray)
                                Spacer().frame(height: 4)
                                Text(LocalizedStringKey(currency))
                            }
                            .font(.caption2)
                            Spacer()
                            switch selectionType {
                            case .localCurrency:
                                if currency == appStorage.localCurrency {
                                    Image(systemName: "checkmark.circle.fill")
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(Color(hex: "969696"))
                                }
                            case .convertCurrency(let index):
                                if currency == appStorage.convertForeignCurrency[index] {
                                    Image(systemName: "checkmark.circle.fill")
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(Color(hex: "969696"))
                                }
                            }
                            
                        }
                        .padding(.horizontal,20)
                        .frame(width: width * 0.85,height: 50)
                        .background(color == .light ? Color(hex: "ECECEC") : Color(hex: "2f2f2f"))
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .cornerRadius(10)
                        .onTapGesture {
                            switch selectionType {
                            case .localCurrency:
                                appStorage.localCurrency = currency
                            case .convertCurrency(let index):
                                appStorage.convertForeignCurrency[index] = currency
                            }
                        }
                        Spacer()
                            .frame(height: 10)
                }
            }
            .frame(width: width * 0.85)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
        .onAppear {
            print("selectionType:\(selectionType)")
        }

    }
}

#Preview {
    ChangeCurrencyView(isShowChangeCurrency: .constant(true), selectionType: .convertCurrency(index: 2))
        .environmentObject(AppStorageManager.shared)
}
