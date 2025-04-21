//
//  ExchangeRateChart.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/4/21.
//

import SwiftUI

struct ExchangeRateChart: View {
    var datas: [Double] = [0.22,0.24,0.36,0.27,0.33,0.5,0.44]
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            // 计算最大和最小值
            let dataMax = datas.max() ?? 0
            let dataMin = datas.min() ?? 0
            
            Path { path in
                for (index,data) in datas.enumerated() {
                    // X轴的各点
                    let xPosition = CGFloat(index) / CGFloat(datas.count - 1) * width
                    // Y轴的数值 - 从底部开始计算，减去归一化的值
                    let normalizedValue = (data - dataMin) / (dataMax - dataMin)
                    let yPosition = height - (normalizedValue * height)
                    if index == 0 {
                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                    } else {
                        path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                    }
                }
            }
            .stroke(Color.gray, lineWidth: 5)
        }
    }
}

#Preview {
    ExchangeRateChart()
        .frame(width: 350,height: 180)
        .border(.blue.opacity(0.3))
}
