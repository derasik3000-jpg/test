//
//  AddPlotViewController.swift
//  Control Rain Watering schedule
//
//  Created by Евгений on 04.02.2026.
//

import UIKit

final class AddPlotViewController: UIViewController {
    
    var onPlotAdded: (() -> Void)?
    
    private let storageManager = BarnStorageManager.shared
    private var selectedIrrigationType: IrrigationType = .drip
    
    // MARK: - UI Elements
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.delaysContentTouches = false
        scroll.canCancelContentTouches = false // Don't cancel touches in collection view
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
    
    private let plotNameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Field Name (e.g., North Meadow)"
        field.font = FarmTypography.harvest
        field.textColor = FarmPalette.richSoil
        field.backgroundColor = FarmPalette.morningMist
        field.attributedPlaceholder = NSAttributedString(
            string: "Field Name (e.g., North Meadow)",
            attributes: [.foregroundColor: FarmPalette.dustyField]
        )
        field.layer.cornerRadius = FarmRadius.crop
        field.layer.borderWidth = 1
        field.layer.borderColor = FarmPalette.goldenHarvest.withAlphaComponent(0.3).cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: FarmSpacing.plotMargin, height: 0))
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let cropTypeTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Crop Type (e.g., Wheat, Corn)"
        field.font = FarmTypography.harvest
        field.textColor = FarmPalette.richSoil
        field.backgroundColor = FarmPalette.morningMist
        field.attributedPlaceholder = NSAttributedString(
            string: "Crop Type (e.g., Wheat, Corn)",
            attributes: [.foregroundColor: FarmPalette.dustyField]
        )
        field.layer.cornerRadius = FarmRadius.crop
        field.layer.borderWidth = 1
        field.layer.borderColor = FarmPalette.goldenHarvest.withAlphaComponent(0.3).cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: FarmSpacing.plotMargin, height: 0))
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let fieldImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "square.grid.3x3.fill")
        imageView.tintColor = FarmPalette.goldenHarvest
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let fieldImageContainer: UIView = {
        let view = UIView()
        view.backgroundColor = FarmPalette.darkCard
        view.layer.cornerRadius = FarmRadius.barn
        view.layer.borderWidth = 2
        view.layer.borderColor = FarmPalette.goldenHarvest.withAlphaComponent(0.5).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let irrigationTypeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = FarmSpacing.plotMargin
        layout.minimumLineSpacing = FarmSpacing.plotMargin
        layout.sectionInset = UIEdgeInsets(
            top: FarmSpacing.rowSpacing,
            left: FarmSpacing.plotMargin,
            bottom: FarmSpacing.rowSpacing,
            right: FarmSpacing.plotMargin
        )
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = FarmPalette.darkCard
        collection.layer.cornerRadius = FarmRadius.crop
        collection.layer.borderWidth = 1
        collection.layer.borderColor = FarmPalette.goldenHarvest.withAlphaComponent(0.3).cgColor
        collection.showsHorizontalScrollIndicator = false
        collection.isScrollEnabled = true
        collection.alwaysBounceHorizontal = true
        collection.allowsSelection = true
        collection.allowsMultipleSelection = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private var selectedIrrigationTypeIndex: Int = 0
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🌱 Create Field", for: .normal)
        button.titleLabel?.font = FarmTypography.harvest
        button.backgroundColor = FarmPalette.goldenHarvest
        button.setTitleColor(FarmPalette.richSoil, for: .normal)
        button.layer.cornerRadius = FarmRadius.barn
        button.layer.shadowColor = FarmPalette.goldenHarvest.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Field"
        setupUI()
        setupKeyboardHandling()
        setupCollectionView()
        
        // Ensure first item is selected by default
        selectedIrrigationTypeIndex = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload collection view to ensure proper selection state
        DispatchQueue.main.async { [weak self] in
            self?.irrigationTypeCollectionView.reloadData()
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Add New Field"
        view.backgroundColor = FarmPalette.richSoil
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        fieldImageContainer.addSubview(fieldImageView)
        
        contentStack.addArrangedSubview(fieldImageContainer)
        contentStack.addArrangedSubview(createLabel("Field Name"))
        contentStack.addArrangedSubview(plotNameTextField)
        contentStack.addArrangedSubview(createLabel("Crop Type"))
        contentStack.addArrangedSubview(cropTypeTextField)
        contentStack.addArrangedSubview(createLabel("Irrigation Type"))
        contentStack.addArrangedSubview(irrigationTypeCollectionView)
        contentStack.addArrangedSubview(saveButton)
        
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
            
            fieldImageContainer.heightAnchor.constraint(equalToConstant: 120),
            fieldImageView.topAnchor.constraint(equalTo: fieldImageContainer.topAnchor, constant: FarmSpacing.plotMargin),
            fieldImageView.leadingAnchor.constraint(equalTo: fieldImageContainer.leadingAnchor, constant: FarmSpacing.plotMargin),
            fieldImageView.trailingAnchor.constraint(equalTo: fieldImageContainer.trailingAnchor, constant: -FarmSpacing.plotMargin),
            fieldImageView.bottomAnchor.constraint(equalTo: fieldImageContainer.bottomAnchor, constant: -FarmSpacing.plotMargin),
            
            plotNameTextField.heightAnchor.constraint(equalToConstant: 50),
            cropTypeTextField.heightAnchor.constraint(equalToConstant: 50),
            
            irrigationTypeCollectionView.heightAnchor.constraint(equalToConstant: 110),
            
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
    
    private func setupCollectionView() {
        irrigationTypeCollectionView.delegate = self
        irrigationTypeCollectionView.dataSource = self
        irrigationTypeCollectionView.register(IrrigationTypeCell.self, forCellWithReuseIdentifier: "IrrigationTypeCell")
        
        // Ensure collection view can receive touches
        irrigationTypeCollectionView.isUserInteractionEnabled = true
        irrigationTypeCollectionView.delaysContentTouches = false
        irrigationTypeCollectionView.canCancelContentTouches = true
        irrigationTypeCollectionView.allowsSelection = true
        irrigationTypeCollectionView.allowsMultipleSelection = false
        
        // Add tap gesture as fallback
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(collectionViewTapped(_:)))
        tapGesture.cancelsTouchesInView = false
        irrigationTypeCollectionView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func collectionViewTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: irrigationTypeCollectionView)
        if let indexPath = irrigationTypeCollectionView.indexPathForItem(at: location) {
            print("🔍 Tap gesture detected at index: \(indexPath.item)")
            
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            let oldIndex = selectedIrrigationTypeIndex
            selectedIrrigationTypeIndex = indexPath.item
            
            print("🔍 Selection changed via gesture: \(oldIndex) -> \(selectedIrrigationTypeIndex)")
            
            // Update collection view
            UIView.performWithoutAnimation {
                irrigationTypeCollectionView.reloadData()
            }
            
            // Scroll to selected item
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.irrigationTypeCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Actions
    
    @objc private func saveTapped() {
        guard let plotName = plotNameTextField.text, !plotName.isEmpty else {
            showAlert(title: "Error", message: "Please enter a field name")
            return
        }
        
        guard let cropType = cropTypeTextField.text, !cropType.isEmpty else {
            showAlert(title: "Error", message: "Please enter a crop type")
            return
        }
        
        let irrigationType = IrrigationType.allCases[selectedIrrigationTypeIndex]
        
        let plot = IrrigationPlot(
            plotName: plotName,
            cropType: cropType,
            irrigationType: irrigationType
        )
        
        storageManager.addPlot(plot)
        
        // Add experience points
        var profile = storageManager.loadFarmerProfile()
        profile.addExperience(20)
        profile.totalPlotsManaged += 1
        storageManager.saveFarmerProfile(profile)
        
        onPlotAdded?()
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

// MARK: - UICollectionViewDataSource

extension AddPlotViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return IrrigationType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IrrigationTypeCell", for: indexPath) as? IrrigationTypeCell else {
            return UICollectionViewCell()
        }
        
        let irrigationType = IrrigationType.allCases[indexPath.item]
        let isSelected = indexPath.item == selectedIrrigationTypeIndex
        
        // Debug
        print("🔍 Cell \(indexPath.item): isSelected=\(isSelected), selectedIndex=\(selectedIrrigationTypeIndex)")
        
        cell.configure(with: irrigationType, isSelected: isSelected)
        
        // Force layout update
        DispatchQueue.main.async {
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension AddPlotViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        print("🔍 shouldSelectItemAt called for index: \(indexPath.item)")
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("🔍 didSelectItemAt called for index: \(indexPath.item)")
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let oldIndex = selectedIrrigationTypeIndex
        selectedIrrigationTypeIndex = indexPath.item
        
        print("🔍 Selection changed: \(oldIndex) -> \(selectedIrrigationTypeIndex)")
        
        // Update all cells to ensure proper state
        UIView.performWithoutAnimation {
            collectionView.reloadData()
        }
        
        // Scroll to selected item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        print("🔍 didHighlightItemAt called for index: \(indexPath.item)")
        if let cell = collectionView.cellForItem(at: indexPath) as? IrrigationTypeCell {
            cell.isHighlighted = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        print("🔍 didUnhighlightItemAt called for index: \(indexPath.item)")
        if let cell = collectionView.cellForItem(at: indexPath) as? IrrigationTypeCell {
            cell.isHighlighted = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        print("🔍 shouldHighlightItemAt called for index: \(indexPath.item)")
        return true
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AddPlotViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Fixed larger size for better touch area
        return CGSize(width: 150, height: 90)
    }
}

// MARK: - IrrigationTypeCell

final class IrrigationTypeCell: UICollectionViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = FarmRadius.crop
        view.layer.borderWidth = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = FarmTypography.harvest
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
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
        // Make entire cell tappable
        isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
        
        contentView.addSubview(containerView)
        containerView.addSubview(emojiLabel)
        containerView.addSubview(textLabel)
        
        containerView.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            emojiLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: FarmSpacing.rowSpacing),
            emojiLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            emojiLabel.heightAnchor.constraint(equalToConstant: 35),
            
            textLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: FarmSpacing.furrow),
            textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: FarmSpacing.seedGap),
            textLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -FarmSpacing.seedGap),
            textLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -FarmSpacing.rowSpacing)
        ])
    }
    
    private var gradientLayer: CAGradientLayer?
    
    func configure(with irrigationType: IrrigationType, isSelected: Bool) {
        emojiLabel.text = irrigationType.emoji
        textLabel.text = irrigationType.rawValue
        
        print("🎨 Configuring cell: \(irrigationType.rawValue), isSelected: \(isSelected)")
        
        // Remove any existing gradient or background layers
        containerView.layer.sublayers?.forEach { layer in
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        gradientLayer = nil
        
        if isSelected {
            // Selected: Golden gradient background
            containerView.backgroundColor = .clear
            
            let newGradientLayer = CAGradientLayer()
            newGradientLayer.colors = [
                FarmPalette.goldenHarvest.cgColor,
                FarmPalette.goldenHarvest.withAlphaComponent(0.8).cgColor
            ]
            newGradientLayer.startPoint = CGPoint(x: 0, y: 0)
            newGradientLayer.endPoint = CGPoint(x: 1, y: 1)
            newGradientLayer.frame = containerView.bounds
            newGradientLayer.cornerRadius = containerView.layer.cornerRadius
            containerView.layer.insertSublayer(newGradientLayer, at: 0)
            gradientLayer = newGradientLayer
            
            containerView.layer.borderColor = UIColor.white.cgColor
            containerView.layer.borderWidth = 3
            textLabel.textColor = FarmPalette.richSoil
            emojiLabel.textColor = FarmPalette.richSoil
        } else {
            // Not selected: White background
            containerView.backgroundColor = FarmPalette.morningMist
            containerView.layer.borderColor = FarmPalette.goldenHarvest.withAlphaComponent(0.5).cgColor
            containerView.layer.borderWidth = 2
            textLabel.textColor = FarmPalette.richSoil
            emojiLabel.textColor = FarmPalette.richSoil
        }
        
        // Ensure cell is tappable
        isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = true
        
        // Force layout update
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update gradient frame if it exists
        if let gradientLayer = gradientLayer {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            gradientLayer.frame = containerView.bounds
            gradientLayer.cornerRadius = containerView.layer.cornerRadius
            CATransaction.commit()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Clear gradient
        containerView.layer.sublayers?.forEach { layer in
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        gradientLayer = nil
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.containerView.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
                self.containerView.alpha = self.isHighlighted ? 0.8 : 1.0
            }
        }
    }
}
