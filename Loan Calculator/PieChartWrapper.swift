//
//  PieChartWrapper.swift
//  Loan Calculator
//
//  Created by František Moucha on 04.06.2023.
//

import Foundation
import SwiftUI
import Charts


struct PieChartWrapper: UIViewRepresentable {
    let dataPoints: [DataPoint]
    
    func makeUIView(context: Context) -> PieChartView {
        let chartView = PieChartView()
        return chartView
    }
    
    func updateUIView(_ uiView: PieChartView, context: Context) {
        var entries: [ChartDataEntry] = []
        var colors: [NSUIColor] = [.green,.orange]
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = "$"
        numberFormatter.maximumFractionDigits = 2
        
        for (index, dataPoint) in dataPoints.enumerated() {
            let formattedValue = numberFormatter.string(from: NSNumber(value: round(dataPoint.value)))
            let entry = PieChartDataEntry(value: round(dataPoint.value), label: formattedValue)
            entries.append(entry)
        }
        
        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.colors = colors // Set the colors for the data set
        dataSet.selectionShift = 0 // Set the selection shift to 0
        dataSet.valueFont = UIFont.boldSystemFont(ofSize: 18) // Set the value label font to bold
        dataSet.entryLabelFont = UIFont.boldSystemFont(ofSize: 18)
        
        let chartData = PieChartData(dataSet: dataSet)
        
        uiView.data = chartData
        uiView.holeColor = .blue
        uiView.notifyDataSetChanged()
    }
    
    typealias UIViewType = PieChartView
}
