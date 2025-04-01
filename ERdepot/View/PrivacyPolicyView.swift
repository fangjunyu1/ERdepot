//
//  PrivacyPolicyView.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/3/31.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Binding var ViewSteps: Int
    @Environment(\.colorScheme) var color
    @EnvironmentObject var appStorage:AppStorageManager
    var body: some View {
        GeometryReader { geo in
            let width = geo.frame(in: .global).width * 0.95
            VStack {
                Spacer().frame(height: 50)
                Text("Privacy Statement")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                    .frame(height: 30)
                Image("PrivacyPolicy")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                Spacer()
                    .frame(height: 30)
                // 隐私备注
                VStack {
                    Text("The exchange rate data in this app comes from the Internet.")
                    Spacer()
                        .frame(height: 20)
                    Text("The exchange rate and warehouse foreign exchange/foreign currency data in the app are saved locally on the device or stored in the cloud iCound.")
                    Spacer()
                        .frame(height: 20)
                    Text("We do not store any of your data.")
                }
                .foregroundColor(.gray)
                .font(.footnote)
                .multilineTextAlignment(.center)
                Spacer()
                    .frame(height: 30)
                Link(destination: URL(string: "https://fangjunyu.com/2024/10/16/%e6%b1%87%e7%8e%87%e4%bb%93%e5%ba%93-%e9%9a%90%e7%a7%81%e6%94%bf%e7%ad%96/")!) {
                    Text("Privacy Policy")
                        .tint(color == .light ? .black : .white)
                        .font(.footnote)
                }
                Spacer()
                    .frame(height: 50)
                Button(action: {
                    // 跳转到隐私视图
                    appStorage.isInit = true
                }, label: {
                    Text("Continue")
                        .fontWeight(.bold)
                        .padding(.vertical,16)
                        .padding(.horizontal,80)
                        .foregroundColor(color == .light ? .white : .black)
                        .background(color == .light ? .black : .white)
                        .cornerRadius(6)
                })
                Spacer()
            }
            .frame(width: width)
            .frame(maxWidth: .infinity,maxHeight: .infinity)
        }
    }
}

#Preview {
    PrivacyPolicyView(ViewSteps: .constant(1))
        .environmentObject(AppStorageManager.shared)
}
