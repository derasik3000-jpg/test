//
//  PulseBootScene.swift
//  PULSE
//
//  Loading Screen
//

import UIKit

class PulseBootScene: UIViewController {
    
    weak var coordinator: RootSpineCoordinator?
    
    private let pulseLayer = CAShapeLayer()
    private var orbitDots: [CAShapeLayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupPulse()
        setupOrbitDots()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimation()
    }
    
    // MARK: - Setup
    
    private func setupPulse() {
        let center = view.center
        let radius: CGFloat = 60
        
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        
        pulseLayer.path = circlePath.cgPath
        pulseLayer.fillColor = UIColor.clear.cgColor
        pulseLayer.strokeColor = UIColor.pulsePrimary.cgColor
        pulseLayer.lineWidth = 4
        
        view.layer.addSublayer(pulseLayer)
    }
    
    private func setupOrbitDots() {
        let center = view.center
        let orbitRadius: CGFloat = 100
        let dotCount = 6
        
        for i in 0..<dotCount {
            let dotLayer = CAShapeLayer()
            let dotPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 8, height: 8))
            
            dotLayer.path = dotPath.cgPath
            dotLayer.fillColor = UIColor.pulsePrimary.cgColor
            
            let angle = (CGFloat(i) / CGFloat(dotCount)) * .pi * 2
            let x = center.x + cos(angle) * orbitRadius
            let y = center.y + sin(angle) * orbitRadius
            dotLayer.position = CGPoint(x: x, y: y)
            
            view.layer.addSublayer(dotLayer)
            orbitDots.append(dotLayer)
        }
    }
    
    // MARK: - Animation
    
    private func startAnimation() {
        if PulseMotion.isReduceMotionEnabled {
            // Simple fade for reduce motion
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.completeLoading()
            }
            return
        }
        
        // Pulse stroke animation
        let strokeAnimation = PulseMotion.createStrokeAnimation(duration: 2.0)
        strokeAnimation.repeatCount = 1
        pulseLayer.add(strokeAnimation, forKey: "stroke")
        
        // Orbit dots animation
        for (index, dot) in orbitDots.enumerated() {
            let orbitAnimation = PulseMotion.createOrbitAnimation(radius: 100, duration: 2.0)
            orbitAnimation.beginTime = CACurrentMediaTime() + Double(index) * 0.1
            orbitAnimation.repeatCount = 1
            dot.add(orbitAnimation, forKey: "orbit")
        }
        
        // Complete after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.completeLoading()
        }
    }
    
    private func completeLoading() {
        coordinator?.bootCompleted()
    }
}
