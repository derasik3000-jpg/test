import UIKit

final class PqRitualDonutView: UIView {
    var data: RitualDonutData? {
        didSet {
            pqDrawDonutVisualization(animated: true)
        }
    }
    
    var ringWidth: CGFloat = 12
    var onTap: (() -> Void)?
    
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let captionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        pqInitializeDonutLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        pqInitializeDonutLayers()
    }
    
    private func pqInitializeDonutLayers() {
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = PqColors.dividerSubtle.cgColor
        trackLayer.lineWidth = ringWidth
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
        
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = PqColors.brightTurquoiseAccent.cgColor
        progressLayer.lineWidth = ringWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
        
        captionLabel.font = PqFonts.monospacedDigit(size: 18, weight: .semibold)
        captionLabel.textColor = PqColors.textPrimaryLight
        captionLabel.textAlignment = .center
        addSubview(captionLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pqDonutWasTapped))
        addGestureRecognizer(tapGesture)
        
        isAccessibilityElement = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - ringWidth
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: -.pi / 2, endAngle: 1.5 * .pi, clockwise: true)
        
        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
        
        captionLabel.frame = CGRect(x: 0, y: bounds.midY - 15, width: bounds.width, height: 30)
    }
    
    private func pqDrawDonutVisualization(animated: Bool) {
        guard let data = data else { return }
        
        captionLabel.text = data.caption
        
        let targetStrokeEnd = data.ratio
        
        if animated && !UIAccessibility.isReduceMotionEnabled {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressLayer.strokeEnd
            animation.toValue = targetStrokeEnd
            animation.duration = 0.18
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            progressLayer.add(animation, forKey: "strokeEnd")
        }
        
        progressLayer.strokeEnd = targetStrokeEnd
        
        if data.isComplete {
            progressLayer.strokeColor = PqColors.successLeafGreen.cgColor
            if animated && !UIAccessibility.isReduceMotionEnabled {
                PqHapticEngine.shared.pqEmitPositiveFeedback()
            }
        } else {
            progressLayer.strokeColor = PqColors.brightTurquoiseAccent.cgColor
        }
        
        accessibilityLabel = "Ritual progress: \(data.done) of \(data.total), \(data.caption)"
    }
    
    @objc private func pqDonutWasTapped() {
        onTap?()
    }
}

