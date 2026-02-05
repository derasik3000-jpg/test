//
//  AddWateringSessionViewController.swift
//  Control Rain Watering schedule
//
//  Created by Евгений on 04.02.2026.
//

import UIKit

final class AddWateringSessionViewController: UIViewController {
    
    var onSessionAdded: (() -> Void)?
    
    private let storageManager = BarnStorageManager.shared
    private var plots: [IrrigationPlot] = []
    private var selectedPlot: IrrigationPlot?
    
    // MARK: - UI Elements
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = FarmSpacing.plotMargin
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let plotButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Field", for: .normal)
        button.titleLabel?.font = FarmTypography.harvest
        button.backgroundColor = FarmPalette.morningMist
        button.setTitleColor(FarmPalette.richSoil, for: .normal)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: FarmSpacing.plotMargin, bottom: 0, right: FarmSpacing.plotMargin)
        button.layer.cornerRadius = FarmRadius.crop
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let durationTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Duration"
        field.font = FarmTypography.harvest
        field.textColor = FarmPalette.richSoil
        field.backgroundColor = FarmPalette.morningMist
        field.layer.cornerRadius = FarmRadius.crop
        field.keyboardType = .numberPad
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: FarmSpacing.plotMargin, height: 0))
        field.leftViewMode = .always
        
        // Add unit label on the right
        let unitLabel = UILabel()
        unitLabel.text = "min"
        unitLabel.font = FarmTypography.crop
        unitLabel.textColor = FarmPalette.dustyField
        unitLabel.sizeToFit()
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: unitLabel.frame.width + FarmSpacing.plotMargin * 2, height: 50))
        unitLabel.frame = CGRect(x: FarmSpacing.plotMargin, y: 0, width: unitLabel.frame.width, height: 50)
        rightView.addSubview(unitLabel)
        field.rightView = rightView
        field.rightViewMode = .always
        
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let waterAmountTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Water Amount"
        field.font = FarmTypography.harvest
        field.textColor = FarmPalette.richSoil
        field.backgroundColor = FarmPalette.morningMist
        field.layer.cornerRadius = FarmRadius.crop
        field.keyboardType = .decimalPad
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: FarmSpacing.plotMargin, height: 0))
        field.leftViewMode = .always
        
        // Add unit label on the right
        let unitLabel = UILabel()
        unitLabel.text = "L"
        unitLabel.font = FarmTypography.crop
        unitLabel.textColor = FarmPalette.dustyField
        unitLabel.sizeToFit()
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: unitLabel.frame.width + FarmSpacing.plotMargin * 2, height: 50))
        unitLabel.frame = CGRect(x: FarmSpacing.plotMargin, y: 0, width: unitLabel.frame.width, height: 50)
        rightView.addSubview(unitLabel)
        field.rightView = rightView
        field.rightViewMode = .always
        
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let notesTextView: UITextView = {
        let textView = UITextView()
        textView.font = FarmTypography.crop
        textView.textColor = FarmPalette.richSoil
        textView.backgroundColor = FarmPalette.morningMist
        textView.layer.cornerRadius = FarmRadius.crop
        textView.textContainerInset = UIEdgeInsets(top: FarmSpacing.rowSpacing, left: FarmSpacing.rowSpacing, bottom: FarmSpacing.rowSpacing, right: FarmSpacing.rowSpacing)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let rainfallSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = FarmPalette.freshWater
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    private let rainfallLabel: UILabel = {
        let label = UILabel()
        label.text = "Was this rainfall?"
        label.font = FarmTypography.harvest
        label.textColor = FarmPalette.morningMist
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("💧 Save Session", for: .normal)
        button.titleLabel?.font = FarmTypography.harvest
        button.backgroundColor = FarmPalette.goldenHarvest
        button.setTitleColor(FarmPalette.richSoil, for: .normal)
        button.layer.cornerRadius = FarmRadius.barn
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log Watering"
        setupUI()
        loadPlots()
        setupKeyboardHandling()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Log Watering"
        view.backgroundColor = FarmPalette.richSoil
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        let rainfallStack = UIStackView(arrangedSubviews: [rainfallLabel, rainfallSwitch])
        rainfallStack.axis = .horizontal
        rainfallStack.spacing = FarmSpacing.rowSpacing
        
        contentStack.addArrangedSubview(createLabel("Select Field"))
        contentStack.addArrangedSubview(plotButton)
        contentStack.addArrangedSubview(createLabel("Duration (minutes)"))
        contentStack.addArrangedSubview(durationTextField)
        contentStack.addArrangedSubview(createLabel("Water Amount (liters)"))
        contentStack.addArrangedSubview(waterAmountTextField)
        contentStack.addArrangedSubview(createLabel("Notes (optional)"))
        contentStack.addArrangedSubview(notesTextView)
        contentStack.addArrangedSubview(rainfallStack)
        contentStack.addArrangedSubview(saveButton)
        
        plotButton.addTarget(self, action: #selector(selectPlotTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: FarmSpacing.fieldPadding),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: FarmSpacing.fieldPadding),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -FarmSpacing.fieldPadding),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -FarmSpacing.fieldPadding),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -FarmSpacing.fieldPadding * 2),
            
            plotButton.heightAnchor.constraint(equalToConstant: 50),
            durationTextField.heightAnchor.constraint(equalToConstant: 50),
            waterAmountTextField.heightAnchor.constraint(equalToConstant: 50),
            notesTextView.heightAnchor.constraint(equalToConstant: 100),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func createLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = FarmTypography.crop
        label.textColor = FarmPalette.goldenHarvest
        return label
    }
    
    private func loadPlots() {
        plots = storageManager.loadPlots()
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Actions
    
    @objc private func selectPlotTapped() {
        let alert = UIAlertController(title: "Select Field", message: nil, preferredStyle: .actionSheet)
        
        for plot in plots {
            alert.addAction(UIAlertAction(title: "\(plot.irrigationType.emoji) \(plot.plotName)", style: .default) { [weak self] _ in
                self?.selectedPlot = plot
                self?.plotButton.setTitle("\(plot.irrigationType.emoji) \(plot.plotName)", for: .normal)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func saveTapped() {
        guard let plot = selectedPlot else {
            showAlert(title: "Error", message: "Please select a field")
            return
        }
        
        guard let durationText = durationTextField.text, let duration = Int(durationText), duration > 0 else {
            showAlert(title: "Error", message: "Please enter a valid duration")
            return
        }
        
        guard let waterText = waterAmountTextField.text, let waterAmount = Double(waterText), waterAmount > 0 else {
            showAlert(title: "Error", message: "Please enter a valid water amount")
            return
        }
        
        let session = WateringSession(
            plotId: plot.id,
            durationMinutes: duration,
            waterAmount: waterAmount,
            notes: notesTextView.text.isEmpty ? nil : notesTextView.text,
            wasRainfall: rainfallSwitch.isOn
        )
        
        storageManager.addSession(session)
        
        // Add experience points
        var profile = storageManager.loadFarmerProfile()
        profile.addExperience(10)
        storageManager.saveFarmerProfile(profile)
        
        onSessionAdded?()
        dismiss(animated: true)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView.contentInset.bottom = keyboardFrame.height
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
