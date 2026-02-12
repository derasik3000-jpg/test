//
//  AvatarComposerView.swift
//  PULSE
//
//  Avatar Composer - Interactive avatar customization
//

import UIKit

protocol AvatarComposerDelegate: AnyObject {
    func avatarDidChange(_ newAvatar: AvatarGlyph)
}

class AvatarComposerView: UIView {
    
    weak var delegate: AvatarComposerDelegate?
    
    private var currentAvatar: AvatarGlyph = AvatarGlyph(emoji: "😊", shape: .circle, backgroundColor: "pulsePrimary")
    
    private let containerView = UIView()
    private let emojiLabel = UILabel()
    private let shapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        // Container
        containerView.backgroundColor = .clear
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Shape layer
        containerView.layer.addSublayer(shapeLayer)
        
        // Emoji
        emojiLabel.font = .systemFont(ofSize: 48)
        emojiLabel.textAlignment = .center
        containerView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        // Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        addGestureRecognizer(tapGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateShapeLayer()
    }
    
    func configure(with avatar: AvatarGlyph) {
        currentAvatar = avatar
        emojiLabel.text = avatar.emoji
        updateShapeLayer()
    }
    
    private func updateShapeLayer() {
        let size = min(bounds.width, bounds.height)
        let rect = CGRect(x: (bounds.width - size) / 2, y: (bounds.height - size) / 2, width: size, height: size)
        
        let path: UIBezierPath
        
        switch currentAvatar.shape {
        case .circle:
            path = UIBezierPath(ovalIn: rect)
        case .square:
            path = UIBezierPath(roundedRect: rect, cornerRadius: size * 0.2)
        case .triangle:
            path = UIBezierPath()
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.close()
        case .hexagon:
            path = createHexagonPath(in: rect)
        }
        
        shapeLayer.path = path.cgPath
        
        // Convert backgroundColor string to UIColor
        let bgColor: UIColor
        switch currentAvatar.backgroundColor {
        case "pulseCalm": bgColor = .pulseCalm
        case "pulseIntense": bgColor = .pulseIntense
        case "pulseSurface": bgColor = .pulseSurface
        default: bgColor = .pulsePrimary
        }
        
        shapeLayer.fillColor = bgColor.withAlphaComponent(0.2).cgColor
        shapeLayer.strokeColor = bgColor.cgColor
        shapeLayer.lineWidth = 3
    }
    
    private func createHexagonPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let centerX = rect.midX
        let centerY = rect.midY
        let radius = min(rect.width, rect.height) / 2
        
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3
            let x = centerX + radius * cos(angle)
            let y = centerY + radius * sin(angle)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.close()
        return path
    }
    
    @objc private func avatarTapped() {
        PulseHaptics.selection()
        showCustomizationMenu()
    }
    
    private func showCustomizationMenu() {
        guard let viewController = findViewController() else { return }
        
        let alert = UIAlertController(title: "Customize Avatar", message: nil, preferredStyle: .actionSheet)
        
        // Emoji options
        let emojis = ["😊", "😎", "🤓", "😌", "🔥", "⚡️", "🌟", "💫", "🎯", "🚀"]
        for emoji in emojis {
            alert.addAction(UIAlertAction(title: emoji, style: .default) { _ in
                self.currentAvatar.emoji = emoji
                self.configure(with: self.currentAvatar)
                self.delegate?.avatarDidChange(self.currentAvatar)
            })
        }
        
        // Shape options
        alert.addAction(UIAlertAction(title: "Change Shape", style: .default) { _ in
            self.showShapeMenu()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        viewController.present(alert, animated: true)
    }
    
    private func showShapeMenu() {
        guard let viewController = findViewController() else { return }
        
        let alert = UIAlertController(title: "Choose Shape", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "⚫️ Circle", style: .default) { _ in
            self.currentAvatar.shape = .circle
            self.configure(with: self.currentAvatar)
            self.delegate?.avatarDidChange(self.currentAvatar)
        })
        
        alert.addAction(UIAlertAction(title: "⬛️ Square", style: .default) { _ in
            self.currentAvatar.shape = .square
            self.configure(with: self.currentAvatar)
            self.delegate?.avatarDidChange(self.currentAvatar)
        })
        
        alert.addAction(UIAlertAction(title: "🔺 Triangle", style: .default) { _ in
            self.currentAvatar.shape = .triangle
            self.configure(with: self.currentAvatar)
            self.delegate?.avatarDidChange(self.currentAvatar)
        })
        
        alert.addAction(UIAlertAction(title: "⬡ Hexagon", style: .default) { _ in
            self.currentAvatar.shape = .hexagon
            self.configure(with: self.currentAvatar)
            self.delegate?.avatarDidChange(self.currentAvatar)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        viewController.present(alert, animated: true)
    }
    
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            responder = responder?.next
        }
        return nil
    }
}
