import UIKit

final class PqPrimaryButton: UIButton {
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        pqStyleButtonAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        pqStyleButtonAppearance()
    }
    
    private func pqStyleButtonAppearance() {
        backgroundColor = PqColors.pureWhitePrimary
        setTitleColor(PqColors.deepIndigoBase, for: .normal)
        titleLabel?.font = PqFonts.headlineRegular()
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
    }
    
    override var isHighlighted: Bool {
        didSet {
            alpha = isHighlighted ? 0.7 : 1.0
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.48
        }
    }
}

