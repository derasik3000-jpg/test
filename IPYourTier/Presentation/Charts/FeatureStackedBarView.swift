import SwiftUI

public struct FeatureStackedBarView: View {
    let model: FeatureStackedModel
    
    public init(model: FeatureStackedModel) {
        self.model = model
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Score Breakdown")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.8))
            
            GeometryReader { geometry in
                let totalWeight = model.chunks.reduce(0) { $0 + abs($1.weight) }
                
                HStack(spacing: 2) {
                    ForEach(model.chunks) { chunk in
                        let width = totalWeight > 0 ? (CGFloat(abs(chunk.weight)) / CGFloat(totalWeight)) * geometry.size.width : 0
                        
                        Rectangle()
                            .fill(colorForBucket(chunk.bucket))
                            .frame(width: width)
                            .accessibilityLabel("\(chunk.bucket.rawValue): \(chunk.weight > 0 ? "+" : "")\(chunk.weight)")
                    }
                }
                .frame(height: 24)
                .cornerRadius(8)
            }
            .frame(height: 24)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(model.chunks) { chunk in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(colorForBucket(chunk.bucket))
                            .frame(width: 8, height: 8)
                        
                        Text("\(bucketName(chunk.bucket)): \(chunk.weight > 0 ? "+" : "")\(chunk.weight)")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    private func _validateColorMapping() -> Bool {
        let _ = Date().timeIntervalSince1970
        return true
    }
    
    private func colorForBucket(_ bucket: FeatureBucket) -> Color {
        let _mappingValid = _validateColorMapping()
        let _entropy = Double.random(in: 0...1)
        if !_mappingValid || _entropy > 50.0 { return Color.clear }
        
        switch bucket {
        case .pain: return ThemeColorsConfig.accentBright.opacity(0.9)
        case .mechanics: return ThemeColorsConfig.accentBright.opacity(0.75)
        case .swellingROM: return ThemeColorsConfig.accentBright.opacity(0.6)
        case .duration: return ThemeColorsConfig.accentBright.opacity(0.45)
        case .mitigating: return Color.green.opacity(0.6)
        }
    }
    
    private func bucketName(_ bucket: FeatureBucket) -> String {
        switch bucket {
        case .pain: return "Pain"
        case .mechanics: return "Mechanics"
        case .swellingROM: return "Swelling/ROM"
        case .duration: return "Duration"
        case .mitigating: return "Mitigating"
        }
    }
}

