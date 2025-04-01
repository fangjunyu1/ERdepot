//
//  WelcomeView.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/3/31.
//

import SwiftUI

struct WelcomeView: View {
    @State private var offsets: [CGFloat] = [-3100, -3600]
    let animationDuration: Double = 120
    @Binding var ViewSteps: Int
    @Environment(\.colorScheme) var color
    let countrys = [
        ["AED","AUD","CAD","CHF","DKK","EUR","GBP","HKD","HUF","JPY","KRW","MOP","MXN","MYR","NOK","NZD","PLN","RUB","SAR","SEK","SGD","THB","TRY","USD","ZAR"],
        ["MXN","MYR","NOK","NZD","PLN","RUB","SAR","SEK","SGD","THB","TRY","USD","ZAR","AED","AUD","CAD","CHF","DKK","EUR","GBP","HKD","HUF","JPY","KRW","MOP"]
    ]
    
    func startAnimation() {
        withAnimation(Animation.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
            offsets = [0,0]
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.frame(in: .global).width * 0.95
            VStack {
                Spacer().frame(height: 50)
                // 设置最大宽度
                VStack {
                    Text("Welcome")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                        .frame(height: 30)
                    Text("ERdepot")
                        .fontWeight(.bold)
                        .padding(.vertical,8)
                        .padding(.horizontal,50)
                        .foregroundColor(color == .light ? .white : .black)
                        .background(color == .light ? .black : .white)
                        .cornerRadius(4)
                    Spacer().frame(height: 30)
                    Image("welcome")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240)
                    
                    Spacer().frame(height: 30)
                    // 介绍文字
                    VStack {
                        Text("We provide free exchange rate data.")
                        Spacer().frame(height: 20)
                        Text("Track historical foreign exchange rate trends.")
                    }
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .font(.footnote)
                }
                .frame(maxWidth: width)
                Spacer().frame(height: 30)
                ForEach(0..<2) { item in
                    HStack {
                        ForEach(0..<2) { _ in
                            ForEach(countrys[item],id: \.self) { country in
                                Image("\(country)")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100)
                                Text(LocalizedStringKey(country))
                                    .font(.footnote)
                                    .fixedSize()
                            }
                        }
                    }
                    .offset(x:offsets[item])
                    .frame(width: width,height: 30)
                    if item == 0 {
                        Spacer().frame(height: 30)
                    }
                }
                .onAppear {
                    startAnimation()
                }
                Spacer().frame(height: 30)
                // 设置最大宽度
                VStack {
                    Button(action: {
                        // 跳转到隐私视图
                        ViewSteps = 1
                    }, label: {
                        Text("Start")
                            .fontWeight(.bold)
                            .padding(.vertical,16)
                            .padding(.horizontal,80)
                            .foregroundColor(color == .light ? .white : .black)
                            .background(color == .light ? .black : .white)
                            .cornerRadius(6)
                    })
                }
                .frame(maxWidth: width)
                Spacer()
            }
            .frame(maxWidth: .infinity,maxHeight: .infinity)
        }
    }
}

#Preview {
    WelcomeView(ViewSteps: .constant(0))
}
