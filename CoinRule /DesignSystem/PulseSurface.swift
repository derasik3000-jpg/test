//
//  PulseSurface.swift
//  PULSE
//
//  Design System - Surface Components
//

import UIKit

class PulseSurface: UIView {
    
    enum Style {
        case card
        case panel
        case overlay
    }
    
    private let style: Style
    
    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAppearance() {
        switch style {
        case .card:
            backgroundColor = .pulseSurface
            layer.cornerRadius = 16
            layer.borderWidth = 1
            layer.borderColor = UIColor.pulsePrimary.withAlphaComponent(0.2).cgColor
            layer.shadowColor = UIColor.pulsePrimary.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 4)
            layer.shadowRadius = 8
            layer.shadowOpacity = 0.15
            
        case .panel:
            backgroundColor = .pulseSurfaceLight
            layer.cornerRadius = 12
            
        case .overlay:
            backgroundColor = .pulsePrimary.withAlphaComponent(0.8)
            layer.cornerRadius = 20
        }
    }
}

// MARK: - Pulse Button

class PulseButton: UIButton {
    
    enum Style {
        case primary
        case secondary
        case ghost
    }
    
    private let buttonStyle: Style
    
    init(style: Style, title: String) {
        self.buttonStyle = style
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAppearance() {
        titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        layer.cornerRadius = 12
        
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
        configuration = config
        
        switch buttonStyle {
        case .primary:
            backgroundColor = .pulsePrimary
            setTitleColor(.black, for: .normal)
            setTitleColor(.black.withAlphaComponent(0.6), for: .highlighted)
            
        case .secondary:
            backgroundColor = .pulseSurface
            setTitleColor(.pulsePrimary, for: .normal)
            setTitleColor(.pulsePrimary.withAlphaComponent(0.6), for: .highlighted)
            
        case .ghost:
            backgroundColor = .clear
            setTitleColor(.pulsePrimary, for: .normal)
            setTitleColor(.pulsePrimary.withAlphaComponent(0.6), for: .highlighted)
            layer.borderWidth = 2
            layer.borderColor = UIColor.pulsePrimary.cgColor
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.alpha = self.isHighlighted ? 0.7 : 1.0
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
            }
        }
    }
}
