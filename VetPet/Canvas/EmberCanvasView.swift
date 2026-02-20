import SwiftUI
import UIKit

// MARK: - EmberCanvasView
// SwiftUI wrapper for the UIKit animated background
// Subtle floating golden particles on deep dark canvas

struct EmberCanvasView: UIViewRepresentable {

    func makeUIView(context: Context) -> EmberCanvasUIView {
        let canvas = EmberCanvasUIView()
        canvas.isUserInteractionEnabled = false
        canvas.clipsToBounds = true
        return canvas
    }

    func updateUIView(_ uiView: EmberCanvasUIView, context: Context) {}
}

// MARK: - EmberCanvasUIView

final class EmberCanvasUIView: UIView {

    // MARK: - Ember Layers

    private var emberLayers: [CAShapeLayer] = []
    private var orbGradientLayer: CAGradientLayer?
    private var displayLink: CADisplayLink?
    private var elapsedTime: CFTimeInterval = 0
    private var lastTimestamp: CFTimeInterval = 0

    private let emberCount = 18
    private let orbCount = 3

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1.0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            igniteEmbers()
            summonOrbs()
            startBreathCycle()
        } else {
            extinguish()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        orbGradientLayer?.frame = bounds
        repositionEmbers()
    }

    // MARK: - Floating Embers (tiny golden dots)

    private func igniteEmbers() {
        guard emberLayers.isEmpty else { return }

        for _ in 0..<emberCount {
            let ember = CAShapeLayer()
            let radius = CGFloat.random(in: 1.2...3.0)
            ember.path = UIBezierPath(
                ovalIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2)
            ).cgPath

            let goldHue = CGFloat.random(in: 0.10...0.14)
            let saturation = CGFloat.random(in: 0.7...1.0)
            let brightness = CGFloat.random(in: 0.6...1.0)
            ember.fillColor = UIColor(
                hue: goldHue,
                saturation: saturation,
                brightness: brightness,
                alpha: CGFloat.random(in: 0.15...0.45)
            ).cgColor

            ember.position = randomSpawnPoint()
            layer.addSublayer(ember)
            emberLayers.append(ember)

            animateEmberDrift(ember)
        }
    }

    private func animateEmberDrift(_ ember: CAShapeLayer) {
        let duration = CFTimeInterval.random(in: 12...28)
        let drift = CAKeyframeAnimation(keyPath: "position")

        let start = ember.position
        let mid1 = CGPoint(
            x: start.x + CGFloat.random(in: -40 ... 40),
            y: start.y + CGFloat.random(in: -80 ... -20)
        )
        let mid2 = CGPoint(
            x: mid1.x + CGFloat.random(in: -30 ... 30),
            y: mid1.y + CGFloat.random(in: -60 ... -10)
        )
        let end = CGPoint(
            x: mid2.x + CGFloat.random(in: -20 ... 20),
            y: -20
        )

        drift.values = [
            NSValue(cgPoint: start),
            NSValue(cgPoint: mid1),
            NSValue(cgPoint: mid2),
            NSValue(cgPoint: end)
        ]
        drift.keyTimes = [0, 0.3, 0.7, 1.0]
        drift.duration = duration
        drift.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeIn)
        ]

        let fade = CAKeyframeAnimation(keyPath: "opacity")
        fade.values = [0.0, 0.6, 0.4, 0.0]
        fade.keyTimes = [0, 0.15, 0.75, 1.0]
        fade.duration = duration

        let group = CAAnimationGroup()
        group.animations = [drift, fade]
        group.duration = duration
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards
        group.completion = { [weak self, weak ember] _ in
            guard let self = self, let ember = ember else { return }
            ember.position = self.randomSpawnPoint()
            self.animateEmberDrift(ember)
        }

        ember.add(group, forKey: "emberDrift")
    }

    private func repositionEmbers() {
        // Only reposition if bounds changed significantly
        for ember in emberLayers where ember.animation(forKey: "emberDrift") == nil {
            ember.position = randomSpawnPoint()
            animateEmberDrift(ember)
        }
    }

    private func randomSpawnPoint() -> CGPoint {
        let w = max(bounds.width, 320)
        let h = max(bounds.height, 568)
        return CGPoint(
            x: CGFloat.random(in: 0...w),
            y: CGFloat.random(in: h * 0.4...h + 60)
        )
    }

    // MARK: - Ambient Orbs (soft radial glows)

    private func summonOrbs() {
        let gradient = CAGradientLayer()
        gradient.type = .radial
        gradient.colors = [
            UIColor(red: 1.0, green: 0.78, blue: 0.20, alpha: 0.04).cgColor,
            UIColor(red: 1.0, green: 0.78, blue: 0.20, alpha: 0.01).cgColor,
            UIColor.clear.cgColor
        ]
        gradient.locations = [0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.3, y: 0.2)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = bounds
        gradient.opacity = 0.6

        layer.insertSublayer(gradient, at: 0)
        orbGradientLayer = gradient

        animateOrbPulse(gradient)
    }

    private func animateOrbPulse(_ gradient: CAGradientLayer) {
        let pulse = CABasicAnimation(keyPath: "opacity")
        pulse.fromValue = 0.4
        pulse.toValue = 0.8
        pulse.duration = 6.0
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gradient.add(pulse, forKey: "orbPulse")

        let shift = CABasicAnimation(keyPath: "startPoint")
        shift.fromValue = CGPoint(x: 0.2, y: 0.15)
        shift.toValue = CGPoint(x: 0.5, y: 0.35)
        shift.duration = 14.0
        shift.autoreverses = true
        shift.repeatCount = .infinity
        shift.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gradient.add(shift, forKey: "orbShift")
    }

    // MARK: - Breath Cycle (subtle background brightness)

    private func startBreathCycle() {
        let breath = CABasicAnimation(keyPath: "backgroundColor")
        breath.fromValue = UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1.0).cgColor
        breath.toValue = UIColor(red: 0.08, green: 0.08, blue: 0.11, alpha: 1.0).cgColor
        breath.duration = 8.0
        breath.autoreverses = true
        breath.repeatCount = .infinity
        breath.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(breath, forKey: "breathCycle")
    }

    // MARK: - Cleanup

    private func extinguish() {
        displayLink?.invalidate()
        displayLink = nil
        emberLayers.forEach { $0.removeAllAnimations(); $0.removeFromSuperlayer() }
        emberLayers.removeAll()
        orbGradientLayer?.removeAllAnimations()
        orbGradientLayer?.removeFromSuperlayer()
        orbGradientLayer = nil
        layer.removeAnimation(forKey: "breathCycle")
    }
}

// MARK: - CAAnimationGroup Completion Helper

private extension CAAnimationGroup {
    var completion: ((Bool) -> Void)? {
        get { return nil }
        set {
            delegate = AnimationDelegate(completion: newValue)
        }
    }
}

private final class AnimationDelegate: NSObject, CAAnimationDelegate {
    let completion: ((Bool) -> Void)?

    init(completion: ((Bool) -> Void)?) {
        self.completion = completion
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        completion?(flag)
    }
}

// MARK: - Modifier for easy usage

struct EmberBackdrop: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            EmberCanvasView()
                .ignoresSafeArea()
            content
        }
    }
}

extension View {
    /// Applies the animated dark ember background behind content
    func withEmberBackdrop() -> some View {
        modifier(EmberBackdrop())
    }
}
