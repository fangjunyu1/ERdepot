//
//  Settings.swift
//  ERdepot
//
//  Created by 方君宇 on 2024/10/18.
//

import SwiftUI
import UIKit
import MessageUI
struct Settings: View {
    @State private var mailResult: MFMailComposeResult?
    @ObservedObject var shared = IAPManager.shared
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var mode
    @State var path = NavigationPath()
    @ObservedObject private var exchangeRate = ExchangeRate.ExchangeRateExamples
    @ObservedObject private var language = LanguageManager.shared
    
    // 获取应用的版本号
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    // 发送邮件信息
    func sendEmail() {
        let email = "fangjunyu.com@gmail.com"
        let subject = "Feedback"
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
        NavigationStack(path: $path){
            VStack(spacing: 0) {
                Spacer().frame(height: 30)
                // 赞助应用
                VStack {
                    if UserDefaults.standard.bool(forKey: shared.productID[0]) {
                        HStack{
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 26))
                                .foregroundColor(mode == .dark ? Color.white : Color(hex: "0097FE"))
                            Text("Thanks for your support")
                                .padding(.horizontal,10)
                                .foregroundColor(mode == .dark ? Color.white : Color(hex: "0097FE"))
                            Spacer()
                            Image(systemName: "chevron.compact.forward")
                                .foregroundColor(Color(hex:"C1C1C1"))
                                .opacity(0)
                        }
                    }
                    else {
                        HStack{
                            Image(systemName: "checkmark.seal")
                                .font(.system(size: 26))
                            Text("Sponsored apps")
                                .padding(.horizontal,10)
                            Spacer()
                            Image(systemName: "chevron.compact.forward")
                                .foregroundColor(Color(hex:"C1C1C1"))
                        }
                        .contentShape(Rectangle()) // 扩展点击区域
                        .onTapGesture {
                            if !shared.products.isEmpty {
                                shared.loadPurchased = true // 显示加载动画
                                // 将商品分配给一个变量
                                let productToPurchase = shared.products[0]
                                // 分开调用购买操作
                                shared.purchaseProduct(productToPurchase)
                            } else {
                                print("products为空")
                                Task {
                                    await shared.loadProduct()   // 加载产品信息
                                }
                            }
                        }
                    }
                }
                .padding(.vertical,14)
                .padding(.horizontal,20)
                .background(mode == .dark ? Color(hex:"939393") : Color.white)
                .cornerRadius(8)
                .containerRelativeFrame(.horizontal) { size, axis in size * 0.85 }
                
                
                // 赞助应用和当前货币的间距
                Spacer().frame(height: 20)
                
                // 当前货币、语言版本、数据来源外层
                VStack(spacing: 0) {
                    // 当前货币
                    NavigationLink(destination: {
                        SwitchCurrentCurrency()
                    }, label: {
                        VStack {
                            HStack{
                                Image(systemName: "dollarsign.circle")
                                    .font(.system(size: 26))
                                Text("Current currency")
                                    .padding(.horizontal,10)
                                Spacer()
                                Text(LocalizedStringKey(exchangeRate.ExchangeRateCurrencyConversion))
                                    .font(.system(size: 14))
                                    .padding(.horizontal,10)
                                Image(systemName: "chevron.compact.forward")
                                    .foregroundColor(Color(hex:"C1C1C1"))
                            }
                        }
                        .padding(.vertical,14)
                    })
                    .buttonStyle(.plain)
                    Divider()       // 分割线
                        .padding(.leading, 50)
                    
                    // 语言版本
                    NavigationLink(destination: {
                        SwitchLanague()
                    }, label: {
                        VStack {
                            HStack{
                                Image(systemName: "speaker.wave.2.bubble")
                                    .font(.system(size: 26))
                                Text("language version")
                                    .padding(.horizontal,10)
                                Spacer()
                                Text(LocalizedStringKey(language.getCurrentLanguageName()))
                                    .font(.system(size: 14))
                                    .padding(.horizontal,10)
                                Image(systemName: "chevron.compact.forward")
                                    .foregroundColor(Color(hex:"C1C1C1"))
                            }
                        }
                        .padding(.vertical,14)
                    })
                    .buttonStyle(.plain) // 取消默认颜色样式
                    Divider()       // 分割线
                        .padding(.leading, 50)
                    // 数据来源
                    VStack {
                        HStack{
                            Image(systemName: "link.circle")
                                .font(.system(size: 26))
                            Text("Data sources")
                                .padding(.horizontal,10)
                            Spacer()
                            Text("A certain foreign exchange market")
                                .font(.system(size: 14))
                                .padding(.horizontal,10)
                            Image(systemName: "chevron.compact.forward")
                                .foregroundColor(Color(hex:"C1C1C1"))
                                .opacity(0) // 因目前无法切换数据源，右边改为透明
                        }
                    }
                    .padding(.vertical,14)
                }
                .padding(.horizontal,20)
                .background(mode == .dark ? Color(hex:"939393") : Color.white)
                .cornerRadius(8)
                .containerRelativeFrame(.horizontal) { size, axis in size * 0.85 }
                Spacer().frame(height: 20)
                // 问题反馈、使用条款、隐私政策外层
                VStack(spacing: 0) {
                    // 问题反馈
                    VStack{
                        HStack{
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 26))
                            Text("Issue feedback")
                                .padding(.horizontal,10)
                            Spacer()
                            Image(systemName: "chevron.compact.forward")
                                .foregroundColor(Color(hex:"C1C1C1"))
                        }
                    }
                    .padding(.vertical,14)
                    .contentShape(Rectangle()) // 扩展点击区域
                    .onTapGesture {
                        sendEmail()
                    }
                    Divider()       // 分割线
                        .padding(.leading, 50)
                    // 使用条款
                    VStack {
                        HStack{
                            Image(systemName: "book.pages")
                                .font(.system(size: 26))
                            Text("Terms of use")
                                .padding(.horizontal,10)
                            Spacer()
                            Image(systemName: "chevron.compact.forward")
                                .foregroundColor(Color(hex:"C1C1C1"))
                        }
                    }
                    .padding(.vertical,14)
                    .contentShape(Rectangle()) // 扩展点击区域
                    .onTapGesture {
                        if let url = URL(string: "https://fangjunyu.com/2024/10/16/%e6%b1%87%e7%8e%87%e4%bb%93%e5%ba%93-%e4%bd%bf%e7%94%a8%e6%9d%a1%e6%ac%be/") {
                            UIApplication.shared.open(url)
                        }
                    }
                    Divider()       // 分割线
                        .padding(.leading, 50)
                    // 隐私政策
                    VStack {
                        HStack{
                            Image(systemName: "hand.raised.app")
                                .font(.system(size: 26))
                            Text("Privacy Policy")
                                .padding(.horizontal,10)
                            Spacer()
                            Image(systemName: "chevron.compact.forward")
                                .foregroundColor(Color(hex:"C1C1C1"))
                        }
                    }
                    .padding(.vertical,14)
                    .contentShape(Rectangle()) // 扩展点击区域
                    .onTapGesture {
                        if let url = URL(string: "https://fangjunyu.com/2024/10/16/%e6%b1%87%e7%8e%87%e4%bb%93%e5%ba%93-%e9%9a%90%e7%a7%81%e6%94%bf%e7%ad%96/") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                .padding(.horizontal,20)
                .background(mode == .dark ? Color(hex:"939393") : Color.white)
                .cornerRadius(8)
                .containerRelativeFrame(.horizontal) { size, axis in size * 0.85 }
                
                Spacer().frame(height: 50)
                // 版本号和备案号
                VStack {
                    HStack{
                        Text("Version")
                        Text(":")
                        Text(appVersion)
                    }
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "C1C1C1"))
                    Spacer().frame(height: 10)
                    Text("FilingInfo")
                        .foregroundColor(Color(hex: "C1C1C1"))
                        .font(.system(size: 12))
                }
                // 顶起整个空白区域
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // 使背景颜色填充整个屏幕
            .background(mode == .dark ? Color(hex:"5F5F5F") : Color(hex:"#F0F0F0")) // 应用背景颜色到 VStack
            .navigationTitle(Text("Settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "arrow.down.to.line")
                            .padding(.leading,30)
                            .foregroundColor(mode == .dark ? Color.white : Color(hex: "0097FE"))
                    })
                }
            }
        }
        .overlay(
            // 加载内购商品动画层
            Group {
                if shared.loadPurchased {
                    ZStack {
                        // 遮罩层
                        Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
                        VStack {
                            // 加载条
                            ProgressView("loading...")
                            // 加载条修饰符
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                                .background(mode == .dark ? Color(hex: "A8AFB3") : Color.white)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            
        )
    }
}


#Preview {
    Settings(path: NavigationPath())
}

