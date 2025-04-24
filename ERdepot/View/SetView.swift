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
    @State private var endOfWait = false    // 为true时，显示结束等待按钮
    @EnvironmentObject var iapManager: IAPManager
    
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
                    // 赞助应用
                    if !appStorage.isInAppPurchase {
                        Spacer().frame(height: 30)
                        HStack{
                            // 内购按钮
                            Button(action: {
                                if !iapManager.products.isEmpty {
                                    iapManager.loadPurchased = true // 显示加载动画
                                    // 将商品分配给一个变量
                                    let productToPurchase = iapManager.products[0]
                                    // 分开调用购买操作
                                    iapManager.purchaseProduct(productToPurchase)
                                    // 当等待时间超过20秒时，显示结束按钮
                                    Task {
                                        try? await Task.sleep(nanoseconds: 20_000_000_000) // 延迟 20 秒
                                        endOfWait = true
                                    }
                                } else {
                                    print("products为空")
                                    Task {
                                        await iapManager.loadProduct()   // 加载产品信息
                                    }
                                }
                                
                            }, label: {
                                VStack(spacing: 6) {
                                    Text("Sponsored apps")
                                        .fontWeight(.bold)
                                    if !iapManager.products.isEmpty {
                                        Text("\(iapManager.products.first?.displayPrice ?? "N/A")")
                                            .fontWeight(.bold)
                                            .font(.footnote)
                                    } else {
                                        Text("$ --")
                                            .font(.footnote)
                                            .fontWeight(.bold)
                                    }
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
                            VStack {
                                Image("success")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60,height: 60)
                                // 恢复内购按钮
                                Button(action: {
                                    // 调用恢复内购代码
                                    Task {
                                        await iapManager.restorePurchases()
                                        
                                        // 主线程更新 loadPurchased 和 endOfWait
                                        DispatchQueue.main.async {
                                            iapManager.loadPurchased = false // 结束加载动画
                                        }
                                        
                                        try? await Task.sleep(nanoseconds: 20_000_000_000) // 延迟 20 秒
                                        DispatchQueue.main.async {
                                            endOfWait = true // 主线程更新 endOfWait
                                        }
                                    }
                                    DispatchQueue.main.async {
                                        iapManager.loadPurchased = true // 显示加载动画
                                    }
                                }, label: {
                                    Text("Restore Purchases")
                                        .font(.caption2)
                                        .frame(width: 100,height: 30)
                                        .foregroundColor(.white)
                                        .background(Color(hex: "A4A225"))
                                        .cornerRadius(10)
                                })
                            }
                        }
                    }
                    
                    Spacer().frame(height: 30)
                    // 数据来源，问题反馈，使用条款，隐私政策
                    Group  {
                        // 数据来源
                        Link(destination: URL(string: "https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html")!, label: {
                            HStack {
                                Text("Data sources")
                                    .fontWeight(.medium)
                                    .tint(color == .light ? .black : .white)
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
                                    .tint(color == .light ? .black : .white)
                                Spacer()
                                Text("E-mail")
                                    .foregroundColor(.gray)
                            }
                        })
                        
                        // 使用条款
                        Link(destination: URL(string: "https://fangjunyu.com/2024/10/16/%e6%b1%87%e7%8e%87%e4%bb%93%e5%ba%93-%e4%bd%bf%e7%94%a8%e6%9d%a1%e6%ac%be/")!, label: {
                            HStack {
                                Text("Terms of use")
                                    .fontWeight(.medium)
                                    .tint(color == .light ? .black : .white)
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
                                    .tint(color == .light ? .black : .white)
                                Spacer()
                                Text("Webpage")
                                    .foregroundColor(.gray)
                            }
                        })
                        
                        // 开源
                        Link(destination: URL(string: "https://github.com/fangjunyu1/ERdepot")!, label: {
                            HStack {
                                Text("Open Source")
                                    .fontWeight(.medium)
                                    .tint(color == .light ? .black : .white)
                                Spacer()
                                Text("GitHub")
                                    .foregroundColor(.gray)
                            }
                        })
                        
                        // 鸣谢
                        HStack {
                            Text("Acknowledgements")
                                .fontWeight(.medium)
                                .foregroundColor(color == .light ? .black : .white)
                            Spacer()
                            Text("Freepik")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical,16)
                    .padding(.horizontal,14)
                    .background(color == .light ? Color(hex: "ECECEC") : Color(hex: "2f2f2f"))
                    .cornerRadius(10)
                    Spacer()
                        .frame(height: 30)
                    HStack(spacing:2) {
                        Text("Version")
                        Text(":")
                        Text("\(Bundle.main.appVersion).\(Bundle.main.appBuild)")
                    }
                    .foregroundColor(.gray)
                    .font(.caption)
                    Spacer()
                }
                .frame(width: width * 0.85)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        
        .overlay {
            if iapManager.loadPurchased == true {
                ZStack {
                    Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
                    VStack {
                        // 加载条
                        ProgressView("loading...")
                        // 加载条修饰符
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                            .background(color == .dark ? Color(hex: "2f2f2f") : Color.white)
                            .cornerRadius(10)
                            .overlay {
                                // 当等待时间超过10秒时显示结束
                                if endOfWait == true {
                                    Button(action: {
                                        iapManager.loadPurchased = false
                                    }, label: {
                                        Text("End of the wait")
                                            .foregroundStyle(.red)
                                            .frame(width: 100,height: 30)
                                            .background(color == .dark ? Color(hex: "3f3f3f") : Color.white)
                                            .cornerRadius(10)
                                    })
                                    .offset(y:60)
                                }
                            }
                        
                    }
                }
            }
        }
        
    }
}

#Preview {
    SetView(isShowSet: .constant(true))
        .environmentObject(IAPManager.shared)
        .environmentObject(AppStorageManager.shared)
        .environment(\.locale, .init(identifier: "de")) // 设置为阿拉伯语
}
#Preview {
    SetView(isShowSet: .constant(true))
        .environmentObject(IAPManager.shared)
        .environmentObject(AppStorageManager.shared)
        .preferredColorScheme(.dark)
        .environment(\.locale, .init(identifier: "de")) // 设置为阿拉伯语
}
