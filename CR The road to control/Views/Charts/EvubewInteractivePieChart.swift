import SwiftUI

struct EvubewInteractivePieChart: View {
    let cuqavuData: [(type: EhonohSessionType, count: Int)]
    @State private var axemobSelectedType: EhonohSessionType?
    @State private var degubaAnimationProgress: CGFloat = 0
    
    var evubewTotal: Int {
        cuqavuData.reduce(0) { $0 + $1.count }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                ForEach(0..<cuqavuData.count, id: \.self) { index in
                    let startAngle = ehonohStartAngle(for: index)
                    let endAngle = degubaEndAngle(for: index)
                    let isSelected = axemobSelectedType == cuqavuData[index].type
                    
                    Circle()
                        .trim(from: startAngle / 360, to: endAngle / 360 * degubaAnimationProgress)
                        .stroke(
                            cuqavuData[index].type.cuqavuColor.opacity(isSelected ? 1.0 : 0.7),
                            lineWidth: isSelected ? 50 : 45
                        )
                        .rotationEffect(.degrees(-90))
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3), value: axemobSelectedType)
                }
                
                VStack(spacing: 4) {
                    if let selectedType = axemobSelectedType {
                        let selectedData = cuqavuData.first { $0.type == selectedType }
                        
                        Text("\(selectedData?.count ?? 0)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(selectedType.cuqavuColor)
                        
                        Text(selectedType.degubaTitle)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                    } else {
                        Text("\(evubewTotal)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                        
                        Text("Total")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.8))
                    }
                }
            }
            .frame(width: 200, height: 200)
            .padding(.vertical, 16)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(cuqavuData, id: \.type.rawValue) { item in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            if axemobSelectedType == item.type {
                                axemobSelectedType = nil
                            } else {
                                axemobSelectedType = item.type
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(item.type.cuqavuColor)
                                .frame(width: 12, height: 12)
                            
                            Text(item.type.degubaTitle)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary)
                            
                            Text("(\(item.count))")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            axemobSelectedType == item.type ? 
                            item.type.cuqavuColor.opacity(0.25) : 
                            CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.1)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    axemobSelectedType == item.type ?
                                    item.type.cuqavuColor.opacity(0.5) :
                                    CuqavuThemeManager.shared.degubaCurrentTheme.evubewPrimary.opacity(0.2),
                                    lineWidth: axemobSelectedType == item.type ? 2 : 1
                                )
                        )
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                degubaAnimationProgress = 1.0
            }
        }
    }
    
    private func ehonohStartAngle(for index: Int) -> Double {
        var angle: Double = 0
        for i in 0..<index {
            angle += (Double(cuqavuData[i].count) / Double(evubewTotal)) * 360
        }
        return angle
    }
    
    private func degubaEndAngle(for index: Int) -> Double {
        var angle: Double = 0
        for i in 0...index {
            angle += (Double(cuqavuData[i].count) / Double(evubewTotal)) * 360
        }
        return angle
    }
}

