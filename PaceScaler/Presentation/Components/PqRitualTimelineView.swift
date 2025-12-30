import UIKit

final class PqRitualTimelineView: UIView {
    var data: RitualTimelineData? {
        didSet {
            pqVisualizeTimeline(animated: true)
        }
    }
    
    var onPointTap: ((Int) -> Void)?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        pqBuildTimelineStructure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        pqBuildTimelineStructure()
    }
    
    private func pqBuildTimelineStructure() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    private func pqVisualizeTimeline(animated: Bool) {
        guard let data = data else { return }
        
        contentView.subviews.forEach { $0.removeFromSuperview() }
        contentView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let pointCount = data.points.count
        guard pointCount > 0 else { return }
        
        let nodeSize: CGFloat = 40
        let spacing: CGFloat = 80
        let totalWidth = CGFloat(pointCount) * spacing + 40
        
        contentView.widthAnchor.constraint(equalToConstant: totalWidth).isActive = true
        
        let lineLayer = CAShapeLayer()
        let linePath = UIBezierPath()
        
        for (index, point) in data.points.enumerated() {
            let x: CGFloat = 20 + CGFloat(index) * spacing
            let y: CGFloat = bounds.height / 2
            
            if index > 0 {
                linePath.move(to: CGPoint(x: x - spacing, y: y))
                linePath.addLine(to: CGPoint(x: x, y: y))
            }
            
            let nodeLayer = CAShapeLayer()
            let nodePath = UIBezierPath(ovalIn: CGRect(x: x - nodeSize / 2, y: y - nodeSize / 2, width: nodeSize, height: nodeSize))
            nodeLayer.path = nodePath.cgPath
            
            if point.isDone {
                nodeLayer.fillColor = PqColors.brightTurquoiseAccent.cgColor
                nodeLayer.strokeColor = PqColors.brightTurquoiseAccent.cgColor
            } else {
                nodeLayer.fillColor = UIColor.clear.cgColor
                nodeLayer.strokeColor = PqColors.dividerSubtle.cgColor
            }
            nodeLayer.lineWidth = 2
            contentView.layer.addSublayer(nodeLayer)
            
            let iconImageView = UIImageView(image: UIImage(systemName: point.iconName))
            iconImageView.tintColor = point.isDone ? PqColors.deepIndigoBase : PqColors.textSecondaryFaded
            iconImageView.contentMode = .scaleAspectFit
            iconImageView.frame = CGRect(x: x - 12, y: y - 12, width: 24, height: 24)
            contentView.addSubview(iconImageView)
            
            let titleLabel = UILabel()
            titleLabel.text = point.title
            titleLabel.font = PqFonts.footnoteRegular()
            titleLabel.textColor = PqColors.textSecondaryFaded
            titleLabel.textAlignment = .center
            titleLabel.frame = CGRect(x: x - 40, y: y + nodeSize / 2 + 4, width: 80, height: 20)
            contentView.addSubview(titleLabel)
            
            if let timestamp = point.timestamp {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                let timeLabel = UILabel()
                timeLabel.text = formatter.string(from: timestamp)
                timeLabel.font = PqFonts.monospacedDigit(size: 11)
                timeLabel.textColor = PqColors.textSecondaryFaded
                timeLabel.textAlignment = .center
                timeLabel.frame = CGRect(x: x - 40, y: y - nodeSize / 2 - 24, width: 80, height: 20)
                contentView.addSubview(timeLabel)
            }
        }
        
        lineLayer.path = linePath.cgPath
        lineLayer.strokeColor = PqColors.dividerSubtle.cgColor
        lineLayer.lineWidth = 2
        contentView.layer.insertSublayer(lineLayer, at: 0)
    }
}

