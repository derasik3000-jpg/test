//
//  PulseCoreScreen.swift
//  Travel Budget Tracker
//
//  Tab 1 - Expense Entry Screen
//

import UIKit

class PulseCoreScreen: UIViewController {
    
    private var currentRecord: DailyPulseRecord
    private var selectedMood: Mood = .normal
    
    private let waveformView = WaveformBackgroundView()
    private let pulseCircle = UIView()
    private let pulseLabel = UILabel()
    private let moodSelector = MoodSelectorView()
    private let categorySelector = CategorySelectorView()
    private let noteInputContainer = UIView()
    private let amountTextField = UITextField()
    private let noteTextField = UITextField()
    private let interactionBar = UIView()
    private var selectedCategory: ExpenseCategory = .food
    
    private let statsContainer = UIView()
    private let todayBeatsLabel = UILabel()
    private let streakLabel = UILabel()
    private let evolutionLabel = UILabel()
    private let settingsButton = UIButton(type: .system)
    
    private var keyboardHeight: CGFloat = 0
    
    init() {
        self.currentRecord = PulseStorage.shared.loadTodayRecord()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .pulseBackground
        
        setupWaveform()
        setupSettingsButton()
        setupStatsContainer()
        setupCategorySelector()
        setupPulseCircle()
        setupInteractionBar()
        setupMoodSelector()
        setupKeyboardObservers()
        
        // Убедимся что кнопка настроек всегда сверху
        view.bringSubviewToFront(settingsButton)
        
        updateStats()
        
        PulseHaptics.prepare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentRecord = PulseStorage.shared.loadTodayRecord()
        updateStats()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupWaveform() {
        waveformView.isUserInteractionEnabled = false
        view.addSubview(waveformView)
        waveformView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            waveformView.topAnchor.constraint(equalTo: view.topAnchor),
            waveformView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            waveformView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            waveformView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSettingsButton() {
        settingsButton.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        settingsButton.tintColor = .pulsePrimary
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        settingsButton.backgroundColor = .pulseSurface
        settingsButton.layer.cornerRadius = 22
        settingsButton.isUserInteractionEnabled = true
        
        view.addSubview(settingsButton)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            settingsButton.widthAnchor.constraint(equalToConstant: 44),
            settingsButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Убедимся что кнопка поверх всех элементов
        view.bringSubviewToFront(settingsButton)
    }
    
    private func setupStatsContainer() {
        statsContainer.backgroundColor = .clear
        
        todayBeatsLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        todayBeatsLabel.textColor = .pulsePrimary
        todayBeatsLabel.textAlignment = .center
        
        streakLabel.font = .systemFont(ofSize: 13, weight: .medium)
        streakLabel.textColor = .pulseTextSecondary
        streakLabel.textAlignment = .center
        
        evolutionLabel.font = .systemFont(ofSize: 13, weight: .medium)
        evolutionLabel.textColor = .pulseTextSecondary
        evolutionLabel.textAlignment = .center
        
        let statsStack = UIStackView(arrangedSubviews: [todayBeatsLabel, streakLabel, evolutionLabel])
        statsStack.axis = .vertical
        statsStack.spacing = 4
        statsStack.alignment = .center
        
        statsContainer.addSubview(statsStack)
        view.addSubview(statsContainer)
        
        statsContainer.translatesAutoresizingMaskIntoConstraints = false
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            statsContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            statsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            statsStack.topAnchor.constraint(equalTo: statsContainer.topAnchor),
            statsStack.centerXAnchor.constraint(equalTo: statsContainer.centerXAnchor),
            statsStack.bottomAnchor.constraint(equalTo: statsContainer.bottomAnchor)
        ])
    }
    
    
    private func setupPulseCircle() {
        pulseCircle.backgroundColor = .pulsePrimary
        pulseCircle.layer.cornerRadius = 100
        
        pulseLabel.text = "ADD\nEXPENSE"
        pulseLabel.font = .systemFont(ofSize: 20, weight: .bold)
        pulseLabel.textColor = .black
        pulseLabel.textAlignment = .center
        pulseLabel.numberOfLines = 2
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pulseTapped))
        pulseCircle.addGestureRecognizer(tapGesture)
        pulseCircle.isUserInteractionEnabled = true
        
        pulseCircle.addSubview(pulseLabel)
        view.addSubview(pulseCircle)
        
        pulseCircle.translatesAutoresizingMaskIntoConstraints = false
        pulseLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pulseCircle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pulseCircle.topAnchor.constraint(equalTo: categorySelector.bottomAnchor, constant: 30),
            pulseCircle.widthAnchor.constraint(equalToConstant: 200),
            pulseCircle.heightAnchor.constraint(equalToConstant: 200),
            
            pulseLabel.centerXAnchor.constraint(equalTo: pulseCircle.centerXAnchor),
            pulseLabel.centerYAnchor.constraint(equalTo: pulseCircle.centerYAnchor)
        ])
        
        startPulseAnimation()
    }
    
    private func setupCategorySelector() {
        categorySelector.delegate = self
        
        view.addSubview(categorySelector)
        categorySelector.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            categorySelector.topAnchor.constraint(equalTo: statsContainer.bottomAnchor, constant: 30),
            categorySelector.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categorySelector.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            categorySelector.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupMoodSelector() {
        moodSelector.delegate = self
        
        view.addSubview(moodSelector)
        moodSelector.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            moodSelector.bottomAnchor.constraint(equalTo: interactionBar.topAnchor, constant: -20),
            moodSelector.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            moodSelector.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupInteractionBar() {
        interactionBar.backgroundColor = .pulseSurface
        interactionBar.layer.cornerRadius = 20
        interactionBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // Amount text field
        amountTextField.placeholder = "Amount (e.g., 25.50)"
        amountTextField.font = .systemFont(ofSize: 20, weight: .semibold)
        amountTextField.textColor = .pulsePrimary
        amountTextField.backgroundColor = UIColor.pulsePrimary.withAlphaComponent(0.1)
        amountTextField.layer.cornerRadius = 12
        amountTextField.keyboardType = .decimalPad
        amountTextField.clearButtonMode = .whileEditing
        amountTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        amountTextField.leftViewMode = .always
        amountTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        amountTextField.rightViewMode = .always
        amountTextField.delegate = self
        amountTextField.attributedPlaceholder = NSAttributedString(
            string: "Amount (e.g., 25.50)",
            attributes: [.foregroundColor: UIColor.pulseTextSecondary]
        )
        
        // Note text field
        noteTextField.placeholder = "What did you buy? (optional)"
        noteTextField.font = .systemFont(ofSize: 16, weight: .regular)
        noteTextField.textColor = .pulsePrimary
        noteTextField.backgroundColor = .pulseSurface
        noteTextField.layer.cornerRadius = 12
        noteTextField.returnKeyType = .done
        noteTextField.clearButtonMode = .whileEditing
        noteTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        noteTextField.leftViewMode = .always
        noteTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        noteTextField.rightViewMode = .always
        noteTextField.delegate = self
        noteTextField.attributedPlaceholder = NSAttributedString(
            string: "What did you buy? (optional)",
            attributes: [.foregroundColor: UIColor.pulseTextSecondary]
        )
        
        interactionBar.addSubview(amountTextField)
        interactionBar.addSubview(noteTextField)
        view.addSubview(interactionBar)
        
        interactionBar.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        noteTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            interactionBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            interactionBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            interactionBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            interactionBar.heightAnchor.constraint(equalToConstant: 140),
            
            amountTextField.topAnchor.constraint(equalTo: interactionBar.topAnchor, constant: 16),
            amountTextField.leadingAnchor.constraint(equalTo: interactionBar.leadingAnchor, constant: 20),
            amountTextField.trailingAnchor.constraint(equalTo: interactionBar.trailingAnchor, constant: -20),
            amountTextField.heightAnchor.constraint(equalToConstant: 52),
            
            noteTextField.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 12),
            noteTextField.leadingAnchor.constraint(equalTo: interactionBar.leadingAnchor, constant: 20),
            noteTextField.trailingAnchor.constraint(equalTo: interactionBar.trailingAnchor, constant: -20),
            noteTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Keyboard
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: 0.3) {
            self.interactionBar.transform = CGAffineTransform(translationX: 0, y: -self.keyboardHeight + self.view.safeAreaInsets.bottom)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.interactionBar.transform = .identity
        }
    }
    
    // MARK: - Actions
    
    @objc private func pulseTapped() {
        // Проверяем, что введена сумма
        guard let amountText = amountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !amountText.isEmpty,
              let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")),
              amount > 0 else {
            // Показываем предупреждение
            let alert = UIAlertController(
                title: "Amount Required",
                message: "Please enter the expense amount",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            return
        }
        
        PulseHaptics.beat()
        
        // Получаем текст заметки
        let noteText = noteTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasNote = !(noteText?.isEmpty ?? true)
        
        // Создаём expense с суммой и категорией
        let beat = Beat(
            mood: selectedMood,
            note: hasNote ? noteText : nil,
            amount: amount,
            category: selectedCategory,
            currency: "USD"
        )
        currentRecord.addBeat(beat)
        PulseStorage.shared.saveDailyRecord(currentRecord)
        
        animateBeatAdded()
        animateRipple()
        updateStats()
        
        amountTextField.text = ""
        noteTextField.text = ""
        amountTextField.resignFirstResponder()
        noteTextField.resignFirstResponder()
    }
    
    @objc private func settingsTapped() {
        print("🔧 Settings button tapped!")
        PulseHaptics.selection()
        showCategoryManagement()
    }
    
    private func showCategoryManagement() {
        print("📋 Showing category management")
        let alert = UIAlertController(title: "Manage Categories", message: nil, preferredStyle: .actionSheet)
        
        // Default categories section
        alert.addAction(UIAlertAction(title: "📋 Default Categories", style: .default) { _ in
            self.showDefaultCategories()
        })
        
        // Custom categories section
        let customCategories = PulseStorage.shared.loadCustomCategories()
        if !customCategories.isEmpty {
            alert.addAction(UIAlertAction(title: "✏️ Edit Custom Categories (\(customCategories.count))", style: .default) { _ in
                self.showCustomCategoriesList()
            })
        }
        
        // Add new category
        alert.addAction(UIAlertAction(title: "➕ Add New Category", style: .default) { _ in
            self.showAddCategoryDialog()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    private func showDefaultCategories() {
        var message = "Built-in categories:\n\n"
        for category in ExpenseCategory.allCases {
            message += "\(category.emoji) \(category.displayName)\n"
        }
        
        let alert = UIAlertController(
            title: "Default Categories",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    private func showCustomCategoriesList() {
        let customCategories = PulseStorage.shared.loadCustomCategories()
        
        let alert = UIAlertController(
            title: "Custom Categories",
            message: "Tap to delete a category",
            preferredStyle: .actionSheet
        )
        
        for category in customCategories {
            alert.addAction(UIAlertAction(title: "\(category.emoji) \(category.name)", style: .destructive) { _ in
                self.confirmDeleteCategory(category)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    private func confirmDeleteCategory(_ category: CustomCategory) {
        let alert = UIAlertController(
            title: "Delete Category",
            message: "Are you sure you want to delete \"\(category.emoji) \(category.name)\"?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            PulseStorage.shared.deleteCustomCategory(id: category.id)
            PulseHaptics.success()
            
            // Обновляем селектор категорий
            self.categorySelector.reloadCategories()
            
            // Show success message
            let successAlert = UIAlertController(
                title: "Deleted",
                message: "Category has been removed",
                preferredStyle: .alert
            )
            successAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(successAlert, animated: true)
        })
        
        self.present(alert, animated: true)
    }
    
    private func showAddCategoryDialog() {
        let alert = UIAlertController(
            title: "Add New Category",
            message: "Enter category name and emoji",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Category name (e.g., Souvenirs)"
            textField.autocapitalizationType = .words
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Emoji (e.g., 🎁)"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            guard let name = alert.textFields?[0].text?.trimmingCharacters(in: .whitespaces),
                  let emoji = alert.textFields?[1].text?.trimmingCharacters(in: .whitespaces),
                  !name.isEmpty,
                  !emoji.isEmpty else {
                let errorAlert = UIAlertController(
                    title: "Error",
                    message: "Please enter both name and emoji",
                    preferredStyle: .alert
                )
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(errorAlert, animated: true)
                return
            }
            
            // Save custom category
            let customCategory = CustomCategory(name: name, emoji: emoji)
            PulseStorage.shared.addCustomCategory(customCategory)
            PulseHaptics.success()
            
            // Обновляем селектор категорий
            self.categorySelector.reloadCategories()
            
            // Show success message
            let successAlert = UIAlertController(
                title: "Success",
                message: "\(emoji) \(name) has been added!",
                preferredStyle: .alert
            )
            successAlert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(successAlert, animated: true)
        })
        
        self.present(alert, animated: true)
    }
    
    private func updateStats() {
        let expensesCount = currentRecord.beats.count
        let totalAmount = currentRecord.totalAmount
        todayBeatsLabel.text = String(format: "$%.2f spent today", totalAmount)
        
        let streak = PulseStorage.shared.calculateStreak()
        streakLabel.text = "🔥 \(streak) day tracking streak"
        
        evolutionLabel.text = "📊 \(expensesCount) expenses logged"
    }
    
    private func animateRipple() {
        guard !PulseMotion.isReduceMotionEnabled else { return }
        
        for i in 0..<3 {
            let ripple = UIView()
            ripple.backgroundColor = .clear
            ripple.layer.borderColor = selectedMood == .cheap ? UIColor.pulseCalm.cgColor :
                                        selectedMood == .expensive ? UIColor.pulseIntense.cgColor :
                                        UIColor.pulsePrimary.cgColor
            ripple.layer.borderWidth = 2
            ripple.layer.cornerRadius = 100
            ripple.frame = pulseCircle.frame
            ripple.alpha = 0.8
            
            view.insertSubview(ripple, belowSubview: pulseCircle)
            
            UIView.animate(withDuration: 1.5, delay: Double(i) * 0.2, options: .curveEaseOut) {
                ripple.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                ripple.alpha = 0
            } completion: { _ in
                ripple.removeFromSuperview()
            }
        }
    }
    
    private func animateBeatAdded() {
        guard !PulseMotion.isReduceMotionEnabled else { return }
        
        PulseMotion.springAnimate(duration: 0.3) {
            self.pulseCircle.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { _ in
            PulseMotion.springAnimate(duration: 0.3) {
                self.pulseCircle.transform = .identity
            }
        }
    }
    
    private func startPulseAnimation() {
        guard !PulseMotion.isReduceMotionEnabled else { return }
        
        let animation = PulseMotion.createPulseAnimation()
        pulseCircle.layer.add(animation, forKey: "pulse")
    }
    
    private func updatePulseColor() {
        UIView.animate(withDuration: 0.3) {
            switch self.selectedMood {
            case .cheap:
                self.pulseCircle.backgroundColor = .pulseCalm
            case .normal:
                self.pulseCircle.backgroundColor = .pulsePrimary
            case .expensive:
                self.pulseCircle.backgroundColor = .pulseIntense
            }
        }
    }
}

// MARK: - MoodSelectorDelegate

extension PulseCoreScreen: MoodSelectorDelegate {
    func didSelectMood(_ mood: Mood) {
        selectedMood = mood
        updatePulseColor()
        PulseHaptics.moodChange()
    }
}

// MARK: - CategorySelectorDelegate

extension PulseCoreScreen: CategorySelectorDelegate {
    func didSelectCategory(_ category: ExpenseCategory) {
        selectedCategory = category
        PulseHaptics.selection()
    }
}

// MARK: - UITextFieldDelegate

extension PulseCoreScreen: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - WaveformBackgroundView

class WaveformBackgroundView: UIView {
    
    private var waveShapes: [CAShapeLayer] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWaves()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupWaves() {
        for _ in 0..<3 {
            let waveLayer = CAShapeLayer()
            waveLayer.strokeColor = UIColor.pulsePrimary.withAlphaComponent(0.08).cgColor
            waveLayer.fillColor = UIColor.clear.cgColor
            waveLayer.lineWidth = 2
            
            layer.addSublayer(waveLayer)
            waveShapes.append(waveLayer)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateWaves()
    }
    
    private func updateWaves() {
        let width = bounds.width
        let height = bounds.height
        
        for (index, waveLayer) in waveShapes.enumerated() {
            let path = UIBezierPath()
            let yOffset = height / 2 + CGFloat(index - 1) * 100
            
            path.move(to: CGPoint(x: 0, y: yOffset))
            
            for x in stride(from: 0, through: width, by: 10) {
                let y = yOffset + sin(x / 50 + CGFloat(index) * .pi / 3) * 20
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            waveLayer.path = path.cgPath
        }
    }
}

// MARK: - MoodSelectorView

protocol MoodSelectorDelegate: AnyObject {
    func didSelectMood(_ mood: Mood)
}

class MoodSelectorView: UIView {
    
    weak var delegate: MoodSelectorDelegate?
    
    private let stackView = UIStackView()
    private var moodButtons: [UIButton] = []
    private var selectedMood: Mood = .normal
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
        setupButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStackView() {
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupButtons() {
        for mood in Mood.allCases {
            let button = UIButton(type: .system)
            
            button.setTitle("\(mood.emoji) \(mood.displayName)", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.7
            button.layer.cornerRadius = 18
            button.layer.borderWidth = 2
            button.tag = Mood.allCases.firstIndex(of: mood) ?? 0
            
            var config = UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            button.configuration = config
            button.addTarget(self, action: #selector(moodButtonTapped), for: .touchUpInside)
            
            stackView.addArrangedSubview(button)
            moodButtons.append(button)
        }
        
        updateButtonStates()
    }
    
    @objc private func moodButtonTapped(_ sender: UIButton) {
        selectedMood = Mood.allCases[sender.tag]
        updateButtonStates()
        delegate?.didSelectMood(selectedMood)
    }
    
    private func updateButtonStates() {
        for (index, button) in moodButtons.enumerated() {
            let mood = Mood.allCases[index]
            let isSelected = mood == selectedMood
            
            UIView.animate(withDuration: 0.2) {
                if isSelected {
                    // Выбранная кнопка: желтый фон, черный текст, черная рамка
                    button.backgroundColor = .pulsePrimary
                    button.setTitleColor(.black, for: .normal)
                    button.layer.borderColor = UIColor.black.cgColor
                } else {
                    // Невыбранная кнопка: черный фон, желтый текст, золотая рамка
                    button.backgroundColor = .black
                    button.setTitleColor(.pulsePrimary, for: .normal)
                    button.layer.borderColor = UIColor.pulsePrimary.cgColor
                }
                button.transform = isSelected ? CGAffineTransform(scaleX: 1.05, y: 1.05) : .identity
            }
        }
    }
}

// MARK: - CategorySelectorView

protocol CategorySelectorDelegate: AnyObject {
    func didSelectCategory(_ category: ExpenseCategory)
}

class CategorySelectorView: UIView {
    
    weak var delegate: CategorySelectorDelegate?
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var categoryButtons: [UIButton] = []
    private var selectedCategory: ExpenseCategory = .food
    private var customCategories: [CustomCategory] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
        reloadCategories()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadCategories() {
        // Удаляем все существующие кнопки
        categoryButtons.forEach { $0.removeFromSuperview() }
        categoryButtons.removeAll()
        
        // Загружаем кастомные категории
        customCategories = PulseStorage.shared.loadCustomCategories()
        
        // Создаём кнопки заново
        setupButtons()
    }
    
    private func setupScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    private func setupButtons() {
        // Добавляем стандартные категории
        for category in ExpenseCategory.allCases {
            let button = UIButton(type: .system)
            
            button.setTitle("\(category.emoji) \(category.displayName)", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
            button.layer.cornerRadius = 18
            button.layer.borderWidth = 2
            button.tag = ExpenseCategory.allCases.firstIndex(of: category) ?? 0
            
            var config = UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
            button.configuration = config
            button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
            
            stackView.addArrangedSubview(button)
            categoryButtons.append(button)
        }
        
        // Добавляем кастомные категории
        for customCategory in customCategories {
            let button = UIButton(type: .system)
            
            button.setTitle("\(customCategory.emoji) \(customCategory.name)", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
            button.layer.cornerRadius = 18
            button.layer.borderWidth = 2
            button.tag = -1 // Отрицательный tag для кастомных категорий
            
            var config = UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
            button.configuration = config
            button.addTarget(self, action: #selector(customCategoryButtonTapped), for: .touchUpInside)
            
            // Сохраняем ID кастомной категории в accessibilityIdentifier
            button.accessibilityIdentifier = customCategory.id.uuidString
            
            stackView.addArrangedSubview(button)
            categoryButtons.append(button)
        }
        
        updateButtonStates()
    }
    
    @objc private func customCategoryButtonTapped(_ sender: UIButton) {
        // Для кастомных категорий просто обновляем визуальное состояние
        // Снимаем выделение со стандартных категорий
        updateCustomButtonStates(selectedButton: sender)
        // TODO: В будущем можно добавить поддержку кастомных категорий в Beat
    }
    
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        selectedCategory = ExpenseCategory.allCases[sender.tag]
        updateButtonStates()
        delegate?.didSelectCategory(selectedCategory)
    }
    
    private func updateButtonStates() {
        let standardCategoriesCount = ExpenseCategory.allCases.count
        
        for (index, button) in categoryButtons.enumerated() {
            let isSelected: Bool
            
            if index < standardCategoriesCount {
                let category = ExpenseCategory.allCases[index]
                isSelected = category == selectedCategory
            } else {
                isSelected = false
            }
            
            UIView.animate(withDuration: 0.2) {
                if isSelected {
                    // Выбранная кнопка: желтый фон, черный текст, черная рамка
                    button.backgroundColor = .pulsePrimary
                    button.setTitleColor(.black, for: .normal)
                    button.layer.borderColor = UIColor.black.cgColor
                } else {
                    // Невыбранная кнопка: черный фон, желтый текст, золотая рамка
                    button.backgroundColor = .black
                    button.setTitleColor(.pulsePrimary, for: .normal)
                    button.layer.borderColor = UIColor.pulsePrimary.cgColor
                }
                button.transform = isSelected ? CGAffineTransform(scaleX: 1.05, y: 1.05) : .identity
            }
        }
    }
    
    private func updateCustomButtonStates(selectedButton: UIButton) {
        for button in categoryButtons {
            let isSelected = button == selectedButton
            
            UIView.animate(withDuration: 0.2) {
                if isSelected {
                    // Выбранная кнопка: желтый фон, черный текст, черная рамка
                    button.backgroundColor = .pulsePrimary
                    button.setTitleColor(.black, for: .normal)
                    button.layer.borderColor = UIColor.black.cgColor
                } else {
                    // Невыбранная кнопка: черный фон, желтый текст, золотая рамка
                    button.backgroundColor = .black
                    button.setTitleColor(.pulsePrimary, for: .normal)
                    button.layer.borderColor = UIColor.pulsePrimary.cgColor
                }
                button.transform = isSelected ? CGAffineTransform(scaleX: 1.05, y: 1.05) : .identity
            }
        }
    }
}
