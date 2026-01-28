import UIKit
import SwiftUI
import QuartzCore

// MARK: - Elegant Animated Background UIView
class AnimatedGradientBackgroundView: UIView {
    
    // MARK: - Layers
    private var gradientLayer: CAGradientLayer!
    private var particlesLayer: CAEmitterLayer!
    private var glowLayers: [CAGradientLayer] = []
    private var geometricLines: [CAShapeLayer] = []
    
    // MARK: - Theme Colors
    var primaryColor: UIColor = UIColor(red: 0.96, green: 0.84, blue: 0.26, alpha: 1.0)
    var secondaryColor: UIColor = UIColor(red: 1.0, green: 0.88, blue: 0.0, alpha: 1.0)
    var darkBackground: UIColor = UIColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1.0)
    
    // MARK: - Configuration
    private let particleCount: Int = 40
    private let glowCount: Int = 3
    private let lineCount: Int = 4
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    // MARK: - Setup
    private func setupLayers() {
        backgroundColor = darkBackground
        setupGradient()
        setupSoftGlows()
        setupGeometricLines()
        setupParticles()
    }
    
    // MARK: - Gradient Background
    private func setupGradient() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.type = .radial
        gradientLayer.colors = [
            darkBackground.lighter(by: 0.08).cgColor,
            darkBackground.cgColor,
            darkBackground.darker(by: 0.02).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.3)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer.addSublayer(gradientLayer)
        
        // Subtle gradient animation
        let animation = CABasicAnimation(keyPath: "startPoint")
        animation.fromValue = CGPoint(x: 0.3, y: 0.2)
        animation.toValue = CGPoint(x: 0.7, y: 0.4)
        animation.duration = 20.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gradientLayer.add(animation, forKey: "gradientMove")
    }
    
    // MARK: - Soft Ambient Glows
    private func setupSoftGlows() {
        let glowConfigs: [(position: CGPoint, size: CGFloat, color: UIColor, opacity: Float)] = [
            (CGPoint(x: 0.2, y: 0.15), 300, primaryColor, 0.04),
            (CGPoint(x: 0.85, y: 0.7), 250, secondaryColor, 0.03),
            (CGPoint(x: 0.5, y: 0.9), 350, primaryColor, 0.025)
        ]
        
        for (index, config) in glowConfigs.enumerated() {
            let glowLayer = CAGradientLayer()
            glowLayer.type = .radial
            glowLayer.colors = [
                config.color.withAlphaComponent(CGFloat(config.opacity)).cgColor,
                config.color.withAlphaComponent(0).cgColor
            ]
            glowLayer.locations = [0.0, 1.0]
            glowLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
            glowLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
            
            let size = config.size
            glowLayer.frame = CGRect(
                x: bounds.width * config.position.x - size/2,
                y: bounds.height * config.position.y - size/2,
                width: size,
                height: size
            )
            glowLayer.cornerRadius = size / 2
            
            layer.addSublayer(glowLayer)
            glowLayers.append(glowLayer)
            
            // Floating animation
            animateGlow(glowLayer, index: index)
        }
    }
    
    private func animateGlow(_ glow: CAGradientLayer, index: Int) {
        let duration = Double.random(in: 15...25)
        let xOffset = CGFloat.random(in: 30...60)
        let yOffset = CGFloat.random(in: 20...40)
        
        // Position animation
        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        let startPos = glow.position
        positionAnimation.values = [
            startPos,
            CGPoint(x: startPos.x + xOffset, y: startPos.y - yOffset),
            CGPoint(x: startPos.x - xOffset/2, y: startPos.y + yOffset/2),
            startPos
        ]
        positionAnimation.keyTimes = [0, 0.33, 0.66, 1]
        positionAnimation.duration = duration
        positionAnimation.repeatCount = .infinity
        positionAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        glow.add(positionAnimation, forKey: "glowPosition\(index)")
        
        // Opacity pulse
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0.6
        opacityAnimation.duration = duration / 2
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = .infinity
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        glow.add(opacityAnimation, forKey: "glowOpacity\(index)")
    }
    
    // MARK: - Geometric Lines
    private func setupGeometricLines() {
        for i in 0..<lineCount {
            let line = CAShapeLayer()
            line.strokeColor = primaryColor.withAlphaComponent(0.03).cgColor
            line.fillColor = UIColor.clear.cgColor
            line.lineWidth = 0.5
            line.lineCap = .round
            
            layer.addSublayer(line)
            geometricLines.append(line)
            
            updateLinePath(line, index: i)
            animateLine(line, index: i)
        }
    }
    
    private func updateLinePath(_ line: CAShapeLayer, index: Int) {
        let path = UIBezierPath()
        
        let isHorizontal = index % 2 == 0
        let offset = CGFloat(index) * 0.2 + 0.2
        
        if isHorizontal {
            let y = bounds.height * offset
            path.move(to: CGPoint(x: -50, y: y))
            
            // Create subtle wave
            let segments = 5
            let segmentWidth = (bounds.width + 100) / CGFloat(segments)
            for s in 0..<segments {
                let x = CGFloat(s + 1) * segmentWidth - 50
                let controlY = y + CGFloat.random(in: -20...20)
                path.addQuadCurve(
                    to: CGPoint(x: x, y: y),
                    controlPoint: CGPoint(x: x - segmentWidth/2, y: controlY)
                )
            }
        } else {
            let x = bounds.width * offset
            path.move(to: CGPoint(x: x, y: -50))
            
            let segments = 5
            let segmentHeight = (bounds.height + 100) / CGFloat(segments)
            for s in 0..<segments {
                let y = CGFloat(s + 1) * segmentHeight - 50
                let controlX = x + CGFloat.random(in: -20...20)
                path.addQuadCurve(
                    to: CGPoint(x: x, y: y),
                    controlPoint: CGPoint(x: controlX, y: y - segmentHeight/2)
                )
            }
        }
        
        line.path = path.cgPath
    }
    
    private func animateLine(_ line: CAShapeLayer, index: Int) {
        // Subtle opacity breathing
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.3
        opacityAnimation.toValue = 0.8
        opacityAnimation.duration = Double.random(in: 4...8)
        opacityAnimation.autoreverses = true
        opacityAnimation.repeatCount = .infinity
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        line.add(opacityAnimation, forKey: "lineOpacity\(index)")
        
        // Stroke animation (drawing effect)
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue = 0.9
        strokeAnimation.toValue = 1.0
        strokeAnimation.duration = Double.random(in: 6...10)
        strokeAnimation.autoreverses = true
        strokeAnimation.repeatCount = .infinity
        strokeAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        line.add(strokeAnimation, forKey: "lineStroke\(index)")
    }
    
    // MARK: - Particle System
    private func setupParticles() {
        particlesLayer = CAEmitterLayer()
        particlesLayer.emitterPosition = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        particlesLayer.emitterSize = CGSize(width: bounds.width, height: bounds.height)
        particlesLayer.emitterShape = .rectangle
        particlesLayer.renderMode = .additive
        
        // Small floating dots
        let dotCell = makeParticleCell(
            color: primaryColor.withAlphaComponent(0.3),
            size: 2,
            lifetime: 20,
            velocity: 5,
            birthRate: 0.8
        )
        
        // Tiny sparkles
        let sparkleCell = makeParticleCell(
            color: secondaryColor.withAlphaComponent(0.4),
            size: 1.5,
            lifetime: 15,
            velocity: 3,
            birthRate: 0.5
        )
        
        // Very faint larger particles
        let softCell = makeParticleCell(
            color: primaryColor.withAlphaComponent(0.15),
            size: 4,
            lifetime: 25,
            velocity: 2,
            birthRate: 0.2
        )
        
        particlesLayer.emitterCells = [dotCell, sparkleCell, softCell]
        layer.addSublayer(particlesLayer)
    }
    
    private func makeParticleCell(
        color: UIColor,
        size: CGFloat,
        lifetime: Float,
        velocity: CGFloat,
        birthRate: Float
    ) -> CAEmitterCell {
        let cell = CAEmitterCell()
        
        // Create circular particle image
        let particleSize = size * 4
        UIGraphicsBeginImageContextWithOptions(CGSize(width: particleSize, height: particleSize), false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            let rect = CGRect(x: 0, y: 0, width: particleSize, height: particleSize)
            
            // Soft circular gradient
            let colors = [
                UIColor.white.cgColor,
                UIColor.white.withAlphaComponent(0.5).cgColor,
                UIColor.white.withAlphaComponent(0).cgColor
            ] as CFArray
            
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.4, 1]) {
                context.drawRadialGradient(
                    gradient,
                    startCenter: CGPoint(x: particleSize/2, y: particleSize/2),
                    startRadius: 0,
                    endCenter: CGPoint(x: particleSize/2, y: particleSize/2),
                    endRadius: particleSize/2,
                    options: []
                )
            }
        }
        let particleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        cell.contents = particleImage?.cgImage
        cell.color = color.cgColor
        cell.birthRate = birthRate
        cell.lifetime = lifetime
        cell.lifetimeRange = lifetime * 0.3
        cell.velocity = velocity
        cell.velocityRange = velocity * 0.5
        cell.emissionRange = .pi * 2
        cell.scale = size / particleSize
        cell.scaleRange = cell.scale * 0.3
        cell.alphaSpeed = -0.02
        cell.alphaRange = 0.3
        
        return cell
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer?.frame = bounds
        particlesLayer?.emitterPosition = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        particlesLayer?.emitterSize = CGSize(width: bounds.width, height: bounds.height)
        
        // Update glow positions
        let glowConfigs: [(position: CGPoint, size: CGFloat)] = [
            (CGPoint(x: 0.2, y: 0.15), 300),
            (CGPoint(x: 0.85, y: 0.7), 250),
            (CGPoint(x: 0.5, y: 0.9), 350)
        ]
        
        for (index, glow) in glowLayers.enumerated() where index < glowConfigs.count {
            let config = glowConfigs[index]
            let size = config.size
            glow.frame = CGRect(
                x: bounds.width * config.position.x - size/2,
                y: bounds.height * config.position.y - size/2,
                width: size,
                height: size
            )
        }
        
        // Update line paths
        for (index, line) in geometricLines.enumerated() {
            updateLinePath(line, index: index)
        }
    }
    
    // MARK: - Theme Update
    func updateTheme(primary: UIColor, secondary: UIColor, background: UIColor) {
        primaryColor = primary
        secondaryColor = secondary
        darkBackground = background
        
        // Update gradient
        gradientLayer.colors = [
            darkBackground.lighter(by: 0.08).cgColor,
            darkBackground.cgColor,
            darkBackground.darker(by: 0.02).cgColor
        ]
        
        // Update glows
        let colors: [UIColor] = [primary, secondary, primary]
        let opacities: [Float] = [0.04, 0.03, 0.025]
        for (index, glow) in glowLayers.enumerated() where index < colors.count {
            glow.colors = [
                colors[index].withAlphaComponent(CGFloat(opacities[index])).cgColor,
                colors[index].withAlphaComponent(0).cgColor
            ]
        }
        
        // Update lines
        for line in geometricLines {
            line.strokeColor = primary.withAlphaComponent(0.03).cgColor
        }
        
        // Update particles
        if let cells = particlesLayer.emitterCells {
            for (index, cell) in cells.enumerated() {
                switch index {
                case 0: cell.color = primary.withAlphaComponent(0.3).cgColor
                case 1: cell.color = secondary.withAlphaComponent(0.4).cgColor
                case 2: cell.color = primary.withAlphaComponent(0.15).cgColor
                default: break
                }
            }
        }
        
        backgroundColor = darkBackground
    }
}

// MARK: - UIColor Extensions
extension UIColor {
    func lighter(by percentage: CGFloat) -> UIColor {
        return adjust(by: abs(percentage))
    }
    
    func darker(by percentage: CGFloat) -> UIColor {
        return adjust(by: -abs(percentage))
    }
    
    private func adjust(by percentage: CGFloat) -> UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(
            red: min(max(red + percentage, 0), 1),
            green: min(max(green + percentage, 0), 1),
            blue: min(max(blue + percentage, 0), 1),
            alpha: alpha
        )
    }
}

// MARK: - SwiftUI Wrapper
struct AnimatedGradientBackground: UIViewRepresentable {
    @ObservedObject var themeManager = CuqavuThemeManager.shared
    
    func makeUIView(context: Context) -> AnimatedGradientBackgroundView {
        let view = AnimatedGradientBackgroundView()
        updateThemeColors(view: view)
        return view
    }
    
    func updateUIView(_ uiView: AnimatedGradientBackgroundView, context: Context) {
        updateThemeColors(view: uiView)
    }
    
    private func updateThemeColors(view: AnimatedGradientBackgroundView) {
        let theme = themeManager.degubaCurrentTheme
        
        let primaryUIColor = UIColor(
            red: CGFloat(theme.evubewPrimary.components.red),
            green: CGFloat(theme.evubewPrimary.components.green),
            blue: CGFloat(theme.evubewPrimary.components.blue),
            alpha: 1.0
        )
        
        let secondaryUIColor = UIColor(
            red: CGFloat(theme.cuqavuSecondary.components.red),
            green: CGFloat(theme.cuqavuSecondary.components.green),
            blue: CGFloat(theme.cuqavuSecondary.components.blue),
            alpha: 1.0
        )
        
        let backgroundUIColor = UIColor(
            red: CGFloat(theme.degubaBackground.components.red),
            green: CGFloat(theme.degubaBackground.components.green),
            blue: CGFloat(theme.degubaBackground.components.blue),
            alpha: 1.0
        )
        
        view.updateTheme(
            primary: primaryUIColor,
            secondary: secondaryUIColor,
            background: backgroundUIColor
        )
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        AnimatedGradientBackground()
            .ignoresSafeArea()
        
        VStack(spacing: 20) {
            Text("Content Title")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Your main content goes here")
                .foregroundColor(.white.opacity(0.7))
        }
    }
}
