import UIKit

final class PqTagChipView: UIView {
    private let label = UILabel()
    private var isSelectedState = false
    
    var onTap: (() -> Void)?
    
    init(text: String) {
        super.init(frame: .zero)
        label.text = text
        pqConfigureChipLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        pqConfigureChipLayout()
    }
    
    private func pqConfigureChipLayout() {
        backgroundColor = PqColors.dividerSubtle
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = PqColors.dividerSubtle.cgColor
        
        label.font = PqFonts.footnoteRegular()
        label.textColor = PqColors.textPrimaryLight
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pqChipWasTapped))
        addGestureRecognizer(tapGesture)
        
        isAccessibilityElement = true
        accessibilityTraits = .button
    }
    
    func pqApplySelectionState(_ selected: Bool) {
        isSelectedState = selected
        if selected {
            backgroundColor = PqColors.brightTurquoiseAccent.withAlphaComponent(0.3)
            layer.borderColor = PqColors.brightTurquoiseAccent.cgColor
        } else {
            backgroundColor = PqColors.dividerSubtle
            layer.borderColor = PqColors.dividerSubtle.cgColor
        }
        accessibilityValue = selected ? "selected" : "not selected"
    }
    
    @objc private func pqChipWasTapped() {
        PqHapticEngine.shared.pqFireTactileImpulse()
        onTap?()
    }
}

