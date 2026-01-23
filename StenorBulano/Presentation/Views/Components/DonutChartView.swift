import SwiftUI

struct DonutChartView: View {
    let slices: [ChartSlice]
    let totalText: String
    
    struct ChartSlice: Identifiable {
        let id = UUID()
        let value: Double
        let color: Color
        let label: String
    }
    
    var body: some View {
        ZStack {
            VStack {
                Text(totalText)
                    .font(Typography.h2())
                    .foregroundColor(ColorTheme.Text.primary)
            }
        }
        .frame(height: 200)
    }
}

