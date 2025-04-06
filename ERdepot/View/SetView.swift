//
//  SetView.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/4/6.
//

import SwiftUI

struct SetView: View {
    @Environment(\.colorScheme) var color
    @EnvironmentObject var appStorage: AppStorageManager
    @Binding var isShowSet: Bool
    
    func sendEmail() {
            let email = "fangjunyu.com@gmail.com"
            let subject = "ERdepot Problem Feedback"
            let body = "Hi fangjunyu,\n\n"
            
            // URL 编码参数
            let urlString = "mailto:\(email)?subject=\(subject)&body=\(body)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            if let url = URL(string: urlString ?? "") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                } else {
                    // 处理无法打开邮件应用的情况
                    print("Cannot open Mail app.")
                }
            }
        }
    
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
                        isShowSet = false
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
                // 设置
                HStack {
                    VStack(alignment: .leading) {
                        Text("Settings")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer().frame(height: 10)
                        Text("Manage various configurations")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    VStack {
                        Image("gear")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70)
                    }
                    
                }
                Spacer().frame(height: 30)
                // 赞助应用
                HStack{
                    // 内购按钮
                    Button(action: {
                        
                    }, label: {
                        VStack(spacing: 6) {
                            Text("Sponsored apps")
                                .fontWeight(.bold)
                            Text("¥ 1")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "53AEC8"), Color(hex: "6482DC")]), // 渐变的颜色
                                        startPoint: .topLeading, // 渐变的起始点
                                        endPoint: .bottomTrailing // 渐变的结束点
                                    )
                                    .cornerRadius(10)
                        )
                    })
                    Spacer().frame(width: 20)
                    Image("success")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100,height: 100)
                }
                Spacer().frame(height: 30)
                // 数据来源，问题反馈，使用条款，隐私政策
                Group  {
                    // 数据来源
                    Link(destination: URL(string: "https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html")!, label: {
                        HStack {
                            Text("Data sources")
                                .fontWeight(.medium)
                                .tint(.black)
                            Spacer()
                            Text("European Central Bank")
                                .foregroundColor(.gray)
                        }
                    })
                    
                    // 问题反馈
                    Button(action: {
                        sendEmail()
                    }, label: {
                        HStack {
                            Text("Issue feedback")
                                .fontWeight(.medium)
                                .tint(.black)
                            Spacer()
                            Text("Email")
                                .foregroundColor(.gray)
                        }
                    })
                    
                    // 使用条款
                    Link(destination: URL(string: "https://fangjunyu.com/2024/10/16/%e6%b1%87%e7%8e%87%e4%bb%93%e5%ba%93-%e4%bd%bf%e7%94%a8%e6%9d%a1%e6%ac%be/")!, label: {
                        HStack {
                            Text("Terms of use")
                                .fontWeight(.medium)
                                .tint(.black)
                            Spacer()
                            Text("Webpage")
                                .foregroundColor(.gray)
                        }
                    })
                    
                    // 隐私政策
                    Link(destination: URL(string: "https://fangjunyu.com/2024/10/16/%e6%b1%87%e7%8e%87%e4%bb%93%e5%ba%93-%e9%9a%90%e7%a7%81%e6%94%bf%e7%ad%96/")!, label: {
                        HStack {
                            Text("Privacy Policy")
                                .fontWeight(.medium)
                                .tint(.black)
                            Spacer()
                            Text("Webpage")
                                .foregroundColor(.gray)
                        }
                    })
                    
                }
                .padding(.vertical,16)
                .padding(.horizontal,14)
                .background(Color(hex: "ECECEC"))
                .cornerRadius(10)
                Spacer()
            }
            .frame(width: width * 0.85)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    }
}

#Preview {
    SetView(isShowSet: .constant(true))
        .environmentObject(AppStorageManager.shared)
}
