import UIKit

final class PqCheckboxCell: UITableViewCell {
    static let identifier = "PqCheckboxCell"
    
    private let containerView = UIView()
    private let checkboxButton = UIButton(type: .custom)
    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    private let iconImageView = UIImageView()
    
    private var isDoneState = false
    var onToggle: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        pqBuildCellStructure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        pqBuildCellStructure()
    }
    
    private func pqBuildCellStructure() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        checkboxButton.addTarget(self, action: #selector(pqCheckboxWasActivated), for: .touchUpInside)
        containerView.addSubview(checkboxButton)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = PqColors.brightTurquoiseAccent
        containerView.addSubview(iconImageView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = PqFonts.headlineRegular()
        titleLabel.textColor = PqColors.textPrimaryLight
        titleLabel.numberOfLines = 1
        containerView.addSubview(titleLabel)
        
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.font = PqFonts.footnoteRegular()
        descLabel.textColor = PqColors.textSecondaryFaded
        descLabel.numberOfLines = 1
        containerView.addSubview(descLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            checkboxButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            checkboxButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 44),
            checkboxButton.heightAnchor.constraint(equalToConstant: 44),
            
            iconImageView.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 8),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            
            descLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            descLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
    func pqApplyData(title: String, desc: String?, icon: String, isDone: Bool) {
        titleLabel.text = title
        descLabel.text = desc
        descLabel.isHidden = desc == nil || desc?.isEmpty == true
        iconImageView.image = UIImage(systemName: icon)
        isDoneState = isDone
        pqRefreshCheckboxState(isDone: isDone)
    }
    
    private func pqRefreshCheckboxState(isDone: Bool) {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        if isDone {
            let image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
            checkboxButton.setImage(image, for: .normal)
            checkboxButton.tintColor = PqColors.brightTurquoiseAccent
        } else {
            let image = UIImage(systemName: "circle", withConfiguration: config)
            checkboxButton.setImage(image, for: .normal)
            checkboxButton.tintColor = PqColors.checkboxOffBorder
        }
    }
    
    @objc private func pqCheckboxWasActivated() {
        let newState = !isDoneState
        isDoneState = newState
        
        pqRefreshCheckboxState(isDone: newState)
        
        if newState {
            PqHapticEngine.shared.pqFireTactileImpulse()
            if !UIAccessibility.isReduceMotionEnabled {
                checkboxButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                UIView.animate(withDuration: 0.16, delay: 0, options: .curveEaseOut) {
                    self.checkboxButton.transform = .identity
                }
            }
        }
        
        onToggle?(newState)
    }
}

