// This is example code for the article "Area chart with a dimming layer up to the current point in time",
// that can be found at https://nilcoalescing.com/blog/AreaChartWithADimmingLayer/

import SwiftUI
import Charts

extension Calendar {
    static func date(bySettingHour hour: Int, of date: Date) -> Date? {
        Calendar.current.date(
            bySettingHour: hour,
            minute: 0,
            second: 0,
            of: date
        )
    }
}

struct ContentView: View {
    let currentDate = Calendar.date(bySettingHour: 12, of: Date())!
    
    let uvData = [
        (hour: 6, uv: 0), (hour: 8, uv: 1),
        (hour: 10, uv: 4), (hour: 12, uv: 6.5),
        (hour: 14, uv: 8.2), (hour: 16, uv: 6),
        (hour: 18, uv: 1.3), (hour: 20, uv: 0)
    ]

    var currentUVData: [(date: Date, uv: Double)] {
        uvData.map {
            (
                date: Calendar.date(bySettingHour: $0.hour, of: currentDate)!,
                uv: $0.uv
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("UV index in Christchurch throughout the day")
                .font(.headline)
            
            Chart {
                ForEach(currentUVData, id: \.date) { dataPoint in
                    AreaMark(
                        x: .value("Time of day", dataPoint.date),
                        y: .value("UV index", dataPoint.uv)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.green, .yellow, .red],
                            startPoint: .bottom, endPoint: .top
                        )
                        .opacity(0.5)
                    )
                    .alignsMarkStylesWithPlotArea()
                    .accessibilityHidden(true)
                    
                    LineMark(
                        x: .value("Time of day", dataPoint.date),
                        y: .value("UV index", dataPoint.uv)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.green, .yellow, .red],
                            startPoint: .bottom, endPoint: .top
                        )
                    )
                    .lineStyle(StrokeStyle(lineWidth: 4))
                    .alignsMarkStylesWithPlotArea()
                }
                
                if let dataPoint = closestDataPoint(for: currentDate) {
                    
                    if let firstDataPoint = currentUVData.first {
                        RectangleMark(
                            xStart: .value("", firstDataPoint.date),
                            xEnd: .value("", dataPoint.date)
                        )
                        
                        .foregroundStyle(.thickMaterial)
                        .opacity(0.6)
                        .accessibilityHidden(true)
                        
                        .mask {
                            ForEach(currentUVData, id: \.date) { dataPoint in
                                AreaMark(
                                    x: .value("Time of day", dataPoint.date),
                                    y: .value("UV index", dataPoint.uv),
                                    series: .value("", "mask"),
                                    stacking: .unstacked
                                )
                                .interpolationMethod(.cardinal)
                                
                                LineMark(
                                    x: .value("Time of day", dataPoint.date),
                                    y: .value("UV index", dataPoint.uv),
                                    series: .value("", "mask")
                                )
                                .interpolationMethod(.cardinal)
                                .lineStyle(StrokeStyle(lineWidth: 4))
                            }
                        }
                    }
                    
                    RuleMark(x: .value("Now", dataPoint.date))
                        .foregroundStyle(Color.secondary)
                        .accessibilityHidden(true)
                    
                    PointMark(
                        x: .value("Time of day", dataPoint.date),
                        y: .value("UV index", dataPoint.uv)
                    )
                    .symbolSize(CGSize(width: 16, height: 16))
                    .foregroundStyle(.regularMaterial)
                    .accessibilityHidden(true)
                    
                    PointMark(
                        x: .value("Time of day", dataPoint.date),
                        y: .value("UV index", dataPoint.uv)
                    )
                    .symbolSize(CGSize(width: 6, height: 6))
                    .foregroundStyle(Color.primary)
                    .accessibilityLabel("Now")
                }
            }
            .chartYScale(range: .plotDimension(padding: 2))
            .chartYAxis {
                AxisMarks(
                    format: .number,
                    preset: .aligned,
                    values: Array(0...12)
                )
                
                AxisMarks(
                    preset: .inset,
                    position: .leading,
                    values: [1, 3, 6, 8, 11]
                ) { value in
                    AxisValueLabel(
                        descriptionForUVIndex(value.as(Double.self)!)
                    )
                }
            }
        }
        .padding()
    }
    
    func closestDataPoint(for date: Date) -> (date: Date, uv: Double)? {
        currentUVData.sorted { a, b in
            abs(date.timeIntervalSince(a.date)) < abs(date.timeIntervalSince(b.date))
        }.first
    }
    
    func descriptionForUVIndex(_ index: Double) -> String {
        switch index {
        case 0...2: return "Low"
        case 3...5: return "Moderate"
        case 6...7: return "High"
        case 8...10: return "Very high"
        default: return "Extreme"
        }
    }
}
