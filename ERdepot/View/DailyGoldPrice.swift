//
//  DailyGoldPrice.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/5/11.
//

import SwiftUI
import CoreData

struct DailyGoldPriceView: View {
    
    @Environment(\.colorScheme) var color
    @EnvironmentObject var appStorage: AppStorageManager
    @Binding var bindingSheet: Bool
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.frame(in: .local).width * 0.95
            let height = geo.frame(in: .local).height
            ScrollView(showsIndicators: false) {
                VStack {
                    Spacer()
                        .frame(height: 30)
                    HStack {
                        // 返回箭头
                        Button(action: {
                            bindingSheet = false
                        }, label: {
                            if #available(iOS 16.0, *) {
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24,height: 24)
                                    .fontWeight(.bold)
                                    .foregroundColor(color == .light ? .black : .white)
                            } else {
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24,height: 24)
                                    .foregroundColor(color == .light ? .black : .white)
                            }
                        })
                        Spacer()
                    }
                    Spacer().frame(height: 24)
                    // 每日金价
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Daily gold price")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer().frame(height: 10)
                            Text("Gold futures")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        VStack {
                            Image("gold")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70)
                        }
                    }
                    Spacer()
                        .frame(height: 20)
                    VStack(alignment: .leading) {
                        Text(LocalizedStringKey(appStorage.GoldPriceUnit))
                            .foregroundColor(.gray)
                            .font(.caption2)
                        Spacer().frame(height: 5)
                        HStack {
                            Text("\(currencySymbols[appStorage.localCurrency] ?? "$")")
                                .fontWeight(.medium)
                            Text("711.33")
                                .fontWeight(.bold)
                        }
                        .font(.largeTitle)
                    }
                    Spacer()
                        .frame(height: 20)
                    
                    
                    HStack {
                        Spacer()
                    }
                    .padding(.horizontal,20)
                    .frame(width: width * 0.85,height: 50)
                    .background(color == .light ? Color(hex: "ECECEC") : Color(hex: "2f2f2f"))
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .cornerRadius(10)
                    
                    
                    Spacer()
                        .frame(height: 30)
                    VStack {
                        HStack {
                            Text("Data source")
                            Text("Yahoo Finance")
                        }
                        .foregroundColor(.gray)
                        .font(.caption2)
                        Spacer().frame(height: 5)
                        HStack {
                            Text("Update time")
                            Text(appStorage.GoldlastUpdateDate,format: Date.FormatStyle.dateTime)
                        }
                    }
                    .foregroundColor(.gray)
                    .font(.caption2)
                    
                    Spacer()
                        .frame(height: 20)
                }
                .frame(width: width * 0.85)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}


#Preview {
    // 清理必须放在 return 之前！
//        if let bundleID = Bundle.main.bundleIdentifier {
//            UserDefaults.standard.removePersistentDomain(forName: bundleID)
//        }
    DailyGoldPriceView(bindingSheet: .constant(true))
        .environmentObject(AppStorageManager.shared)
        .environment(\.managedObjectContext, CoreDataPersistenceController.shared.context) // 加载 NSPersistentContainer
}
