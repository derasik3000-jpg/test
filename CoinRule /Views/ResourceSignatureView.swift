//
//  ResourceSignatureView.swift
//  PULSE
//
//  Visual representation of user's resource pattern
//

import UIKit

class ResourceSignatureView: UIView {
    
    private var signature: ResourceSignature?
    private let shapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayer() {
        backgroundColor = .clear
        
        shapeLayer.strokeColor = UIColor.pulsePrimary.cgColor
        shapeLayer.fillColor = UIColor.pulsePrimary.withAlphaComponent(0.1).cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        
        layer.addSublayer(shapeLayer)
    }
    
    func configure(with signature: ResourceSignature) {
        self.signature = signature
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawSignature()
    }
    
    private func drawSignature() {
        guard let signature = signature, !signature.points.isEmpty else { return }
        
        let path = UIBezierPath()
        let width = bounds.width
        let height = bounds.height
        let padding: CGFloat = 20
        
        // Преобразуем нормализованные точки в координаты view
        let scaledPoints = signature.points.map { point in
            CGPoint(
                x: padding + point.x * (width - padding * 2),
                y: padding + point.y * (height - padding * 2)
            )
        }
        
        guard !scaledPoints.isEmpty else { return }
        
        // Создаём плавную кривую
        path.move(to: scaledPoints[0])
        
        if scaledPoints.count > 2 {
            for i in 1..<scaledPoints.count {
                let point = scaledPoints[i]
                
                if i == 1 {
                    path.addLine(to: point)
                } else {
                    let previousPoint = scaledPoints[i - 1]
                    let controlPoint1 = CGPoint(
                        x: (previousPoint.x + point.x) / 2,
                        y: previousPoint.y
                    )
                    let controlPoint2 = CGPoint(
                        x: (previousPoint.x + point.x) / 2,
                        y: point.y
                    )
                    path.addCurve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
                }
            }
        } else {
            for point in scaledPoints.dropFirst() {
                path.addLine(to: point)
            }
        }
        
        // Замыкаем путь для заливки
        let closedPath = path.copy() as! UIBezierPath
        closedPath.addLine(to: CGPoint(x: scaledPoints.last!.x, y: height - padding))
        closedPath.addLine(to: CGPoint(x: scaledPoints.first!.x, y: height - padding))
        closedPath.close()
        
        shapeLayer.path = closedPath.cgPath
        shapeLayer.frame = bounds
        
        // Анимация появления
        if !PulseMotion.isReduceMotionEnabled {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = 1.5
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            shapeLayer.add(animation, forKey: "drawSignature")
        }
    }
}
