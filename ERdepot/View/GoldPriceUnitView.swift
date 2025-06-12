//
//  GoldPriceUnitView.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/6/11.
//

import SwiftUI

struct GoldPriceUnitView: View {
    @Environment(\.colorScheme) var color
    @Environment(\.dismiss) var dismiss
    var body: some View {
        
        NavigationView {
            GeometryReader { geo in
                let width = geo.frame(in: .local).width * 0.95
                let height = geo.frame(in: .local).height
                    
                VStack {
                    
                    Spacer()
                        .frame(height: 30)
                    
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
