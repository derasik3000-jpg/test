//
//  AddActionSheet.swift
//  DAYTRACE
//
//  Enhanced action creation with categories, priority, time, notes, and emotion
//

import UIKit

final class AddActionSheet: UIViewController {
    
    var onActionCreated: ((TraceAction) -> Void)?
    
    // MARK: - Form Data
    
    private var actionText: String = ""
    private var selectedCategory: ActionCategory = .personal
    private var selectedPriority: ActionPriority = .medium
    private var estimatedMinutes: Int?
    private var notes: String = ""
    private var selectedTags: [String] = []
    private var selectedEmotion: ActionEmotion?
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        sv.keyboardDismissMode = .interactive
        return sv
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Header
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "New Action"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = ColorPalette.primary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        btn.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        btn.tintColor = ColorPalette.primary.withAlphaComponent(0.6)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // Action Text
    private let actionLabel: UILabel = {
        let label = UILabel()
        label.text = "What will you do?"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = ColorPalette.primary
        return label
    }()
    
    private let actionTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "e.g., Morning workout"
        field.font = .systemFont(ofSize: 16)
        field.textColor = .white
        field.backgroundColor = ColorPalette.primary.withAlphaComponent(0.1)
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 2
        field.layer.borderColor = ColorPalette.primary.withAlphaComponent(0.2).cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.rightViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    // Category
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "Category"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = ColorPalette.primary
        return label
    }()
    
    private let categoryCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    // Priority
    private let priorityLabel: UILabel = {
        let label = UILabel()
        label.text = "Priority"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = ColorPalette.primary
        return label
    }()
    
    private let prioritySegment: UISegmentedControl = {
        let items = ActionPriority.allCases.map { "\($0.emoji) \($0.rawValue)" }
        let segment = UISegmentedControl(items: items)
        segment.selectedSegmentIndex = 1 // Medium
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()
    
    // Time Estimate
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "Estimated Time (optional)"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = ColorPalette.primary
        return label
    }()
    
    private let timeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let time15Button = createTimeButton(minutes: 15)
    private let time30Button = createTimeButton(minutes: 30)
    private let time60Button = createTimeButton(minutes: 60)
    private let timeCustomButton = createTimeButton(minutes: nil)
    
    // Emotion
    private let emotionLabel: UILabel = {
        let label = UILabel()
        label.text = "How do you feel about this?"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = ColorPalette.primary
        return label
    }()
    
    private let emotionCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    // Notes
    private let notesLabel: UILabel = {
        let label = UILabel()
        label.text = "Notes (optional)"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = ColorPalette.primary
        return label
    }()
    
    private let notesTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 15)
        tv.textColor = .white
        tv.backgroundColor = ColorPalette.primary.withAlphaComponent(0.1)
        tv.layer.cornerRadius = 12
        tv.layer.borderWidth = 2
        tv.layer.borderColor = ColorPalette.primary.withAlphaComponent(0.2).cgColor
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    // Create Button
    private let createButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Create Action", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.setTitleColor(ColorPalette.primary, for: .normal)
        btn.backgroundColor = ColorPalette.background
        btn.layer.cornerRadius = 16
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.shadowColor = ColorPalette.background.cgColor
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowRadius = 8
        return btn
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorPalette.surface
        setupUI()
        setupActions()
        setupKeyboardObservers()
        configurePrioritySegment()
        
        // Focus on text field
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.actionTextField.becomeFirstResponder()
        }
    }
    
    private func configurePrioritySegment() {
        // Normal state - белый текст
        prioritySegment.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 13, weight: .medium)
        ], for: .normal)
        
        // Selected state - белый текст на желтом фоне
        prioritySegment.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 13, weight: .bold)
        ], for: .selected)
        
        // Цвета фона
        prioritySegment.backgroundColor = ColorPalette.surface
        prioritySegment.selectedSegmentTintColor = ColorPalette.primary
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        // Header
        headerView.addSubview(titleLabel)
        headerView.addSubview(closeButton)
        contentStack.addArrangedSubview(headerView)
        
        // Action text
        contentStack.addArrangedSubview(actionLabel)
        contentStack.addArrangedSubview(actionTextField)
        
        // Category
        contentStack.addArrangedSubview(categoryLabel)
        contentStack.addArrangedSubview(categoryCollection)
        
        // Priority
        contentStack.addArrangedSubview(priorityLabel)
        contentStack.addArrangedSubview(prioritySegment)
        
        // Time
        contentStack.addArrangedSubview(timeLabel)
        timeStack.addArrangedSubview(time15Button)
        timeStack.addArrangedSubview(time30Button)
        timeStack.addArrangedSubview(time60Button)
        timeStack.addArrangedSubview(timeCustomButton)
        contentStack.addArrangedSubview(timeStack)
        
        // Emotion
        contentStack.addArrangedSubview(emotionLabel)
        contentStack.addArrangedSubview(emotionCollection)
        
        // Notes
        contentStack.addArrangedSubview(notesLabel)
        contentStack.addArrangedSubview(notesTextView)
        
        // Create button
        view.addSubview(createButton)
        
        // Collection views
        categoryCollection.delegate = self
        categoryCollection.dataSource = self
        categoryCollection.register(CategoryCell.self, forCellWithReuseIdentifier: "CategoryCell")
        
        emotionCollection.delegate = self
        emotionCollection.dataSource = self
        emotionCollection.register(EmotionCell.self, forCellWithReuseIdentifier: "EmotionCell")
        
        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -16),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            
            headerView.heightAnchor.constraint(equalToConstant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            
            actionTextField.heightAnchor.constraint(equalToConstant: 50),
            categoryCollection.heightAnchor.constraint(equalToConstant: 80),
            timeStack.heightAnchor.constraint(equalToConstant: 50),
            emotionCollection.heightAnchor.constraint(equalToConstant: 70),
            notesTextView.heightAnchor.constraint(equalToConstant: 100),
            
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        actionTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        prioritySegment.addTarget(self, action: #selector(priorityChanged), for: .valueChanged)
        
        time15Button.addTarget(self, action: #selector(timeButtonTapped), for: .touchUpInside)
        time30Button.addTarget(self, action: #selector(timeButtonTapped), for: .touchUpInside)
        time60Button.addTarget(self, action: #selector(timeButtonTapped), for: .touchUpInside)
        timeCustomButton.addTarget(self, action: #selector(timeButtonTapped), for: .touchUpInside)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - Actions
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createTapped() {
        guard !actionText.isEmpty else {
            // Show error
            animateShake(view: actionTextField)
            return
        }
        
        let action = TraceAction(
            text: actionText,
            category: selectedCategory,
            priority: selectedPriority,
            estimatedMinutes: estimatedMinutes,
            notes: notes.isEmpty ? nil : notes,
            emotion: selectedEmotion
        )
        
        onActionCreated?(action)
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        dismiss(animated: true)
    }
    
    @objc private func textFieldChanged() {
        actionText = actionTextField.text ?? ""
        updateCreateButton()
    }
    
    @objc private func priorityChanged() {
        let priorities: [ActionPriority] = [.low, .medium, .high]
        selectedPriority = priorities[prioritySegment.selectedSegmentIndex]
    }
    
    @objc private func timeButtonTapped(_ sender: UIButton) {
        // Deselect all
        [time15Button, time30Button, time60Button, timeCustomButton].forEach {
            $0.backgroundColor = ColorPalette.primary.withAlphaComponent(0.1)
            $0.layer.borderColor = ColorPalette.primary.withAlphaComponent(0.2).cgColor
        }
        
        // Select tapped - белая обводка
        sender.backgroundColor = ColorPalette.primary.withAlphaComponent(0.2)
        sender.layer.borderColor = UIColor.white.cgColor
        
        if sender == time15Button {
            estimatedMinutes = 15
        } else if sender == time30Button {
            estimatedMinutes = 30
        } else if sender == time60Button {
            estimatedMinutes = 60
        } else {
            // Custom time picker
            showCustomTimePicker()
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset.bottom = keyboardHeight
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
    }
    
    // MARK: - Helpers
    
    private func updateCreateButton() {
        createButton.isEnabled = !actionText.isEmpty
        createButton.alpha = actionText.isEmpty ? 0.5 : 1.0
    }
    
    private func animateShake(view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-10, 10, -10, 10, -5, 5, 0]
        view.layer.add(animation, forKey: "shake")
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    private func showCustomTimePicker() {
        // TODO: Implement custom time picker
        estimatedMinutes = nil
    }
    
    private static func createTimeButton(minutes: Int?) -> UIButton {
        let btn = UIButton(type: .system)
        if let minutes = minutes {
            btn.setTitle("\(minutes)m", for: .normal)
        } else {
            btn.setTitle("Custom", for: .normal)
        }
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        btn.setTitleColor(ColorPalette.primary, for: .normal)
        btn.backgroundColor = ColorPalette.primary.withAlphaComponent(0.1)
        btn.layer.cornerRadius = 12
        btn.layer.borderWidth = 2
        btn.layer.borderColor = ColorPalette.primary.withAlphaComponent(0.2).cgColor
        return btn
    }
}

// MARK: - UICollectionView

extension AddActionSheet: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollection {
            return ActionCategory.allCases.count
        } else {
            return ActionEmotion.allCases.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            let category = ActionCategory.allCases[indexPath.item]
            cell.configure(category: category, isSelected: category == selectedCategory)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmotionCell", for: indexPath) as! EmotionCell
            let emotion = ActionEmotion.allCases[indexPath.item]
            cell.configure(emotion: emotion, isSelected: emotion == selectedEmotion)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoryCollection {
            return CGSize(width: 70, height: 80)
        } else {
            return CGSize(width: 60, height: 70)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollection {
            selectedCategory = ActionCategory.allCases[indexPath.item]
            categoryCollection.reloadData()
        } else {
            let emotion = ActionEmotion.allCases[indexPath.item]
            selectedEmotion = (selectedEmotion == emotion) ? nil : emotion
            emotionCollection.reloadData()
        }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - Category Cell

private class CategoryCell: UICollectionViewCell {
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 1
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
        contentView.addSubview(emojiLabel)
        contentView.addSubview(nameLabel)
        
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 2
        
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4)
        ])
    }
    
    func configure(category: ActionCategory, isSelected: Bool) {
        emojiLabel.text = category.emoji
        nameLabel.text = category.rawValue
        
        if isSelected {
            contentView.backgroundColor = ColorPalette.primary.withAlphaComponent(0.2)
            contentView.layer.borderColor = UIColor.white.cgColor
            nameLabel.textColor = .white
        } else {
            contentView.backgroundColor = ColorPalette.primary.withAlphaComponent(0.05)
            contentView.layer.borderColor = ColorPalette.primary.withAlphaComponent(0.2).cgColor
            nameLabel.textColor = ColorPalette.primary.withAlphaComponent(0.7)
        }
    }
}

// MARK: - Emotion Cell

private class EmotionCell: UICollectionViewCell {
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center
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
        contentView.addSubview(emojiLabel)
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 2
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(emotion: ActionEmotion, isSelected: Bool) {
        emojiLabel.text = emotion.emoji
        
        if isSelected {
            contentView.backgroundColor = ColorPalette.primary.withAlphaComponent(0.2)
            contentView.layer.borderColor = UIColor.white.cgColor
            emojiLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } else {
            contentView.backgroundColor = ColorPalette.primary.withAlphaComponent(0.05)
            contentView.layer.borderColor = ColorPalette.primary.withAlphaComponent(0.2).cgColor
            emojiLabel.transform = .identity
        }
    }
}

