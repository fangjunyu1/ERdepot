//
//  ChangeCurrencyView.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/4/6.
//

import SwiftUI

struct ChangeCurrencyView: View {
    @Environment(\.colorScheme) var color
    @EnvironmentObject var appStorage: AppStorageManager
    @Binding var isShowChangeCurrency: Bool
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
                        isShowChangeCurrency = false
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
            }
            .frame(width: width * 0.85)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    }
}

#Preview {
    ChangeCurrencyView(isShowChangeCurrency: .constant(true))
        .environmentObject(AppStorageManager.shared)
}
