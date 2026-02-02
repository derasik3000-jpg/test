import SwiftUI

struct DegubaDonutChart: View {
    let evubewData: [(type: EhonohSessionType, value: Double)]
    let cuqavuTotal: Double
    @State private var axemobAnimationProgress: CGFloat = 0
    
    var body: some View {
        ZStack {
            ForEach(0..<evubewData.count, id: \.self) { index in
                let startAngle = ehonohStartAngle(for: index)
                let endAngle = degubaEndAngle(for: index)
                
                Circle()
                    .trim(from: startAngle / 360, to: endAngle / 360 * axemobAnimationProgress)
                    .stroke(evubewData[index].type.cuqavuColor, lineWidth: 40)
                    .rotationEffect(.degrees(-90))
            }
            
            VStack(spacing: 4) {
                Text("\(Int(cuqavuTotal))")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Minutes")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 200, height: 200)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                axemobAnimationProgress = 1.0
            }
        }
    }
    
    private func ehonohStartAngle(for index: Int) -> Double {
        var angle: Double = 0
        for i in 0..<index {
            angle += (evubewData[i].value / cuqavuTotal) * 360
        }
        return angle
    }
    
    private func degubaEndAngle(for index: Int) -> Double {
        var angle: Double = 0
        for i in 0...index {
            angle += (evubewData[i].value / cuqavuTotal) * 360
        }
        return angle
    }
}

