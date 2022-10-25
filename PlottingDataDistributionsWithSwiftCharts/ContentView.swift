// This is example code for the article "Plotting data distributions with Swift Charts",
// that can be found at https://nilcoalescing.com/blog/PlottingDataDistributionsWithSwiftCharts/

import SwiftUI
import OrderedCollections
import Foundation

struct ContentView: View {
    @State
    var data: [PenguinsDataPoint] = []
    
    @State
    var error: Error? = nil
    
    var body: some View {
        PenguinChart(
            dataset: self.data
        )
        .task(priority: .background) {
            do {
                self.data = try await PenguinsDataPoint.load()
            } catch {
                self.error = error
            }
        }
    }
}
