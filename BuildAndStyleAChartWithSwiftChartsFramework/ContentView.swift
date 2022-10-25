// This is example code for the article "Build and style a chart with the new Swift Charts framework",
// that can be found at https://nilcoalescing.com/blog/BuildAndStyleAChartWithSwiftChartsFramework/

import SwiftUI

struct ContentView: View {
    @State
    var data: [BabyNamesDataPoint] = []
    
    @State
    var error: Error? = nil
    
    var body: some View {
        VStack {
            if let error = error {
                Text("error: \(error.localizedDescription)")
            } else if data.isEmpty {
                ProgressView().progressViewStyle(.circular)
            } else {
                SimpleBabyChart(data: data)
            }
        }
        .task(priority: .background) {
            do {
                self.data = try await BabyNamesDataPoint.load()
            } catch {
                self.error = error
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
