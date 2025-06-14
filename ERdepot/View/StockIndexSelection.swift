//
//  StockIndexSelection.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/6/13.
//

import SwiftUI

enum stockMarketEnum: String, CaseIterable, Identifiable {
    case GSPC = "S&P 500"
    case NDX = "Nasdaq 100"
    case DJI = "Dow Jones Industrial Average"
    case N225 = "Nikkei 225"
    case HSI = "Hang Seng Index"
    case FTSE = "FTSE 100"
    case GDAXI = "DAX"
    case FCHI = "CAC 40"
    case SS = "Shanghai Composite Index"
    case SZ = "Shenzhen Component Index"
    
    var id: String { self.rawValue }
    
    var caseName: String {
        return String(describing: self)
    }
}


struct StockIndexSelectionView: View {
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
                            Text("Stock index")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        Spacer()
                    }
                    
                    Spacer()
                        .frame(height: 30)
                    
                    VStack {
                        ForEach(stockMarketEnum.allCases) { item in
                            Button(action: {
                                appStorage.stockMarket = item
                            },label: {
                                HStack {
                                    Text(LocalizedStringKey(item.rawValue)).foregroundColor(color == .light ? .black : .white)
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .foregroundColor(color == .light ? Color(hex: "0742D2") : .white)
                                        .opacity(item == appStorage.stockMarket ? 1: 0)
                                }
                                .frame(height:24)
                            })
                            if item != stockMarketEnum.SZ {
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
                .frame(width: width * 0.9)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(color == .light ? Color(hex: "F3F3F3") : .black)
        }
//        .navigationBarBackButtonHidden(true) // 隐藏返回按钮
    }
}

#Preview {
    StockIndexSelectionView()
        .environmentObject(IAPManager.shared)
        .environmentObject(AppStorageManager.shared)
    //        .environment(\.locale, .init(identifier: "de")) // 设置为阿拉伯语
}

