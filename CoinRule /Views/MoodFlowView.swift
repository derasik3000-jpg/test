//
//  MoodFlowView.swift
//  PULSE
//
//  Visual mood flow chart
//

import UIKit

class MoodFlowView: UIView {
    
    private let chartLayer = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()
    private let gridLayer = CAShapeLayer()
    private let middleLineLayer = CAShapeLayer()
    private var dataPoints: [(date: Date, intensity: CGFloat)] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayer() {
        backgroundColor = .pulsePrimaryLight
        layer.cornerRadius = 12
        
        // Grid layer
        gridLayer.strokeColor = UIColor.pulseTextSecondary.withAlphaComponent(0.15).cgColor
        gridLayer.lineWidth = 1
        layer.addSublayer(gridLayer)
        
        // Middle line layer
        middleLineLayer.strokeColor = UIColor.pulseTextSecondary.withAlphaComponent(0.3).cgColor
        middleLineLayer.lineWidth = 1
        middleLineLayer.lineDashPattern = [4, 4]
        layer.addSublayer(middleLineLayer)
        
        // Gradient layer for fill
        gradientLayer.colors = [
            UIColor.pulseIntense.withAlphaComponent(0.3).cgColor,
            UIColor.pulseCalm.withAlphaComponent(0.3).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.addSublayer(gradientLayer)
        
        // Chart line layer
        chartLayer.strokeColor = UIColor.pulsePrimary.cgColor
        chartLayer.fillColor = UIColor.clear.cgColor
        chartLayer.lineWidth = 3
        chartLayer.lineCap = .round
        chartLayer.lineJoin = .round
        layer.addSublayer(chartLayer)
    }
    
    func configure(with records: [DailyPulseRecord]) {
        dataPoints = records.prefix(14).map { record in
            let intensity = calculateIntensity(for: record)
            return (record.date, intensity)
        }.reversed()
        
        setNeedsLayout()
    }
    
    private func calculateIntensity(for record: DailyPulseRecord) -> CGFloat {
        guard !record.beats.isEmpty else { return 0.5 }
        
        let expensiveCount = record.beats.filter { $0.mood == .expensive }.count
        let cheapCount = record.beats.filter { $0.mood == .cheap }.count
        let total = record.beats.count
        
        // 0 = cheap, 0.5 = normal, 1 = expensive
        let score = (CGFloat(expensiveCount) * 1.0 + CGFloat(cheapCount) * 0.0) / CGFloat(total)
        return score
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawChart()
    }
    
    private func drawChart() {
        guard !dataPoints.isEmpty else { return }
        
        let width = bounds.width
        let height = bounds.height
        let padding: CGFloat = 40
        let topPadding: CGFloat = 25
        let bottomPadding: CGFloat = 30
        
        let chartHeight = height - topPadding - bottomPadding
        let chartWidth = width - padding * 2
        
        // Draw grid
        drawGrid(padding: padding, topPadding: topPadding, bottomPadding: bottomPadding, width: width, height: height)
        
        // Draw middle line
        let middleY = topPadding + chartHeight / 2
        let middleLinePath = UIBezierPath()
        middleLinePath.move(to: CGPoint(x: padding, y: middleY))
        middleLinePath.addLine(to: CGPoint(x: width - padding, y: middleY))
        middleLineLayer.path = middleLinePath.cgPath
        middleLineLayer.frame = bounds
        
        // Calculate points
        let pointSpacing = chartWidth / CGFloat(max(dataPoints.count - 1, 1))
        var points: [CGPoint] = []
        let path = UIBezierPath()
        
        for (index, point) in dataPoints.enumerated() {
            let x = padding + CGFloat(index) * pointSpacing
            let y = topPadding + (1.0 - point.intensity) * chartHeight
            points.append(CGPoint(x: x, y: y))
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                // Используем плавные кривые
                let previousPoint = points[index - 1]
                let controlPoint1 = CGPoint(
                    x: previousPoint.x + (x - previousPoint.x) / 2,
                    y: previousPoint.y
                )
                let controlPoint2 = CGPoint(
                    x: previousPoint.x + (x - previousPoint.x) / 2,
                    y: y
                )
                path.addCurve(to: CGPoint(x: x, y: y), controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            }
        }
        
        // Create closed path for gradient fill
        let closedPath = path.copy() as! UIBezierPath
        if !points.isEmpty {
            closedPath.addLine(to: CGPoint(x: points.last!.x, y: topPadding + chartHeight))
            closedPath.addLine(to: CGPoint(x: points.first!.x, y: topPadding + chartHeight))
            closedPath.close()
        }
        
        // Setup gradient mask
        let maskLayer = CAShapeLayer()
        maskLayer.path = closedPath.cgPath
        gradientLayer.mask = maskLayer
        gradientLayer.frame = bounds
        
        // Chart line
        chartLayer.path = path.cgPath
        chartLayer.frame = bounds
        
        // Remove old dot layers (keep chart, grid, middle line, and gradient layers)
        let layersToKeep: [CALayer] = [chartLayer, gridLayer, middleLineLayer, gradientLayer]
        layer.sublayers?.forEach { sublayer in
            if let shapeLayer = sublayer as? CAShapeLayer,
               !layersToKeep.contains(where: { $0 === shapeLayer }),
               shapeLayer !== gradientLayer.mask {
                shapeLayer.removeFromSuperlayer()
            }
        }
        
        // Add data points
        for (index, cgPoint) in points.enumerated() {
            let dotLayer = CAShapeLayer()
            let dotSize: CGFloat = 6
            let dotPath = UIBezierPath(ovalIn: CGRect(x: -dotSize/2, y: -dotSize/2, width: dotSize, height: dotSize))
            dotLayer.path = dotPath.cgPath
            
            // Цвет точки зависит от интенсивности
            let intensity = dataPoints[index].intensity
            if intensity > 0.6 {
                dotLayer.fillColor = UIColor.pulseIntense.cgColor
            } else if intensity < 0.4 {
                dotLayer.fillColor = UIColor.pulseCalm.cgColor
            } else {
                dotLayer.fillColor = UIColor.pulseSurface.cgColor
            }
            
            dotLayer.strokeColor = UIColor.pulseBackground.cgColor
            dotLayer.lineWidth = 2
            dotLayer.position = cgPoint
            
            layer.addSublayer(dotLayer)
        }
        
        // Add labels
        addLabels(points: points, padding: padding, topPadding: topPadding, bottomPadding: bottomPadding, width: width, height: height)
        
        // Animation
        if !PulseMotion.isReduceMotionEnabled {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = 1.0
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            chartLayer.add(animation, forKey: "drawChart")
            
            let fillAnimation = CABasicAnimation(keyPath: "opacity")
            fillAnimation.fromValue = 0
            fillAnimation.toValue = 1
            fillAnimation.duration = 1.0
            fillAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            gradientLayer.add(fillAnimation, forKey: "fillAnimation")
        }
    }
    
    private func drawGrid(padding: CGFloat, topPadding: CGFloat, bottomPadding: CGFloat, width: CGFloat, height: CGFloat) {
        let gridPath = UIBezierPath()
        let chartHeight = height - topPadding - bottomPadding
        
        // Horizontal grid lines (3 lines: top, middle, bottom)
        for i in 0...2 {
            let y = topPadding + CGFloat(i) * (chartHeight / 2)
            gridPath.move(to: CGPoint(x: padding, y: y))
            gridPath.addLine(to: CGPoint(x: width - padding, y: y))
        }
        
        gridLayer.path = gridPath.cgPath
        gridLayer.frame = bounds
    }
    
    private func addLabels(points: [CGPoint], padding: CGFloat, topPadding: CGFloat, bottomPadding: CGFloat, width: CGFloat, height: CGFloat) {
        // Удаляем старые метки
        subviews.forEach { $0.removeFromSuperview() }
        
        // Метка "Expensive" вверху справа
        let expensiveLabel = UILabel()
        expensiveLabel.text = "💸 Expensive"
        expensiveLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        expensiveLabel.textColor = .pulseIntense
        addSubview(expensiveLabel)
        expensiveLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            expensiveLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            expensiveLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
        
        // Метка "Normal" посередине справа
        let normalLabel = UILabel()
        normalLabel.text = "💰 Normal"
        normalLabel.font = .systemFont(ofSize: 10, weight: .regular)
        normalLabel.textColor = .pulseTextSecondary
        addSubview(normalLabel)
        normalLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            normalLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            normalLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
        
        // Метка "Cheap" внизу справа
        let cheapLabel = UILabel()
        cheapLabel.text = "💵 Cheap"
        cheapLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        cheapLabel.textColor = .pulseCalm
        addSubview(cheapLabel)
        cheapLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cheapLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            cheapLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
        
        // Метки дат на оси X (показываем каждые несколько дней)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        let step = max(1, dataPoints.count / 4) // Показываем примерно 4-5 меток
        for (index, point) in points.enumerated() where index % step == 0 || index == points.count - 1 {
            // Проверяем, что точка не выходит за границы
            guard point.x >= padding && point.x <= width - padding else { continue }
            
            let dateLabel = UILabel()
            dateLabel.text = dateFormatter.string(from: dataPoints[index].date)
            dateLabel.font = .systemFont(ofSize: 9, weight: .regular)
            dateLabel.textColor = .pulseTextSecondary
            dateLabel.textAlignment = .center
            addSubview(dateLabel)
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                dateLabel.topAnchor.constraint(equalTo: bottomAnchor, constant: -bottomPadding + 8),
                dateLabel.centerXAnchor.constraint(equalTo: leadingAnchor, constant: point.x),
                dateLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 50)
            ])
        }
    }
}
