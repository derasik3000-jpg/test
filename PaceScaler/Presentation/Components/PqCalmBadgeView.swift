import UIKit

final class PqCalmBadgeView: UIView {
    var data: CalmBadgeData? {
        didSet {
            render(animated: true)
        }
    }
    
    private let circleLayer = CAShapeLayer()
    private let iconImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        pqArrangeBadgeElements()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        pqArrangeBadgeElements()
    }
    
    private func pqArrangeBadgeElements() {
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = PqColors.dividerSubtle.cgColor
        circleLayer.lineWidth = 2
        layer.addSublayer(circleLayer)
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = PqColors.successLeafGreen
        addSubview(iconImageView)
        
        isAccessibilityElement = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2
        let path = UIBezierPath(arcCenter: center, radius: radius - 1, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        circleLayer.path = path.cgPath
        
        let iconSize: CGFloat = radius * 1.2
        iconImageView.frame = CGRect(x: bounds.midX - iconSize / 2, y: bounds.midY - iconSize / 2, width: iconSize, height: iconSize)
    }
    
    private func render(animated: Bool) {
        guard let data = data else { return }
        
        if data.isCalm {
            circleLayer.fillColor = PqColors.successLeafGreen.cgColor
            circleLayer.strokeColor = PqColors.successLeafGreen.cgColor
            iconImageView.image = UIImage(systemName: "medal.fill")
            iconImageView.isHidden = false
            accessibilityLabel = "Calm evening: yes"
        } else {
            circleLayer.fillColor = UIColor.clear.cgColor
            circleLayer.strokeColor = PqColors.dividerSubtle.cgColor
            iconImageView.isHidden = true
            accessibilityLabel = "Calm evening: no"
        }
    }
}

