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
}*/
