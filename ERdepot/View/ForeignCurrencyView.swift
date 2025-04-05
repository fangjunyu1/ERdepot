//
//  ForeignCurrencyView.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/4/5.
//

import SwiftUI

struct ForeignCurrencyView: View {
    @Environment(\.colorScheme) var color
    @EnvironmentObject var appStorage: AppStorageManager
    @Binding var isShowForeignCurrency: Bool
    @State private var textField: String = ""
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
                            isShowForeignCurrency = false
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
                            Text("Foreign currency")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer().frame(height: 10)
                            Text("Manage your foreign currency savings.")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        VStack {
                            Image("dollar")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70)
                        }
                        
                    }
                    Spacer()
                        .frame(height: 20)
                    ForEach(appStorage.listOfSupportedCurrencies, id: \.self) { currency in
                        // 国旗列表
                        HStack {
                            Image("\(currency)")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 36)
                                .cornerRadius(10)
                            Spacer().frame(width: 20)
                            VStack(alignment: .leading) {
                                Text("\(currency)" as String)
                                    .foregroundColor(.gray)
                                Spacer().frame(height: 4)
                                Text(LocalizedStringKey(currency))
                            }
                            .font(.caption2)
                            Spacer()
                            TextField("0.0", text: $textField)
                                .multilineTextAlignment(.trailing)
                                .padding(.leading,10)
                        }
                        .padding(.horizontal,20)
                        .frame(width: width * 0.85,height: 50)
                        .background(color == .light ? Color(hex: "ECECEC") : Color(hex: "2f2f2f"))
                        .cornerRadius(10)
                        Spacer()
                            .frame(height: 10)
                    }
                    Spacer()
                        .frame(height: 20)
                    // 其他
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Others")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer().frame(height: 10)
                        }
                        Spacer()
                    }
                    Spacer()
                        .frame(height: 40)
                }
                .frame(width: width * 0.85)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

#Preview {
    ForeignCurrencyView(isShowForeignCurrency: .constant(true))
        .environmentObject(AppStorageManager.shared)
}
