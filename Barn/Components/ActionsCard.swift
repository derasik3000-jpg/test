//
//  ActionsCard.swift
//  DAYTRACE
//
//  Actions list component
//

import UIKit

final class ActionsCard: UIView {
    
    var onActionStateChanged: ((UUID, ActionState) -> Void)?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Today's Actions"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No actions yet"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = ColorPalette.surface
        layer.cornerRadius = 16
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        addSubview(actionsStack)
        addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            actionsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            actionsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            actionsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            actionsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 20)
        ])
    }
    
    func setActions(_ actions: [TraceAction]) {
        actionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if actions.isEmpty {
            emptyLabel.isHidden = false
        } else {
            emptyLabel.isHidden = true
            for action in actions {
                let row = ActionRow(action: action)
                row.onStateTapped = { [weak self] newState in
                    self?.onActionStateChanged?(action.id, newState)
                }
                actionsStack.addArrangedSubview(row)
            }
        }
    }
}

final class ActionRow: UIView {
    
    var onStateTapped: ((ActionState) -> Void)?
    
    private let action: TraceAction
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stateButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    init(action: TraceAction) {
        self.action = action
        super.init(frame: .zero)
        setupUI()
        updateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = ColorPalette.primary.withAlphaComponent(0.1)
        layer.cornerRadius = 8
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(textLabel)
        addSubview(stateButton)
        
        stateButton.addTarget(self, action: #selector(stateTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 50),
            
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            textLabel.trailingAnchor.constraint(equalTo: stateButton.leadingAnchor, constant: -8),
            
            stateButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stateButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            stateButton.widthAnchor.constraint(equalToConstant: 60),
            stateButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func updateUI() {
        textLabel.text = action.text
        
        switch action.state {
        case .pending:
            stateButton.setTitle("⏳", for: .normal)
            stateButton.backgroundColor = ColorPalette.surface
        case .done:
            stateButton.setTitle("✅", for: .normal)
            stateButton.backgroundColor = ColorPalette.primary
        case .skipped:
            stateButton.setTitle("⏭️", for: .normal)
            stateButton.backgroundColor = ColorPalette.surface.withAlphaComponent(0.5)
        }
    }
    
    @objc private func stateTapped() {
        let nextState: ActionState
        switch action.state {
        case .pending:
            nextState = .done
        case .done:
            nextState = .skipped
        case .skipped:
            nextState = .pending
        }
        
        onStateTapped?(nextState)
        
        AnimationKit.springScale(view: stateButton, scale: 0.85)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
