//
//  TimelineComponents.swift
//  DAYTRACE
//
//  Components for the enhanced timeline screen
//

import UIKit

// MARK: - TimelineHeaderView

final class TimelineHeaderView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Timeline"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = ColorPalette.primary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your journey at a glance"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = ColorPalette.primary.withAlphaComponent(0.6)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let iconView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chart.line.uptrend.xyaxis", withConfiguration: config)
        iv.tintColor = ColorPalette.primary
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(iconView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconView.trailingAnchor.constraint(equalTo: trailingAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),
            
            heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

// MARK: - StatCard

final class StatCard: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.surface
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.6)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(valueLabel)
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            iconView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            
            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            valueLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -2),
            
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(value: String, label: String, icon: String, color: UIColor) {
        valueLabel.text = value
        titleLabel.text = label
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        iconView.image = UIImage(systemName: icon, withConfiguration: config)
        iconView.tintColor = ColorPalette.primary
    }
}

// MARK: - FilterChipsView

final class FilterChipsView: UIView {
    
    var onFilterChanged: ((TimelineFilter) -> Void)?
    
    private var selectedFilter: TimelineFilter = .all
    private var chipButtons: [FilterChipButton] = []
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        // Create filter chips
        for filter in TimelineFilter.allCases {
            let chip = FilterChipButton()
            chip.configure(title: filter.rawValue, isSelected: filter == selectedFilter)
            chip.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
            chip.tag = TimelineFilter.allCases.firstIndex(of: filter) ?? 0
            chipButtons.append(chip)
            stackView.addArrangedSubview(chip)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func chipTapped(_ sender: FilterChipButton) {
        let filter = TimelineFilter.allCases[sender.tag]
        selectedFilter = filter
        
        for (index, chip) in chipButtons.enumerated() {
            chip.configure(title: TimelineFilter.allCases[index].rawValue, isSelected: index == sender.tag)
        }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        onFilterChanged?(filter)
    }
}

// MARK: - FilterChipButton

final class FilterChipButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        layer.cornerRadius = 16
        titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }
    
    func configure(title: String, isSelected: Bool) {
        setTitle(title, for: .normal)
        
        UIView.animate(withDuration: 0.2) {
            if isSelected {
                self.backgroundColor = .black
                self.setTitleColor(ColorPalette.primary, for: .normal)
            } else {
                self.backgroundColor = ColorPalette.surface.withAlphaComponent(0.5)
                self.setTitleColor(ColorPalette.primary.withAlphaComponent(0.7), for: .normal)
            }
        }
    }
}

// MARK: - TimelineSectionHeader

final class TimelineSectionHeader: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = ColorPalette.primary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorPalette.primary.withAlphaComponent(0.2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = ColorPalette.background
        
        addSubview(titleLabel)
        addSubview(lineView)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            lineView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 12),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            lineView.centerYAnchor.constraint(equalTo: centerYAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
}

// MARK: - TimelineEmptyStateView

final class TimelineEmptyStateView: UIView {
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "📊"
        label.font = .systemFont(ofSize: 56)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "No traces yet"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = ColorPalette.primary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Start tracking your days to see\nyour journey unfold here"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = ColorPalette.primary.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(emojiLabel)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            emojiLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40),
            
            heightAnchor.constraint(equalToConstant: 220)
        ])
    }
}
