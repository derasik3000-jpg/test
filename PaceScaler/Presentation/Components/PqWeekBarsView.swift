import UIKit

final class PqWeekBarsView: UIView {
    var data: WeekBarsData? {
        didSet {
            pqDrawWeekBars(animated: true)
        }
    }
    
    var onBarTap: ((Date) -> Void)?
    
    private var barLayers: [CAShapeLayer] = []
    private var badgeLayers: [CAShapeLayer] = []
    private var labelLayers: [CATextLayer] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        pqInitializeBarsCanvas()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        pqInitializeBarsCanvas()
    }
    
    private func pqInitializeBarsCanvas() {
        backgroundColor = .clear
        isAccessibilityElement = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pqDrawWeekBars(animated: false)
    }
    
    private func pqDrawWeekBars(animated: Bool) {
        guard let data = data else { return }
        
        barLayers.forEach { $0.removeFromSuperlayer() }
        badgeLayers.forEach { $0.removeFromSuperlayer() }
        labelLayers.forEach { $0.removeFromSuperlayer() }
        barLayers.removeAll()
        badgeLayers.removeAll()
        labelLayers.removeAll()
        
        let count = data.items.count
        guard count > 0 else { return }
        
        let barWidth: CGFloat = 30
        let spacing: CGFloat = (bounds.width - CGFloat(count) * barWidth) / CGFloat(count + 1)
        let maxBarHeight = bounds.height - 40
        
        for (index, item) in data.items.enumerated() {
            let x = spacing + CGFloat(index) * (barWidth + spacing)
            let barHeight = maxBarHeight * item.ratio
            let y = bounds.height - 30 - barHeight
            
            let barLayer = CAShapeLayer()
            barLayer.path = UIBezierPath(roundedRect: CGRect(x: x, y: y, width: barWidth, height: barHeight), cornerRadius: 4).cgPath
            barLayer.fillColor = PqColors.brightTurquoiseAccent.cgColor
            layer.addSublayer(barLayer)
            barLayers.append(barLayer)
            
            if item.isCalm {
                let badgeLayer = CAShapeLayer()
                let badgeSize: CGFloat = 8
                let badgePath = UIBezierPath(ovalIn: CGRect(x: x + barWidth / 2 - badgeSize / 2, y: y - badgeSize - 4, width: badgeSize, height: badgeSize))
                badgeLayer.path = badgePath.cgPath
                badgeLayer.fillColor = PqColors.successLeafGreen.cgColor
                layer.addSublayer(badgeLayer)
                badgeLayers.append(badgeLayer)
            }
            
            let labelLayer = CATextLayer()
            labelLayer.string = PqDateHelper.pqExtractWeekdayGlyph(for: item.date)
            labelLayer.fontSize = 12
            labelLayer.foregroundColor = PqColors.textSecondaryFaded.cgColor
            labelLayer.alignmentMode = .center
            labelLayer.frame = CGRect(x: x, y: bounds.height - 25, width: barWidth, height: 20)
            labelLayer.contentsScale = UIScreen.main.scale
            layer.addSublayer(labelLayer)
            labelLayers.append(labelLayer)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let data = data, let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let count = data.items.count
        let barWidth: CGFloat = 30
        let spacing: CGFloat = (bounds.width - CGFloat(count) * barWidth) / CGFloat(count + 1)
        
        for (index, item) in data.items.enumerated() {
            let x = spacing + CGFloat(index) * (barWidth + spacing)
            if location.x >= x && location.x <= x + barWidth {
                onBarTap?(item.date)
                break
            }
        }
    }
}

