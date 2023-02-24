// This is example code for the article "Area chart with a dimming layer up to the current point in time",
// that can be found at https://nilcoalescing.com/blog/ChartAnnotationsOnHover/

import SwiftUI
import Charts

struct Product: Identifiable {
    let id = UUID()
    let name: String
    let salesData: [Double]
    
    var salesDataByMonth: [(month: String, sales: Double)] {
        salesData.enumerated().map { (offset, sales) in
            return (
                month: Calendar.current.monthSymbols[offset],
                sales: sales
            )
        }
    }
}

struct ContentView: View {
    let products = [
        Product(
            name: "Ice Cream",
            salesData: [
                1000, 1200, 900, 950, 800, 700,
                730, 600, 620, 800, 950, 1100
            ]
        ),
        Product(
            name: "Coffee",
            salesData: [
                1800, 2000, 1900, 1950, 2500, 2800,
                2730, 2600, 1620, 1800, 1950, 2100
            ]
        ),
        Product(
            name: "Muffins",
            salesData: [
                900, 700, 800, 950, 900, 1000,
                1200, 1100, 1000, 800, 950, 900
            ]
        )
    ]
    
    @State private var selectedMonth: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Product sales in 2022")
                .font(.headline)
            
            Chart {
                ForEach(products) { product in
                    ForEach(product.salesDataByMonth, id: \.month) { salesData in
                        BarMark(
                            x: .value("Month", salesData.0),
                            y: .value("Sales", salesData.sales)
                        )
                        // position bar marks side by side instead of stacking them
                        .position(by: .value("Product", product.name))
                        // color the bars differently per product name
                        .foregroundStyle(by: .value("Product", product.name))
                    }
                }
                if
                    let selectedMonth,
                    let monthNumber = Calendar.current.monthSymbols.firstIndex(
                        of: selectedMonth
                    )
                {
                    RectangleMark(x: .value("Month", selectedMonth))
                        .foregroundStyle(.primary.opacity(0.2))
                        .annotation(
                            position: monthNumber < 6 ? .trailing : .leading,
                            alignment: .center, spacing: 0
                        ) {
                            SalesAnnotationView(
                                products: products,
                                month: selectedMonth,
                                monthNumber: monthNumber
                            )
                        }
                        .accessibilityHidden(true)
                }
                
            }
            .chartOverlay { (chartProxy: ChartProxy) in
                Color.clear
                    .onContinuousHover { hoverPhase in
                        switch hoverPhase {
                        case .active(let hoverLocation):
                            selectedMonth = chartProxy.value(
                                atX: hoverLocation.x, as: String.self
                            )
                        case .ended:
                            selectedMonth = nil
                        }
                    }
            }
        }
        .padding()
    }
}

struct SalesAnnotationView: View {
    let products: [Product]
    let month: String
    let monthNumber: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(month)
                .font(.headline)
            Divider()
            ForEach(products) { product in
                let name = product.name
                let sales = product.salesData[monthNumber]
                Text("\(name): \(sales, format: .currency(code: "NZD"))")
            }
        }
        .padding()
        .background(Color.annotationBackground)
    }
}

extension Color {
    static var annotationBackground: Color {
        #if os(macOS)
        return Color(nsColor: .controlBackgroundColor)
        #else
        return Color(uiColor: .secondarySystemBackground)
        #endif
    }
}
