//
//  ExchangeRateChart.swift
//  ERdepot
//
//  Created by 方君宇 on 2025/4/21.
//

import SwiftUI

struct ExchangeRateChart: View {
    @State private var dragLocation: CGFloat? = nil
    @State private var selectedIndex: Int? = nil
    
    var dataPoints: [ExchangeRateChartPoint]
    
    // 格式化日期
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter.string(from: date)
    }
    
    var body: some View {
        
        if dataPoints.isEmpty {
            Image("isEmpty")
                .resizable()
                .scaledToFit()
        } else {
            let dataMax = dataPoints.map{ $0.totalValue}.max() ?? 0
            let dataMin = dataPoints.map{ $0.totalValue}.min() ?? 0
            
            // 计算最大和最小值
            let paddingRatio = 0.8 // 可以自由调整（比如上下额外 10% 高度）
            
            let dataRange = dataMax - dataMin
            let adjustedMax = dataMax + dataRange * paddingRatio
            let adjustedMin = dataMin - dataRange * paddingRatio
            
            let yAxisValues = stride(from: 0, through: 4, by: 1).map { i in
                adjustedMin + (Double(i) / 4.0) * (adjustedMax - adjustedMin)
            }.reversed() // 从大到小显示
            
            let firstDate = dataPoints.first?.date
            let middleDate = dataPoints[dataPoints.count / 2].date
            let lastDate = dataPoints.last?.date
            var endPoint:CGPoint = .zero
            VStack {
                
                Spacer().frame(height:10)
                HStack {
                    //  左侧 Y 轴数值
                    VStack {
                        ForEach(Array(yAxisValues.enumerated()),id:\.1) { index,value in
                            Text(String(format: "%.0f", value))
                                .font(.caption2)
                                .offset(y: -6)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    }
                    VStack {
                        GeometryReader { geo in
                            let width = geo.size.width
                            let height = geo.size.height
                            let spacing:CGFloat = 40
                            let spacingHeight = height - 2 * spacing
                            
                            ZStack {
                                Path { path in
                                    var origin:CGPoint = .zero
                                    
                                    for (index,data) in dataPoints.enumerated() {
                                        // X轴的各点
                                        let xPosition = CGFloat(index) / CGFloat(dataPoints.count - 1) * width
                                        // Y轴的数值 - 从底部开始计算，减去归一化的值
                                        let normalizedValue = (data.totalValue - dataMin) / (dataMax - dataMin)
                                        let yPosition = height - spacing -  (normalizedValue * spacingHeight)
                                        if index == 0 {
                                            origin = CGPoint(x: xPosition, y: yPosition)
                                            path.move(to: origin)
                                        } else {
                                            path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                                        }
                                    }
                                    path.addLine(to: CGPoint(x: width, y: height))
                                    path.addLine(to: CGPoint(x: 0, y: height))
                                    path.addLine(to: origin)
                                    path.closeSubpath() // 完成绘制
                                }
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "DDDDDD"), .clear]), // 渐变的颜色
                                        startPoint: .top, // 渐变的起始点
                                        endPoint: .bottom // 渐变的结束点
                                    )
                                )
                                
                                Path { path in
                                    for (index,data) in dataPoints.enumerated() {
                                        // X轴的各点
                                        let xPosition = CGFloat(index) / CGFloat(dataPoints.count - 1) * width
                                        // Y轴的数值 - 从底部开始计算，减去归一化的值
                                        let normalizedValue = (data.totalValue - dataMin) / (dataMax - dataMin)
                                        let spacing:CGFloat = 40
                                        let spacingHeight = height - 2 * spacing
                                        let yPosition = height - spacing -  (normalizedValue * spacingHeight)
                                        if index == 0 {
                                            path.move(to: CGPoint(x: xPosition, y: yPosition))
                                        } else {
                                            path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                                            if index == dataPoints.count - 1 {
                                                endPoint = CGPoint(x: xPosition, y: yPosition)
                                                print("endPoint:\(endPoint)")
                                            }
                                        }
                                    }
                                }
                                .stroke(Color.gray, lineWidth: 3)
                                
                                // 分割线
                                VStack {
                                    ForEach(0..<5, id:\.self) { item in
                                        Divider()
                                        if item != 4 {
                                            Spacer()
                                        }
                                    }
                                }
                                
                                // 垂直辅助线和浮动提示
                                if let dragLocation = dragLocation,
                                   let selectedIndex = selectedIndex{
                                    let selectedData = dataPoints[selectedIndex]
                                    let xPosition = CGFloat(selectedIndex) / CGFloat(dataPoints.count - 1) * width
                                    let normalizedValue = (selectedData.totalValue - dataMin) / (dataMax - dataMin)
                                    let yPosition = height - spacing -  (normalizedValue * spacingHeight)
                                    
                                    // 垂直线
                                    Path { path in
                                        path.move(to: CGPoint(x: xPosition, y: 0))
                                        path.addLine(to: CGPoint(x: xPosition, y: height))
                                    }
                                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 1, dash: [4]))
                                    
                                    // 圆点
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 8, height: 8)
                                        .position(x: xPosition, y: yPosition)
                                    
                                    // 提示框
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(formattedDate(selectedData.date))
                                            .font(.caption2)
                                            .bold()
                                        Text(String(format: "%.2f", selectedData.totalValue))
                                            .font(.caption2)
                                    }
                                    .padding(6)
                                    .background(Color.white)
                                    .cornerRadius(6)
                                    .shadow(radius: 2)
                                    .position(x: xPosition + 80 > width ? xPosition - 60 : xPosition + 60,
                                              y: yPosition < 40 ? yPosition + 30 : yPosition - 30)
                                } else {
                                    // 圆点
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: 8, height: 8)
                                            .position(endPoint)
                                            .offset(x:-2)
                                }
                            }
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let x = value.location.x
                                        dragLocation = x
                                        let index = Int(round(x / width * CGFloat(dataPoints.count - 1)))
                                        selectedIndex = max(0, min(index, dataPoints.count - 1))
                                    }
                                    .onEnded { _ in
                                        dragLocation = nil
                                        selectedIndex = nil
                                    }
                            )
                        }
                        .frame(height:120)
                        //  底部 X 轴时间标签
                        
                        HStack {
                            if let first = firstDate,
                               let last = lastDate {
                                Text(formattedDate(first))
                                Spacer()
                                if dataPoints.count > 2 {
                                    Text(formattedDate(middleDate))
                                    Spacer()
                                }
                                Text(formattedDate(last))
                            }
                        }
                        .font(.caption2)
                        .frame(height: 20)
                        .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}
#Preview {
    ZStack {
        Color.gray.opacity(0.5)
        ExchangeRateChart(dataPoints: ExchangeRateChartPoint.previewData)
            .padding(14)
            .frame(width: 300,height: 180)
            .background(.white)
            .cornerRadius(10)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.5)
        ExchangeRateChart(dataPoints: ExchangeRateChartPoint.previewData)
            .padding(14)
            .frame(width: 300,height: 180)
            .background(.white)
            .cornerRadius(10)
            .preferredColorScheme(.dark)
    }
}
