//
//  privacyPolicyPage.swift
//  ERdepot
//
//  Created by 方君宇 on 2024/10/16.
//

import SwiftUI

struct privacyPolicyPage: View {
    @Binding var privacyPolicy: Bool
    var body: some View {
        NavigationStack{
            Spacer()
                .frame(height: 60)
            Text("ERdepot")
                .font(.system(size: 48))
                .fontWeight(.semibold)
            Text("Privacy Policy")
                .font(.system(size: 48))
                .fontWeight(.semibold)
            Image("PrivacyPolicy")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
            Spacer()    // 分割空白
                .frame(height: 30)
            // 灰色文本解释部分
            VStack {
                // 汇率数据来源网络文字内容
                Text("The exchange rate data in this app comes from the Internet.")
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.center) // 设置文本居中对齐
                Spacer()    // 分割空白
                    .frame(height: 10)
                // 信息保存本机文字内容
                Text("The exchange rate and warehouse foreign exchange/foreign currency data in the app are saved locally on the device or stored in the cloud iCound.")
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.center) // 设置文本居中对齐
                Spacer()    // 分割空白
                    .frame(height: 10)
                // 不存储信息文字内容
                Text("We do not store any of your data.")
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray)
                Spacer()    // 分割空白
                    .frame(height: 10)
                // 隐私政策外链
                Link(String(localized: "Privacy Policy"),destination: URL(string: "https://fangjunyu.com/2024/10/16/%e6%b1%87%e7%8e%87%e4%bb%93%e5%ba%93-%e9%9a%90%e7%a7%81%e6%94%bf%e7%ad%96/")!)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#0097FE"))
                    .fontWeight(.semibold)
            }
            .containerRelativeFrame(.horizontal) { size, axis in size * 0.8 }   // 设置宽度
            Spacer()
                .frame(height: 50)
            Button{
                privacyPolicy = true
            } label: {
                Text("Start")
                    .foregroundColor(Color.white)
                    .font(.system(size: 22))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            // 点击按钮触觉反馈
            .contentShape(Rectangle())
            .sensoryFeedback(.increase, trigger: privacyPolicy)
            .frame(width: 312,height: 70)
            .background(Color(hex:"#0097FE"))
            .cornerRadius(8)
            Spacer()    // 全部内容上移
        }
        
        
    }
}

#Preview {
    privacyPolicyPage(privacyPolicy: .constant(true))
}
