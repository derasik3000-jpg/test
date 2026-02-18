// ──────────────────────────────────────────────
// RecipeForgeViewController.swift
// с8 – "Menu of 12 Dishes"
//
// Modal editor for creating/editing a dish.
// Supports: title, meal tags, ingredients list,
// cooking steps, notes. Keyboard-aware scrolling.
// ──────────────────────────────────────────────

import UIKit

final class RecipeForgeViewController: UIViewController {

    // ── Coordinator ──────────────────────────

    weak var coordinatorDelegate: KitchenNavigable?

    // ── Mode ──────────────────────────────────

    enum ForgeMode {
        case create(slotIndex: Int)
        case edit(Entree)
        case view(Entree)
    }

    private let mode: ForgeMode

    // ── State ──────────────────────────────────

    private var draftTitle: String = ""
    private var draftTags: Set<CourseKind> = []
    private var draftIngredients: [Pinch] = []
    private var draftSteps: [SimmerStep] = []
    private var draftMemo: String = ""
    private var draftFavorite: Bool = false
    private var draftSatiety: SatietyGrade = .regular

    // ── UI ─────────────────────────────────────

    private let scrollBowl = UIScrollView()
    private let contentStack = UIStackView()

    private let titleField = SaffronPalette.brewTextField(placeholder: "Dish name")
    private let tagsSection = TagsSelectionView()
    private let ingredientsSection = IngredientsEditorView()
    private let stepsSection = StepsEditorView()
    private let memoField: UITextView = {
        let tv = UITextView()
        tv.font = TypographyRecipe.servingBody()
        tv.textColor = SaffronPalette.flour
        tv.backgroundColor = SaffronPalette.meringue
        tv.layer.cornerRadius = PlatingCorner.biscuit
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        tv.keyboardAppearance = .dark
        tv.tintColor = SaffronPalette.honeyComb
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.heightAnchor.constraint(equalToConstant: 100).isActive = true
        return tv
    }()

    private let favoriteToggle: UISwitch = {
        let sw = UISwitch()
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }()

    private let satietySegmented: UISegmentedControl = {
        let items = SatietyGrade.allCases.map { $0.displayLabel }
        let seg = UISegmentedControl(items: items)
        seg.selectedSegmentIndex = 1 // regular
        seg.translatesAutoresizingMaskIntoConstraints = false
        return seg
    }()

    // ── Keyboard ───────────────────────────────

    private var keyboardHeight: CGFloat = 0

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Init
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    init(mode: ForgeMode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Lifecycle
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SaffronPalette.crust

        switch mode {
        case .create:
            title = "New Dish"
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .cancel, target: self, action: #selector(cancelTap)
            )
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Save", style: .done, target: self, action: #selector(saveTap)
            )
        case .edit(let entree):
            title = "Edit Dish"
            loadEntree(entree)
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .cancel, target: self, action: #selector(cancelTap)
            )
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Save", style: .done, target: self, action: #selector(saveTap)
            )
        case .view(let entree):
            title = entree.title
            loadEntree(entree)
            // No left button - use standard Back button from navigation controller
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Edit", style: .plain, target: self, action: #selector(editTap)
            )
            // Disable editing
            titleField.isEnabled = false
            tagsSection.isUserInteractionEnabled = false
            ingredientsSection.isUserInteractionEnabled = false
            stepsSection.isUserInteractionEnabled = false
            memoField.isEditable = false
            favoriteToggle.isEnabled = false
            satietySegmented.isEnabled = false
        }

        setupLayout()
        observeKeyboard()
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Layout
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func setupLayout() {
        scrollBowl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollBowl)

        contentStack.axis = .vertical
        contentStack.spacing = KitchenSpacing.tray
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollBowl.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollBowl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollBowl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollBowl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollBowl.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollBowl.topAnchor, constant: KitchenSpacing.platter),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: KitchenSpacing.plate),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -KitchenSpacing.plate),
            contentStack.bottomAnchor.constraint(equalTo: scrollBowl.bottomAnchor, constant: -KitchenSpacing.banquet),
            contentStack.widthAnchor.constraint(equalTo: scrollBowl.widthAnchor, constant: -KitchenSpacing.plate * 2),
        ])

        // Build sections
        contentStack.addArrangedSubview(buildSection(title: "Name", view: titleField))
        contentStack.addArrangedSubview(buildSection(title: "Meal Types", view: tagsSection))
        contentStack.addArrangedSubview(buildSection(title: "Ingredients", view: ingredientsSection))
        contentStack.addArrangedSubview(buildSection(title: "Cooking Steps", view: stepsSection))
        contentStack.addArrangedSubview(buildSection(title: "Notes", view: memoField))

        // Favorite & Satiety row
        let favRow = UIStackView()
        favRow.axis = .horizontal
        favRow.spacing = KitchenSpacing.plate
        favRow.alignment = .center

        let favLabel = UILabel()
        favLabel.text = "Favorite"
        favLabel.font = TypographyRecipe.servingBody()
        favLabel.textColor = SaffronPalette.flour

        favRow.addArrangedSubview(favLabel)
        favRow.addArrangedSubview(favoriteToggle)

        let satLabel = UILabel()
        satLabel.text = "Satiety:"
        satLabel.font = TypographyRecipe.servingBody()
        satLabel.textColor = SaffronPalette.flour

        let satRow = UIStackView()
        satRow.axis = .horizontal
        satRow.spacing = KitchenSpacing.napkin
        satRow.addArrangedSubview(satLabel)
        satRow.addArrangedSubview(satietySegmented)

        let metaStack = UIStackView()
        metaStack.axis = .vertical
        metaStack.spacing = KitchenSpacing.napkin
        metaStack.addArrangedSubview(favRow)
        metaStack.addArrangedSubview(satRow)

        contentStack.addArrangedSubview(buildSection(title: "", view: metaStack))

        // Configure tags
        tagsSection.onTagsChanged = { [weak self] tags in
            self?.draftTags = tags
        }

        // Configure ingredients
        ingredientsSection.onIngredientsChanged = { [weak self] ingredients in
            self?.draftIngredients = ingredients
        }
        ingredientsSection.parentViewController = self

        // Configure steps
        stepsSection.onStepsChanged = { [weak self] steps in
            self?.draftSteps = steps
        }
        stepsSection.parentViewController = self
    }

    private func buildSection(title: String, view: UIView) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        if !title.isEmpty {
            let label = UILabel()
            label.text = title
            label.font = TypographyRecipe.sectionRoast()
            label.textColor = SaffronPalette.flour
            label.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(label)

            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: container.topAnchor),
                label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            ])
        }

        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: title.isEmpty ? container.topAnchor : container.subviews.first!.bottomAnchor, constant: title.isEmpty ? 0 : KitchenSpacing.garnish),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        return container
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Data Loading
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func loadEntree(_ entree: Entree) {
        draftTitle = entree.title
        draftTags = entree.courseTags
        draftIngredients = entree.ingredients
        draftSteps = entree.steps
        draftMemo = entree.memo ?? ""
        draftFavorite = entree.isFavorite
        draftSatiety = entree.satiety

        titleField.text = draftTitle
        tagsSection.selectedTags = draftTags
        ingredientsSection.ingredients = draftIngredients
        stepsSection.steps = draftSteps
        memoField.text = draftMemo
        favoriteToggle.isOn = draftFavorite
        satietySegmented.selectedSegmentIndex = draftSatiety.rawValue - 1
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Actions
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    @objc private func cancelTap() {
        if hasChanges() {
            let alert = UIAlertController(
                title: "Discard changes?",
                message: "Your edits will be lost.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Keep Editing", style: .cancel))
            alert.addAction(UIAlertAction(title: "Discard", style: .destructive) { _ in
                self.dismiss(animated: true)
            })
            present(alert, animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func saveTap() {
        guard validateForm() else {
            let alert = UIAlertController(
                title: "Incomplete",
                message: "Please add a name, at least one meal type, and at least one ingredient.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        saveEntree()
        
        // Post notification to update views
        NotificationCenter.default.post(name: CellarVault.ledgerDidUpdate, object: nil)
        
        // Close the editing screen
        if presentingViewController != nil {
            // Modal presentation
            dismiss(animated: true)
        } else if navigationController != nil {
            // Pushed on navigation stack
            navigationController?.popViewController(animated: true)
        }
    }

    @objc private func editTap() {
        guard case .view(let entree) = mode else { return }
        // Switch to edit mode
        let editVC = RecipeForgeViewController(mode: .edit(entree))
        editVC.coordinatorDelegate = coordinatorDelegate
        navigationController?.pushViewController(editVC, animated: true)
    }

    private func hasChanges() -> Bool {
        guard case .edit(let original) = mode else { return true }
        return draftTitle != original.title
            || draftTags != original.courseTags
            || draftIngredients != original.ingredients
            || draftSteps != original.steps
            || draftMemo != (original.memo ?? "")
            || draftFavorite != original.isFavorite
            || draftSatiety != original.satiety
    }

    private func validateForm() -> Bool {
        let titleValid = !(titleField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        let tagsValid = !draftTags.isEmpty
        let ingredientsValid = !draftIngredients.isEmpty
        return titleValid && tagsValid && ingredientsValid
    }

    private func saveEntree() {
        let title = titleField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        var tagMask = 0
        for tag in draftTags {
            tagMask |= tag.bitmask
        }

        let satiety = SatietyGrade(rawValue: satietySegmented.selectedSegmentIndex + 1) ?? .regular

        switch mode {
        case .create(let slotIndex):
            let newEntree = Entree(
                id: UUID(),
                title: title,
                memo: draftMemo.isEmpty ? nil : draftMemo,
                courseTagsMask: tagMask,
                isFavorite: favoriteToggle.isOn,
                satiety: satiety,
                ingredients: draftIngredients,
                steps: draftSteps,
                isActive: true,
                slotIndex: slotIndex,
                bakedAt: Date(),
                refreshedAt: Date()
            )
            CellarVault.shared.updateEntree(newEntree)

        case .edit(let original):
            var updated = original
            updated.title = title
            updated.memo = draftMemo.isEmpty ? nil : draftMemo
            updated.courseTagsMask = tagMask
            updated.isFavorite = favoriteToggle.isOn
            updated.satiety = satiety
            updated.ingredients = draftIngredients
            updated.steps = draftSteps
            updated.refreshedAt = Date()
            CellarVault.shared.updateEntree(updated)

        case .view:
            break
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Keyboard
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func observeKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        keyboardHeight = frame.height
        updateScrollInsets()
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        keyboardHeight = 0
        updateScrollInsets()
    }

    private func updateScrollInsets() {
        scrollBowl.contentInset.bottom = keyboardHeight
        scrollBowl.verticalScrollIndicatorInsets.bottom = keyboardHeight
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Tags Selection View
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class TagsSelectionView: UIView {

    var onTagsChanged: ((Set<CourseKind>) -> Void)?
    var selectedTags: Set<CourseKind> = [] {
        didSet {
            updateButtons()
        }
    }

    private var tagButtons: [UIButton] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTags()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupTags() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = KitchenSpacing.garnish
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.heightAnchor.constraint(equalToConstant: 44),
        ])

        for kind in CourseKind.allCases {
            let btn = UIButton(type: .system)
            btn.setTitle(kind.displayLabel, for: .normal)
            btn.titleLabel?.font = TypographyRecipe.sprinkleTag()
            btn.layer.cornerRadius = PlatingCorner.crouton
            btn.tag = kind.rawValue
            btn.addTarget(self, action: #selector(tagTapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(btn)
            tagButtons.append(btn)
        }

        updateButtons()
    }

    @objc private func tagTapped(_ sender: UIButton) {
        guard let kind = CourseKind(rawValue: sender.tag) else { return }
        if selectedTags.contains(kind) {
            selectedTags.remove(kind)
        } else {
            selectedTags.insert(kind)
        }
        updateButtons()
        onTagsChanged?(selectedTags)
    }

    private func updateButtons() {
        for btn in tagButtons {
            guard let kind = CourseKind(rawValue: btn.tag) else { continue }
            let selected = selectedTags.contains(kind)
            UIView.animate(withDuration: 0.2) {
                btn.backgroundColor = selected
                    ? kind.tintColor.withAlphaComponent(0.3)
                    : SaffronPalette.brioche
                btn.setTitleColor(
                    selected ? kind.tintColor : SaffronPalette.steamGrey,
                    for: .normal
                )
            }
        }
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Ingredients Editor View
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class IngredientsEditorView: UIView {

    var onIngredientsChanged: (([Pinch]) -> Void)?
    weak var parentViewController: UIViewController?

    var ingredients: [Pinch] = [] {
        didSet {
            reloadTable()
        }
    }

    private let table = UITableView(frame: .zero, style: .plain)
    private let addButton = UIButton(type: .system)
    private var tableHeightConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTable()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupTable() {
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        addSubview(table)

        addButton.setTitle("+ Add Ingredient", for: .normal)
        addButton.titleLabel?.font = TypographyRecipe.secondaryButton()
        addButton.setTitleColor(SaffronPalette.honeyComb, for: .normal)
        addButton.addTarget(self, action: #selector(addTap), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(addButton)

        let heightConstraint = table.heightAnchor.constraint(equalToConstant: CGFloat(min(ingredients.count, 5)) * 56)
        tableHeightConstraint = heightConstraint

        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: topAnchor),
            table.leadingAnchor.constraint(equalTo: leadingAnchor),
            table.trailingAnchor.constraint(equalTo: trailingAnchor),
            table.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -KitchenSpacing.garnish),
            heightConstraint,

            addButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            addButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    private func reloadTable() {
        table.reloadData()
        tableHeightConstraint?.constant = CGFloat(min(ingredients.count, 5)) * 56
    }

    @objc private func addTap() {
        // Simplified: add empty ingredient at the beginning
        // Update positions of existing ingredients
        for i in 0..<ingredients.count {
            ingredients[i].position = i + 1
        }
        
        let new = Pinch(
            id: UUID(),
            originalName: "",
            normalizedName: "",
            amount: 1,
            unit: .gram,
            aisleID: nil,
            remark: nil,
            isOptional: false,
            position: 0,
            bakedAt: Date(),
            refreshedAt: Date()
        )
        ingredients.insert(new, at: 0)
        reloadTable()
        onIngredientsChanged?(ingredients)
    }
}

extension IngredientsEditorView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ingredients.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Ingredient")
        let pinch = ingredients[indexPath.row]
        cell.textLabel?.text = pinch.originalName.isEmpty ? "Tap to edit" : pinch.originalName
        cell.textLabel?.textColor = SaffronPalette.flour
        cell.textLabel?.font = TypographyRecipe.servingBody()
        cell.detailTextLabel?.text = "\(pinch.amount) \(pinch.unit.shortLabel)"
        cell.detailTextLabel?.textColor = SaffronPalette.steamGrey
        cell.backgroundColor = SaffronPalette.brioche
        cell.selectionStyle = .default
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        editIngredient(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ingredients.remove(at: indexPath.row)
            reloadTable()
            onIngredientsChanged?(ingredients)
        }
    }

    private func editIngredient(at index: Int) {
        guard index < ingredients.count else { return }
        var pinch = ingredients[index]

        let alert = UIAlertController(title: "Edit Ingredient", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Ingredient name"
            textField.text = pinch.originalName
            textField.textColor = SaffronPalette.flour
            textField.keyboardAppearance = .dark
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Amount"
            textField.text = "\(pinch.amount)"
            textField.keyboardType = .decimalPad
            textField.textColor = SaffronPalette.flour
            textField.keyboardAppearance = .dark
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self,
                  let nameField = alert.textFields?[0],
                  let amountField = alert.textFields?[1],
                  let name = nameField.text?.trimmingCharacters(in: .whitespaces),
                  !name.isEmpty,
                  let amountText = amountField.text,
                  let amount = Double(amountText) else {
                return
            }

            pinch.originalName = name
            pinch.normalizedName = name.lowercased()
            pinch.amount = amount
            pinch.refreshedAt = Date()

            self.ingredients[index] = pinch
            self.reloadTable()
            self.onIngredientsChanged?(self.ingredients)
        })

        // Present alert using parent view controller
        parentViewController?.present(alert, animated: true)
    }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MARK: - Steps Editor View
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

final class StepsEditorView: UIView {

    var onStepsChanged: (([SimmerStep]) -> Void)?
    weak var parentViewController: UIViewController?

    var steps: [SimmerStep] = [] {
        didSet {
            reloadTable()
        }
    }

    private let table = UITableView(frame: .zero, style: .plain)
    private let addButton = UIButton(type: .system)
    private var tableHeightConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTable()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupTable() {
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        addSubview(table)

        addButton.setTitle("+ Add Step", for: .normal)
        addButton.titleLabel?.font = TypographyRecipe.secondaryButton()
        addButton.setTitleColor(SaffronPalette.honeyComb, for: .normal)
        addButton.addTarget(self, action: #selector(addTap), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(addButton)

        let heightConstraint = table.heightAnchor.constraint(equalToConstant: CGFloat(min(steps.count, 4)) * 60)
        tableHeightConstraint = heightConstraint

        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: topAnchor),
            table.leadingAnchor.constraint(equalTo: leadingAnchor),
            table.trailingAnchor.constraint(equalTo: trailingAnchor),
            table.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -KitchenSpacing.garnish),
            heightConstraint,

            addButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            addButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    private func reloadTable() {
        table.reloadData()
        tableHeightConstraint?.constant = CGFloat(min(steps.count, 4)) * 60
    }

    @objc private func addTap() {
        // Update positions of existing steps
        for i in 0..<steps.count {
            steps[i].position = i + 1
        }
        
        let new = SimmerStep(
            id: UUID(),
            instruction: "",
            position: 0,
            bakedAt: Date(),
            refreshedAt: Date()
        )
        steps.insert(new, at: 0)
        reloadTable()
        onStepsChanged?(steps)
    }
}

extension StepsEditorView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        steps.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Step")
        let step = steps[indexPath.row]
        cell.textLabel?.text = step.instruction.isEmpty ? "Tap to edit step \(indexPath.row + 1)" : step.instruction
        cell.textLabel?.textColor = SaffronPalette.flour
        cell.textLabel?.font = TypographyRecipe.servingBody()
        cell.textLabel?.numberOfLines = 0
        cell.backgroundColor = SaffronPalette.brioche
        cell.selectionStyle = .default
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        editStep(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            steps.remove(at: indexPath.row)
            reloadTable()
            onStepsChanged?(steps)
        }
    }

    private func editStep(at index: Int) {
        guard index < steps.count else { return }
        var step = steps[index]

        let alert = UIAlertController(title: "Edit Step \(index + 1)", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Step instruction"
            textField.text = step.instruction
            textField.textColor = SaffronPalette.flour
            textField.keyboardAppearance = .dark
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?.first,
                  let instruction = textField.text?.trimmingCharacters(in: .whitespaces),
                  !instruction.isEmpty else {
                return
            }

            step.instruction = instruction
            step.refreshedAt = Date()

            self.steps[index] = step
            self.reloadTable()
            self.onStepsChanged?(self.steps)
        })

        // Present alert using parent view controller
        parentViewController?.present(alert, animated: true)
    }
}
