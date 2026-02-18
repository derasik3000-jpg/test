// ──────────────────────────────────────────────
// TastingOnboardViewController.swift
// с8 – "Menu of 12 Dishes"
//
// Multi-step onboarding:
//   Page 0 – Welcome / promise
//   Page 1 – Choose meal types
//   Page 2 – Servings & rounding
//   Page 3 – Fill set or start empty
// Animated transitions, keyboard-aware.
// ──────────────────────────────────────────────

import UIKit

final class TastingOnboardViewController: UIViewController {

    // ── Callback ─────────────────────────────

    var onTastingComplete: (() -> Void)?

    // ── State ────────────────────────────────

    private var currentCourse = 0
    private let totalCourses = 4

    private var chosenMealMask: Int = {
        // Default: breakfast + lunch + dinner ON, snack OFF
        CourseKind.breakfast.bitmask | CourseKind.lunch.bitmask | CourseKind.dinner.bitmask
    }()

    private var chosenServings: Int = 2
    private var roundingOn: Bool = true

    // ── UI Containers ────────────────────────

    private let canvasScroll = UIScrollView()
    private var plateViews: [UIView] = []

    private let dotsStack = UIStackView()
    private var dotLayers: [UIView] = []

    private let nextLadle = SaffronPalette.brewPrimaryButton(titled: "Next")
    private let skipSpoon = SaffronPalette.brewSecondaryButton(titled: "Skip")

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Lifecycle
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SaffronPalette.crust
        buildChrome()
        buildPlates()
        updateDots()
        updateButtons()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let w = view.bounds.width
        canvasScroll.contentSize = CGSize(width: w * CGFloat(totalCourses), height: canvasScroll.bounds.height)
        for (i, plate) in plateViews.enumerated() {
            plate.frame = CGRect(x: w * CGFloat(i), y: 0,
                                 width: w, height: canvasScroll.bounds.height)
        }
        
        // Update preferred max width for labels after layout
        updateLabelMaxWidths()
    }
    
    private func updateLabelMaxWidths() {
        let screenWidth = view.bounds.width
        let maxTextWidth = min(screenWidth - (KitchenSpacing.platter * 2), 320)
        for plate in plateViews {
            updateMaxWidthForLabels(in: plate, maxWidth: maxTextWidth)
        }
    }
    
    private func updateMaxWidthForLabels(in view: UIView, maxWidth: CGFloat) {
        if let label = view as? UILabel, (label.numberOfLines == 0 || label.numberOfLines > 1) {
            label.preferredMaxLayoutWidth = maxWidth
        }
        for subview in view.subviews {
            updateMaxWidthForLabels(in: subview, maxWidth: maxWidth)
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Chrome (dots + buttons)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func buildChrome() {

        // ── Scroll ───────────────────────────
        canvasScroll.isPagingEnabled = false
        canvasScroll.isScrollEnabled = false
        canvasScroll.showsHorizontalScrollIndicator = false
        canvasScroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvasScroll)

        // ── Dots ─────────────────────────────
        dotsStack.axis = .horizontal
        dotsStack.spacing = KitchenSpacing.garnish
        dotsStack.alignment = .center
        dotsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dotsStack)

        for _ in 0..<totalCourses {
            let dot = UIView()
            dot.layer.cornerRadius = 4
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: 8).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 8).isActive = true
            dotsStack.addArrangedSubview(dot)
            dotLayers.append(dot)
        }

        // ── Buttons ──────────────────────────
        nextLadle.addTarget(self, action: #selector(nextTap), for: .touchUpInside)
        skipSpoon.addTarget(self, action: #selector(skipTap), for: .touchUpInside)
        view.addSubview(nextLadle)
        view.addSubview(skipSpoon)

        // ── Constraints ──────────────────────
        NSLayoutConstraint.activate([
            canvasScroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            canvasScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasScroll.bottomAnchor.constraint(equalTo: dotsStack.topAnchor, constant: -KitchenSpacing.plate),

            dotsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dotsStack.bottomAnchor.constraint(equalTo: nextLadle.topAnchor, constant: -KitchenSpacing.platter),

            nextLadle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: KitchenSpacing.platter),
            nextLadle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -KitchenSpacing.platter),
            nextLadle.bottomAnchor.constraint(equalTo: skipSpoon.topAnchor, constant: -KitchenSpacing.napkin),

            skipSpoon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: KitchenSpacing.platter),
            skipSpoon.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -KitchenSpacing.platter),
            skipSpoon.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -KitchenSpacing.plate),
        ])
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Plate Pages
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func buildPlates() {
        let plates = [
            buildWelcomePlate(),
            buildMealTypePlate(),
            buildServingsPlate(),
            buildFillSetPlate(),
        ]
        for plate in plates {
            canvasScroll.addSubview(plate)
            plateViews.append(plate)
        }
    }

    // ── Page 0: Welcome ──────────────────────

    private func buildWelcomePlate() -> UIView {
        let container = UIView()

        let heroEmoji = makeLabel("🍽", font: .systemFont(ofSize: 72))
        let heading = makeLabel("Your Kitchen,\nSimplified", font: TypographyRecipe.grandBanquet(), color: SaffronPalette.flour, lines: 2, alignment: .center)
        let sub = makeLabel(
            "Pick 12 favorite dishes.\nGet a weekly menu in one tap.\nShopping list builds itself.",
            font: TypographyRecipe.sideNote(),
            color: SaffronPalette.steamGrey,
            lines: 0,
            alignment: .center
        )

        // Animated cards preview
        let cardsRow = buildMiniCardsRow()

        let stack = verticalStack([heroEmoji, heading, sub, cardsRow], spacing: KitchenSpacing.tray)
        container.addSubview(stack)
        pinCenter(stack, in: container)
        return container
    }

    private func buildMiniCardsRow() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = KitchenSpacing.garnish
        row.alignment = .center
        row.distribution = .fillEqually
        row.translatesAutoresizingMaskIntoConstraints = false

        let emojis = ["🥗", "🍝", "🥚", "🌮"]
        for (i, emoji) in emojis.enumerated() {
            let card = UIView()
            card.backgroundColor = SaffronPalette.brioche
            card.layer.cornerRadius = PlatingCorner.biscuit
            card.layer.borderWidth = 1
            card.layer.borderColor = SaffronPalette.honeyComb.withAlphaComponent(0.3).cgColor
            card.translatesAutoresizingMaskIntoConstraints = false
            card.heightAnchor.constraint(equalToConstant: 60).isActive = true

            let lbl = UILabel()
            lbl.text = emoji
            lbl.font = .systemFont(ofSize: 28)
            lbl.textAlignment = .center
            lbl.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(lbl)
            NSLayoutConstraint.activate([
                lbl.centerXAnchor.constraint(equalTo: card.centerXAnchor),
                lbl.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            ])

            card.alpha = 0
            card.transform = CGAffineTransform(translationX: 0, y: 20)
            row.addArrangedSubview(card)

            // Staggered entrance
            UIView.animate(
                withDuration: 0.5,
                delay: 0.4 + Double(i) * 0.12,
                usingSpringWithDamping: 0.75,
                initialSpringVelocity: 0.3,
                options: []
            ) {
                card.alpha = 1
                card.transform = .identity
            }
        }
        return row
    }

    // ── Page 1: Meal Types ───────────────────

    private func buildMealTypePlate() -> UIView {
        let container = UIView()

        let heading = makeLabel("What's on your plate?", font: TypographyRecipe.chefTitle(), color: SaffronPalette.flour, alignment: .center)
        let sub = makeLabel("Choose which meals to plan each day.\nYou can change this anytime.", font: TypographyRecipe.sideNote(), color: SaffronPalette.steamGrey, lines: 2, alignment: .center)

        let toggleStack = UIStackView()
        toggleStack.axis = .vertical
        toggleStack.spacing = KitchenSpacing.plate
        toggleStack.translatesAutoresizingMaskIntoConstraints = false

        for kind in CourseKind.allCases {
            let row = buildMealToggleRow(kind)
            toggleStack.addArrangedSubview(row)
        }

        let stack = verticalStack([heading, sub, toggleStack], spacing: KitchenSpacing.platter)
        container.addSubview(stack)
        pinCenter(stack, in: container, hPad: KitchenSpacing.platter)
        return container
    }

    private func buildMealToggleRow(_ kind: CourseKind) -> UIView {
        let row = UIView()
        row.backgroundColor = SaffronPalette.brioche
        row.layer.cornerRadius = PlatingCorner.biscuit
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 56).isActive = true
        row.isUserInteractionEnabled = true

        let icon = UIImageView(image: UIImage(systemName: kind.sfIcon))
        icon.tintColor = SaffronPalette.honeyComb
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.widthAnchor.constraint(equalToConstant: 24).isActive = true
        icon.isUserInteractionEnabled = false

        let lbl = UILabel()
        lbl.text = kind.displayLabel
        lbl.font = TypographyRecipe.cardLabel()
        lbl.textColor = SaffronPalette.flour
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        lbl.setContentHuggingPriority(.defaultLow, for: .horizontal)
        lbl.isUserInteractionEnabled = false

        let toggle = UISwitch()
        toggle.isOn = (chosenMealMask & kind.bitmask) != 0
        toggle.tag = kind.rawValue
        toggle.addTarget(self, action: #selector(mealToggled(_:)), for: .valueChanged)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.setContentCompressionResistancePriority(.required, for: .horizontal)
        toggle.setContentHuggingPriority(.required, for: .horizontal)
        toggle.isUserInteractionEnabled = true

        row.addSubview(icon)
        row.addSubview(lbl)
        row.addSubview(toggle)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: KitchenSpacing.plate),
            icon.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            lbl.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: KitchenSpacing.napkin),
            lbl.trailingAnchor.constraint(lessThanOrEqualTo: toggle.leadingAnchor, constant: -KitchenSpacing.napkin),
            lbl.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            toggle.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -KitchenSpacing.plate),
            toggle.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])

        return row
    }

    @objc private func mealToggled(_ sender: UISwitch) {
        guard let kind = CourseKind(rawValue: sender.tag) else { return }
        if sender.isOn {
            chosenMealMask |= kind.bitmask
        } else {
            chosenMealMask &= ~kind.bitmask
        }
    }

    // ── Page 2: Servings & Rounding ──────────

    private func buildServingsPlate() -> UIView {
        let container = UIView()

        let heading = makeLabel("How many servings?", font: TypographyRecipe.chefTitle(), color: SaffronPalette.flour, alignment: .center)
        let sub = makeLabel("This affects your shopping list quantities.", font: TypographyRecipe.sideNote(), color: SaffronPalette.steamGrey, alignment: .center)

        // Servings selector
        let servingsRow = UIStackView()
        servingsRow.axis = .horizontal
        servingsRow.spacing = KitchenSpacing.napkin
        servingsRow.distribution = .fillEqually
        servingsRow.translatesAutoresizingMaskIntoConstraints = false

        for n in 1...4 {
            let btn = UIButton(type: .system)
            btn.setTitle("\(n)", for: .normal)
            btn.titleLabel?.font = TypographyRecipe.counterChip()
            btn.tag = n
            btn.layer.cornerRadius = PlatingCorner.biscuit
            btn.layer.borderWidth = 2
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.heightAnchor.constraint(equalToConstant: 60).isActive = true
            btn.addTarget(self, action: #selector(servingsTapped(_:)), for: .touchUpInside)
            styleServingButton(btn, selected: n == chosenServings)
            servingsRow.addArrangedSubview(btn)
        }

        // Rounding toggle
        let roundRow = UIView()
        roundRow.backgroundColor = SaffronPalette.brioche
        roundRow.layer.cornerRadius = PlatingCorner.biscuit
        roundRow.translatesAutoresizingMaskIntoConstraints = false
        roundRow.heightAnchor.constraint(equalToConstant: 56).isActive = true

        let roundLabel = UILabel()
        roundLabel.text = "Round to convenient values"
        roundLabel.font = TypographyRecipe.servingBody()
        roundLabel.textColor = SaffronPalette.flour
        roundLabel.numberOfLines = 2
        roundLabel.lineBreakMode = .byWordWrapping
        roundLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        roundLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        roundLabel.translatesAutoresizingMaskIntoConstraints = false

        let roundToggle = UISwitch()
        roundToggle.isOn = roundingOn
        roundToggle.addTarget(self, action: #selector(roundingToggled(_:)), for: .valueChanged)
        roundToggle.translatesAutoresizingMaskIntoConstraints = false
        roundToggle.setContentCompressionResistancePriority(.required, for: .horizontal)
        roundToggle.setContentHuggingPriority(.required, for: .horizontal)

        roundRow.addSubview(roundLabel)
        roundRow.addSubview(roundToggle)
        NSLayoutConstraint.activate([
            roundLabel.leadingAnchor.constraint(equalTo: roundRow.leadingAnchor, constant: KitchenSpacing.plate),
            roundLabel.trailingAnchor.constraint(lessThanOrEqualTo: roundToggle.leadingAnchor, constant: -KitchenSpacing.napkin),
            roundLabel.topAnchor.constraint(greaterThanOrEqualTo: roundRow.topAnchor, constant: KitchenSpacing.garnish),
            roundLabel.bottomAnchor.constraint(lessThanOrEqualTo: roundRow.bottomAnchor, constant: -KitchenSpacing.garnish),
            roundLabel.centerYAnchor.constraint(equalTo: roundRow.centerYAnchor),
            roundToggle.trailingAnchor.constraint(equalTo: roundRow.trailingAnchor, constant: -KitchenSpacing.plate),
            roundToggle.centerYAnchor.constraint(equalTo: roundRow.centerYAnchor),
        ])

        let example = makeLabel("850 ml → 1 l", font: TypographyRecipe.croutonCaption(), color: SaffronPalette.caramelWhisper, alignment: .center)

        let stack = verticalStack([heading, sub, servingsRow, roundRow, example], spacing: KitchenSpacing.tray)
        container.addSubview(stack)
        pinCenter(stack, in: container, hPad: KitchenSpacing.platter)
        return container
    }

    @objc private func servingsTapped(_ sender: UIButton) {
        chosenServings = sender.tag
        // Update all buttons in parent stack
        guard let stack = sender.superview as? UIStackView else { return }
        for case let btn as UIButton in stack.arrangedSubviews {
            styleServingButton(btn, selected: btn.tag == chosenServings)
        }
    }

    private func styleServingButton(_ btn: UIButton, selected: Bool) {
        UIView.animate(withDuration: 0.2) {
            if selected {
                btn.backgroundColor = SaffronPalette.honeyComb
                btn.setTitleColor(SaffronPalette.crust, for: .normal)
                btn.layer.borderColor = SaffronPalette.honeyComb.cgColor
            } else {
                btn.backgroundColor = SaffronPalette.brioche
                btn.setTitleColor(SaffronPalette.flour, for: .normal)
                btn.layer.borderColor = SaffronPalette.crumbLine.cgColor
            }
        }
    }

    @objc private func roundingToggled(_ sender: UISwitch) {
        roundingOn = sender.isOn
    }

    // ── Page 3: Fill Set ─────────────────────

    private func buildFillSetPlate() -> UIView {
        let container = UIView()

        let heading = makeLabel("Ready to cook!", font: TypographyRecipe.chefTitle(), color: SaffronPalette.flour, alignment: .center)
        let sub = makeLabel(
            "Start creating your collection of 12 dishes.\nTap on empty slots to add your favorite meals.",
            font: TypographyRecipe.sideNote(),
            color: SaffronPalette.steamGrey,
            lines: 0,
            alignment: .center
        )

        // Grid preview (3×4 mini slots)
        let gridPreview = buildMiniGrid()

        // Badge teaser
        let badgeRow = UIStackView()
        badgeRow.axis = .horizontal
        badgeRow.spacing = KitchenSpacing.napkin
        badgeRow.alignment = .center
        badgeRow.translatesAutoresizingMaskIntoConstraints = false

        let trophyIcon = UIImageView(image: UIImage(systemName: "trophy.fill"))
        trophyIcon.tintColor = SaffronPalette.honeyComb
        trophyIcon.translatesAutoresizingMaskIntoConstraints = false
        trophyIcon.widthAnchor.constraint(equalToConstant: 22).isActive = true
        trophyIcon.heightAnchor.constraint(equalToConstant: 22).isActive = true

        let badgeLabel = makeLabel("Fill all 12 slots to earn your first badge!", font: TypographyRecipe.croutonCaption(), color: SaffronPalette.butterGlaze)

        badgeRow.addArrangedSubview(trophyIcon)
        badgeRow.addArrangedSubview(badgeLabel)

        let stack = verticalStack([heading, sub, gridPreview, badgeRow], spacing: KitchenSpacing.tray)
        container.addSubview(stack)
        pinCenter(stack, in: container, hPad: KitchenSpacing.platter)
        return container
    }

    private func buildMiniGrid() -> UIView {
        let grid = UIView()
        grid.translatesAutoresizingMaskIntoConstraints = false
        grid.heightAnchor.constraint(equalToConstant: 180).isActive = true

        let cols = 4
        let rows = 3
        let spacing: CGFloat = 6
        let cardW: CGFloat = 60
        let cardH: CGFloat = 52
        
        // Create cards container
        let cardsContainer = UIView()
        cardsContainer.translatesAutoresizingMaskIntoConstraints = false
        grid.addSubview(cardsContainer)
        
        NSLayoutConstraint.activate([
            cardsContainer.centerXAnchor.constraint(equalTo: grid.centerXAnchor),
            cardsContainer.topAnchor.constraint(equalTo: grid.topAnchor),
            cardsContainer.bottomAnchor.constraint(equalTo: grid.bottomAnchor),
            cardsContainer.widthAnchor.constraint(equalToConstant: CGFloat(cols) * cardW + CGFloat(cols - 1) * spacing),
        ])

        for idx in 0..<12 {
            let r = idx / cols
            let c = idx % cols
            let x = CGFloat(c) * (cardW + spacing)
            let y = CGFloat(r) * (cardH + spacing)

            let card = UIView()
            card.backgroundColor = SaffronPalette.brioche
            card.layer.cornerRadius = PlatingCorner.crouton
            card.layer.borderWidth = 1
            card.layer.borderColor = SaffronPalette.honeyComb.withAlphaComponent(0.2).cgColor
            card.translatesAutoresizingMaskIntoConstraints = false
            cardsContainer.addSubview(card)

            let numLabel = UILabel()
            numLabel.text = "\(idx + 1)"
            numLabel.font = TypographyRecipe.croutonCaption()
            numLabel.textColor = SaffronPalette.ashDust
            numLabel.textAlignment = .center
            numLabel.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(numLabel)
            
            NSLayoutConstraint.activate([
                card.leadingAnchor.constraint(equalTo: cardsContainer.leadingAnchor, constant: x),
                card.topAnchor.constraint(equalTo: cardsContainer.topAnchor, constant: y),
                card.widthAnchor.constraint(equalToConstant: cardW),
                card.heightAnchor.constraint(equalToConstant: cardH),
                
                numLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
                numLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            ])

            card.alpha = 0
            card.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

            UIView.animate(
                withDuration: 0.4,
                delay: Double(idx) * 0.04,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.4,
                options: []
            ) {
                card.alpha = 1
                card.transform = .identity
            }
        }

        return grid
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Navigation Actions
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    @objc private func nextTap() {
        if currentCourse < totalCourses - 1 {
            advancePlate()
        } else {
            finishOnboarding()
        }
    }

    @objc private func skipTap() {
        if currentCourse < totalCourses - 1 {
            // Skip = advance without changing
            advancePlate()
        } else {
            finishOnboarding()
        }
    }

    private func advancePlate() {
        currentCourse += 1
        let x = view.bounds.width * CGFloat(currentCourse)

        let reduced = FrostBox.shouldReduceMotion
        UIView.animate(
            withDuration: reduced ? 0.15 : 0.4,
            delay: 0,
            usingSpringWithDamping: 0.88,
            initialSpringVelocity: 0.3,
            options: []
        ) {
            self.canvasScroll.contentOffset = CGPoint(x: x, y: 0)
        }
        updateDots()
        updateButtons()
    }

    private func updateDots() {
        for (i, dot) in dotLayers.enumerated() {
            let active = i == currentCourse
            UIView.animate(withDuration: 0.25) {
                dot.backgroundColor = active ? SaffronPalette.honeyComb : SaffronPalette.ashDust
                dot.transform = active ? CGAffineTransform(scaleX: 1.3, y: 1.3) : .identity
            }
        }
    }

    private func updateButtons() {
        let isLast = currentCourse == totalCourses - 1

        UIView.animate(withDuration: 0.2) {
            if isLast {
                self.nextLadle.setTitle("Get Started", for: .normal)
                self.skipSpoon.setTitle("Skip", for: .normal)
            } else {
                self.nextLadle.setTitle("Next", for: .normal)
                self.skipSpoon.setTitle("Skip", for: .normal)
            }
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Finish
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func finishOnboarding() {
        let vault = CellarVault.shared

        // Save meal types + servings + rounding
        vault.stir { ledger in
            ledger.config.enabledCoursesMask = self.chosenMealMask
            ledger.config.defaultServings = self.chosenServings
            ledger.config.roundingEnabled = self.roundingOn
            ledger.config.refreshedAt = Date()
        }

        // Start with empty slots - user will fill them manually
        onTastingComplete?()
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Layout Helpers
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func makeLabel(
        _ text: String,
        font: UIFont,
        color: UIColor = SaffronPalette.flour,
        lines: Int = 1,
        alignment: NSTextAlignment = .center
    ) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = font
        lbl.textColor = color
        lbl.textAlignment = alignment
        lbl.numberOfLines = lines
        lbl.lineBreakMode = .byWordWrapping
        lbl.translatesAutoresizingMaskIntoConstraints = false
        if lines == 0 || lines > 1 {
            // Set preferred max width for proper wrapping
            lbl.setContentCompressionResistancePriority(.required, for: .vertical)
            lbl.setContentHuggingPriority(.required, for: .vertical)
        }
        return lbl
    }

    private func verticalStack(_ views: [UIView], spacing: CGFloat) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.spacing = spacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    private func pinCenter(_ child: UIView, in parent: UIView, hPad: CGFloat = KitchenSpacing.plate) {
        child.translatesAutoresizingMaskIntoConstraints = false
        
        // Calculate max text width for better readability (limit to ~320pt for optimal reading)
        let screenWidth = UIScreen.main.bounds.width
        let maxTextWidth = min(screenWidth - (hPad * 2), 320)
        
        // For labels with multiple lines, set preferred max width
        if let stack = child as? UIStackView {
            for arrangedSubview in stack.arrangedSubviews {
                if let label = arrangedSubview as? UILabel, label.numberOfLines == 0 || label.numberOfLines > 1 {
                    label.preferredMaxLayoutWidth = maxTextWidth
                }
            }
        } else if let label = child as? UILabel, label.numberOfLines == 0 || label.numberOfLines > 1 {
            label.preferredMaxLayoutWidth = maxTextWidth
        }
        
        NSLayoutConstraint.activate([
            child.centerYAnchor.constraint(equalTo: parent.centerYAnchor, constant: -30),
            child.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
            child.widthAnchor.constraint(lessThanOrEqualToConstant: screenWidth - (hPad * 2)),
            child.leadingAnchor.constraint(greaterThanOrEqualTo: parent.leadingAnchor, constant: hPad),
            child.trailingAnchor.constraint(lessThanOrEqualTo: parent.trailingAnchor, constant: -hPad),
        ])
    }
}
