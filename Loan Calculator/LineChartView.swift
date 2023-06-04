//
//  LineChartView.swift
//  Loan Calculator
//
//  Created by František Moucha on 04.06.2023.
//

import Foundation
import SwiftUI

struct LineChartView: View {
    let dataSets: [[Double]]
    let lineColors: [Color]
    
    var sortedDataSets: [[Double]] {
        let sortedData1 = dataSets[0].sorted()
        let sortedData2 = dataSets[1].sorted(by: >)
        return [sortedData1, sortedData2]
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack(spacing: 0) {
                    Spacer(minLength: geometry.size.width * 0.25) // Add spacer on the left side
                    
                    VStack(spacing: 0) {
                        ZStack {
                            ForEach(sortedDataSets.indices) { index in
                                LineMarks(dataPoints: sortedDataSets[index], lineColor: lineColors[index])
                                    .frame(width: UIScreen.main.bounds.height * 0.35, height: geometry.size.height) // Adjust the height to fit the frame
                            }
                            
                            Legend(lineColor: lineColors[0], label: "Interest") // Add legend
                                .position(x: 30, y: (geometry.size.height/2) - 15)
                            Legend(lineColor: lineColors[1], label: "Mortgage") // Add legend
                                .position(x: 30, y: (geometry.size.height/2) + 15)
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: geometry.size.width * 0.25) // Add spacer on the right side
                    }
                }
                .padding(.horizontal, geometry.size.width * 0.25) // Add horizontal padding to center the chart
            }
            .frame(height: geometry.size.height)
            .padding(.top, 60)
            .padding(.leading, -160)
        }
        .onAppear {
            dataPrint(_dataSets: sortedDataSets)
        }
    }
}

struct Legend: View {
    let lineColor: Color
    let label: String
    var body: some View {
        HStack(spacing: 8) {
         
                Circle()
                    .fill(lineColor)
                    .frame(width: 10, height: 10)
                Text(label)
                    .font(.caption)
            
        }
    }
}

func dataPrint(_dataSets:[[Double]]){
    let sortedData1 = _dataSets[0].sorted()
    let sortedData2 = _dataSets[1].sorted(by: >)
    
    print(sortedData1)
    print(sortedData2)
}

struct LineMarks: View {
    let dataPoints: [Double]
    let lineColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(dataPoints.indices) { index in
                let x = CGFloat(index) * geometry.size.width / CGFloat(dataPoints.count - 1)
                let y = CGFloat(dataPoints[index]) * geometry.size.height / CGFloat(dataPoints.max() ?? 1)
                
                Circle()
                    .fill(lineColor)
                    .frame(width: 8, height: 8)
                    .position(x: x, y: y)
            }
        }
        .aspectRatio(contentMode: .fit)
    }
}
/*
struct LineChartView: View {
    let dataSets: [[Double]]
    let lineColors: [Color]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    Spacer()
                    ForEach(dataSets.indices) { index in
                        VStack(spacing: 0) {
                            Line(dataPoints: dataSets[index], lineColor: lineColors[index])
                            LineMarks(dataPoints: dataSets[index], lineColor: lineColors[index])
                        }
                        .frame(width: CGFloat(dataSets[index].count - 1) * geometry.size.width, height: 350)
                        .padding(.vertical, 20)
                        Spacer()
                    }
                }
            }
            .frame(height: 350)
        }
    }
}

struct Line: Shape {
    let dataPoints: [Double]
    let lineColor: Color
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard let maxDataPoint = dataPoints.max() else {
            return path
        }
        
        let xScale = rect.width / CGFloat(dataPoints.count - 1)
        let yScale = rect.height / CGFloat(maxDataPoint)
        
        path.move(to: CGPoint(x: 0, y: rect.height))
        
        for (index, dataPoint) in dataPoints.enumerated() {
            let x = CGFloat(index) * xScale
            let y = rect.height - CGFloat(dataPoint) * yScale
            
            if index == 0 {
                path.addLine(to: CGPoint(x: x, y: y))
            } else {
                let previousX = CGFloat(index - 1) * xScale
                let previousY = rect.height - CGFloat(dataPoints[index - 1]) * yScale
                let controlX = (previousX + x) / 2
                path.addQuadCurve(to: CGPoint(x: x, y: y), control: CGPoint(x: controlX, y: previousY))
            }
        }
        
        return path.strokedPath(StrokeStyle(lineWidth: 2, lineCap: .round))
    }
}

struct LineMarks: View {
    let dataPoints: [Double]
    let lineColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(dataPoints.indices) { index in
                let x = CGFloat(index) * geometry.size.width / CGFloat(dataPoints.count - 1)
                let y = CGFloat(dataPoints[index]) * geometry.size.height / CGFloat(dataPoints.max() ?? 1)
                
                Circle()
                    .fill(lineColor)
                    .frame(width: 8, height: 8)
                    .position(x: x, y: y)
            }
        }
        .aspectRatio(contentMode: .fit)
    }
}
*/

/*
struct LineChartView: View {
    let dataSets: [[Double]]
    let lineColors: [Color]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    Spacer()
                    ForEach(dataSets.indices) { index in
                        VStack(spacing: 0) {
                            Line(dataPoints: dataSets[index], lineColor: lineColors[index])
                            LineMarks(dataPoints: dataSets[index], lineColor: lineColors[index])
                        }
                        .frame(width: CGFloat(dataSets[index].count - 1) * geometry.size.width, height: 350)
                        .padding(.vertical, 20)
                        Spacer()
                    }
                }
            }
            .frame(height: 350)
        }
    }
}

struct Line: Shape {
    let dataPoints: [Double]
    let lineColor: Color
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard let maxDataPoint = dataPoints.max() else {
            return path
        }
        
        let xScale = rect.width / CGFloat(dataPoints.count - 1)
        let yScale = rect.height / CGFloat(maxDataPoint)
        
        path.move(to: CGPoint(x: 0, y: rect.height))
        
        for (index, dataPoint) in dataPoints.enumerated() {
            let x = CGFloat(index) * xScale
            let y = rect.height - CGFloat(dataPoint) * yScale
            
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path.strokedPath(StrokeStyle(lineWidth: 2, lineCap: .round))
    }
}

struct LineMarks: View {
    let dataPoints: [Double]
    let lineColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(dataPoints.indices) { index in
                let x = CGFloat(index) * geometry.size.width / CGFloat(dataPoints.count - 1)
                let y = CGFloat(dataPoints[index]) * geometry.size.height / CGFloat(dataPoints.max() ?? 1)
                
                Circle()
                    .fill(lineColor)
                    .frame(width: 8, height: 8)
                    .position(x: x, y: y)
            }
        }
        .aspectRatio(contentMode: .fit)
    }
}
*/

/*
struct LineChartView: View {
    let dataPoints: [[Double]]
    let lineColors: [Color]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) { // Use HStack for horizontal arrangement
                    Spacer()
                    ForEach(dataPoints.indices) { index in
                        VStack(spacing: 0) { // Use VStack for vertical arrangement
                            ZStack {
                                Line(dataPoints: dataPoints[index], lineColor: lineColors[index])
                                MeasureLines(dataPoints: dataPoints[index], lineColor: lineColors[index])
                                LineMarks(dataPoints: dataPoints[index], lineColor: lineColors[index])
                            }
                            .frame(width: CGFloat(dataPoints[index].count - 1) * geometry.size.width, height: 350)
                            .padding(.vertical, 20) // Adjust vertical padding
                            
                            Spacer()
                        }
                        .frame(width: geometry.size.width) // Set width to allow for scrolling
                    }
                    Spacer()
                }
            }
            .frame(height: 350)
        }
    }
}

struct MeasureLines: View {
    let dataPoints: [Double]
    let lineColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let stepX = geometry.size.width / CGFloat(dataPoints.count - 1)
                let stepY = geometry.size.height / CGFloat(dataPoints.max()! - dataPoints.min()!)
                let minValue = dataPoints.min()!
                
                for (index, dataPoint) in dataPoints.enumerated() {
                    let point = CGPoint(x: stepX * CGFloat(index), y: (dataPoint - minValue) * stepY)
                    path.move(to: point)
                    path.addLine(to: CGPoint(x: point.x, y: geometry.size.height))
                }
            }
            .strokedPath(StrokeStyle(lineWidth: 0.5, dash: [5]))
            .foregroundColor(lineColor)
        }
    }
}

struct Line: Shape {
    let dataPoints: [Double]
    let lineColor: Color
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard let maxDataPoint = dataPoints.max() else {
            return path
        }
        
        let xScale = rect.width / CGFloat(dataPoints.count - 1)
        let yScale = rect.height / CGFloat(maxDataPoint)
        
        path.move(to: CGPoint(x: 0, y: rect.height))
        
        for (index, dataPoint) in dataPoints.enumerated() {
            let x = CGFloat(index) * xScale
            let y = rect.height - CGFloat(dataPoint) * yScale
            
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path.strokedPath(StrokeStyle(lineWidth: 2, lineCap: .round))
    }
}

struct LineMarks: View {
    let dataPoints: [Double]
    let lineColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(dataPoints.indices) { index in
                let x = CGFloat(index) * geometry.size.width / CGFloat(dataPoints.count - 1)
                let y = CGFloat(dataPoints[index]) * geometry.size.height / CGFloat(dataPoints.max() ?? 1)
                
                Circle()
                    .fill(lineColor)
                    .frame(width: 8, height: 8)
                    .position(x: x, y: y)
            }
        }
        .aspectRatio(contentMode: .fit)
    }
}*/

