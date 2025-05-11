//
//  StockIndex.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/5/11.
//

import SwiftUI
import CoreData

struct StockIndexView: View {
    
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
                    // 外币
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Stock index")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer().frame(height: 10)
                            Text("Nasdaq 100")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        VStack {
                            Image("stock")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70)
                        }
                    }
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
    StockIndexView(bindingSheet: .constant(true))
        .environmentObject(AppStorageManager.shared)
        .environment(\.managedObjectContext, CoreDataPersistenceController.shared.context) // 加载 NSPersistentContainer
}
