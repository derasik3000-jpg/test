import UIKit

final class PqSleepWindowCard: UIView {
    private let iconImageView = UIImageView()
    private let timeLabel = UILabel()
    private let statusBadge = UILabel()
    
    var onTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        pqAssembleCardLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        pqAssembleCardLayout()
    }
    
    private func pqAssembleCardLayout() {
        backgroundColor = PqColors.deepIndigoBase.withAlphaComponent(0.3)
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = PqColors.dividerSubtle.cgColor
        
        iconImageView.image = UIImage(systemName: "moon.stars.fill")
        iconImageView.tintColor = PqColors.brightTurquoiseAccent
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)
        
        timeLabel.font = PqFonts.monospacedDigit(size: 18, weight: .semibold)
        timeLabel.textColor = PqColors.textPrimaryLight
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(timeLabel)
        
        statusBadge.font = PqFonts.footnoteRegular()
        statusBadge.textColor = PqColors.textSecondaryFaded
        statusBadge.translatesAutoresizingMaskIntoConstraints = false
        addSubview(statusBadge)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),
            
            timeLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            statusBadge.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            statusBadge.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pqCardWasTouched))
        addGestureRecognizer(tapGesture)
        
        isAccessibilityElement = true
        accessibilityTraits = .button
    }
    
    func pqApplyData(startHour: Int, startMin: Int, endHour: Int, endMin: Int, status: PqSleepWindow.Status) {
        timeLabel.text = String(format: "%02d:%02d – %02d:%02d", startHour, startMin, endHour, endMin)
        
        let window = PqSleepWindow(startHour: startHour, startMinute: startMin, endHour: endHour, endMinute: endMin)
        statusBadge.text = window.pqDescribeWindowPhase(at: Date())
        
        switch status {
        case .beforeWindow:
            layer.borderColor = PqColors.brightTurquoiseAccent.cgColor
        case .inWindow:
            layer.borderColor = PqColors.sleepWindowGlow.cgColor
            layer.shadowColor = PqColors.sleepWindowGlow.cgColor
            layer.shadowRadius = 8
            layer.shadowOpacity = 0.6
            layer.shadowOffset = .zero
        case .afterWindow:
            layer.borderColor = PqColors.afterWindowBorder.cgColor
        }
        
        accessibilityLabel = "Sleep window: \(timeLabel.text ?? ""), \(statusBadge.text ?? "")"
    }
    
    @objc private func pqCardWasTouched() {
        onTap?()
    }
}

