//
//  GoldPriceUnitView.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/6/11.
//

import SwiftUI

enum GoldPriceUnitEnum: String, CaseIterable, Identifiable {
    case perGram = "per gram"
    case perKilogram = "per kilogram"
    case perOunce = "per ounce"
    case perTola = "per tola"
    
    var id: String { self.rawValue }
}


struct GoldPriceUnitView: View {
    @Environment(\.colorScheme) var color
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appStorage: AppStorageManager
    
    var body: some View {
        
        NavigationView {
            GeometryReader { geo in
                let width = geo.frame(in: .local).width * 0.95
                let height = geo.frame(in: .local).height
                    
                VStack {
                    
                    Spacer()
                        .frame(height: 10)
                    
                    // 标题
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Gold price unit")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        Spacer()
                    }
                    
                    Spacer()
                        .frame(height: 30)
                    
                    VStack {
                        ForEach(GoldPriceUnitEnum.allCases) { item in
                            Button(action: {
                                appStorage.GoldPriceUnit = item
                            },label: {
                                HStack {
                                    Text(LocalizedStringKey(item.rawValue)).foregroundColor(color == .light ? .black : .white)
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .foregroundColor(color == .light ? Color(hex: "0742D2") : .white)
                                        .opacity(item == appStorage.GoldPriceUnit ? 1: 0)
                                }
                                .frame(height:24)
                            })
                            if item != GoldPriceUnitEnum.perTola {
                                Divider()
                            }
                        }
                    }
                    .padding(.vertical,10)
                    .padding(.horizontal,10)
                    .background(color == .light ? .white : Color(hex: "2f2f2f"))
                    .cornerRadius(10)
                    
                    Spacer()
                }
                .frame(width: width * 0.85)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
//        .navigationBarBackButtonHidden(true) // 隐藏返回按钮
    }
}

#Preview {
    GoldPriceUnitView()
        .environmentObject(IAPManager.shared)
        .environmentObject(AppStorageManager.shared)
    //        .environment(\.locale, .init(identifier: "de")) // 设置为阿拉伯语
}
