// This is example code for the article "Fill bar marks with gradient in Swift Charts",
// that can be found at https://nilcoalescing.com/blog/FillBarMarksWithGradient/

import SwiftUI
import Charts

struct ContentView: View {
    let data = [
        (month: "January", temp: 17.1),
        (month: "February", temp: 17.0),
        (month: "March", temp: 14.9),
        (month: "April", temp: 12.2),
        (month: "May", temp: 9.6),
        (month: "June", temp: 6.9),
        (month: "July", temp: 6.3),
        (month: "August", temp: 7.6),
        (month: "September", temp: 9.5),
        (month: "October", temp: 11.2),
        (month: "November", temp: 13.5),
        (month: "December", temp: 15.7)
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Daily mean temperature in Christchurch in degrees Celsius")
                .font(.headline)
            Chart {
                ForEach(data, id: \.month) {
                    BarMark(
                        x: .value("Month", String($0.month.prefix(3))),
                        y: .value("Temperature", $0.temp)
                    )
                    .accessibilityLabel("\($0.month)")
                }
                .foregroundStyle(
                    .linearGradient(
                        colors: [.blue, .red],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .alignsMarkStylesWithPlotArea()
            }
        }
        .frame(height: 500)
        .padding()
    }
}
