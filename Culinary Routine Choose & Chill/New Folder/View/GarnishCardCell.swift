
import UIKit

final class GarnishCardCell: UICollectionViewCell {

    // ── Reuse Identifier ──────────────────────

    static let reuseTag = "GarnishCardCell"

    // ── UI Elements ────────────────────────────

    private let cardContainer: UIView = {
        let v = UIView()
        v.backgroundColor = SaffronPalette.brioche
        v.layer.cornerRadius = PlatingCorner.biscuit
        v.layer.borderWidth = 1
        v.layer.borderColor = SaffronPalette.crumbLine.cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = TypographyRecipe.cardLabel()
        lbl.textColor = SaffronPalette.flour
        lbl.numberOfLines = 2
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let tagsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fill
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let favoriteIcon: UIImageView = {
        let img = UIImageView(image: UIImage(systemName: "star.fill"))
        img.tintColor = SaffronPalette.honeyComb
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        img.isHidden = true
        return img
    }()

    private let readinessBadge: UIView = {
        let v = UIView()
        v.backgroundColor = SaffronPalette.mintGarnish.withAlphaComponent(0.2)
        v.layer.cornerRadius = 8
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()

    private let readinessLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = TypographyRecipe.sprinkleTag()
        lbl.textColor = SaffronPalette.mintGarnish
        lbl.text = "✓"
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let emptyPlaceholder: UILabel = {
        let lbl = UILabel()
        lbl.text = "+"
        lbl.font = TypographyRecipe.chefTitle()
        lbl.textColor = SaffronPalette.ashDust
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.isHidden = true
        return lbl
    }()

    // ── State ──────────────────────────────────

    private var currentEntree: Entree?

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Init
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Setup
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func setupCell() {
        contentView.addSubview(cardContainer)
        cardContainer.addSubview(titleLabel)
        cardContainer.addSubview(tagsStack)
        cardContainer.addSubview(favoriteIcon)
        cardContainer.addSubview(readinessBadge)
        readinessBadge.addSubview(readinessLabel)
        cardContainer.addSubview(emptyPlaceholder)

        NSLayoutConstraint.activate([
            cardContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: KitchenSpacing.garnish),
            titleLabel.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: KitchenSpacing.garnish),
            titleLabel.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -KitchenSpacing.garnish),

            tagsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: KitchenSpacing.crumb),
            tagsStack.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: KitchenSpacing.garnish),
            tagsStack.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -KitchenSpacing.garnish),
            tagsStack.heightAnchor.constraint(equalToConstant: 16),

            favoriteIcon.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: KitchenSpacing.crumb),
            favoriteIcon.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -KitchenSpacing.crumb),
            favoriteIcon.widthAnchor.constraint(equalToConstant: 16),
            favoriteIcon.heightAnchor.constraint(equalToConstant: 16),

            readinessBadge.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: -KitchenSpacing.crumb),
            readinessBadge.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -KitchenSpacing.crumb),
            readinessBadge.widthAnchor.constraint(equalToConstant: 20),
            readinessBadge.heightAnchor.constraint(equalToConstant: 20),

            readinessLabel.centerXAnchor.constraint(equalTo: readinessBadge.centerXAnchor),
            readinessLabel.centerYAnchor.constraint(equalTo: readinessBadge.centerYAnchor),

            emptyPlaceholder.centerXAnchor.constraint(equalTo: cardContainer.centerXAnchor),
            emptyPlaceholder.centerYAnchor.constraint(equalTo: cardContainer.centerYAnchor),
        ])

        // Shadow
        cardContainer.applySeasoning(ShadowSeasoning.softGlow)

        // Selection highlight
        let selectedBG = UIView()
        selectedBG.backgroundColor = SaffronPalette.honeyComb.withAlphaComponent(0.15)
        selectedBackgroundView = selectedBG
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Configuration
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /// Populates the cell with dish data.
    func season(with entree: Entree) {
        currentEntree = entree

        let isEmpty = !entree.isReadyToServe

        // Empty slot state
        emptyPlaceholder.isHidden = !isEmpty
        titleLabel.isHidden = isEmpty
        tagsStack.isHidden = isEmpty
        favoriteIcon.isHidden = isEmpty || !entree.isFavorite
        readinessBadge.isHidden = isEmpty || !entree.isReadyToServe

        if isEmpty {
            cardContainer.layer.borderColor = SaffronPalette.ashDust.withAlphaComponent(0.3).cgColor
            cardContainer.backgroundColor = SaffronPalette.brioche.withAlphaComponent(0.5)
            return
        }

        // Filled slot state
        cardContainer.layer.borderColor = entree.isReadyToServe
            ? SaffronPalette.honeyComb.withAlphaComponent(0.4).cgColor
            : SaffronPalette.pepperFlake.withAlphaComponent(0.4).cgColor
        cardContainer.backgroundColor = SaffronPalette.brioche

        titleLabel.text = entree.title

        // Build tags
        tagsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let tags = entree.courseTags
        if tags.isEmpty {
            let warning = UILabel()
            warning.text = "⚠️"
            warning.font = TypographyRecipe.sprinkleTag()
            warning.textColor = SaffronPalette.pepperFlake
            warning.translatesAutoresizingMaskIntoConstraints = false
            warning.setContentHuggingPriority(.required, for: .horizontal)
            warning.setContentCompressionResistancePriority(.required, for: .horizontal)
            tagsStack.addArrangedSubview(warning)
        } else {
            for tag in tags.prefix(3) { // Max 3 tags
                let chip = makeTagChip(tag)
                tagsStack.addArrangedSubview(chip)
            }
        }

        favoriteIcon.isHidden = !entree.isFavorite
        readinessBadge.isHidden = !entree.isReadyToServe
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Helpers
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func makeTagChip(_ kind: CourseKind) -> UIView {
        let chip = UIView()
        chip.backgroundColor = kind.tintColor.withAlphaComponent(0.2)
        chip.layer.cornerRadius = 4
        chip.translatesAutoresizingMaskIntoConstraints = false

        let icon = UILabel()
        icon.text = kind.emoji
        icon.font = .systemFont(ofSize: 10)
        icon.textAlignment = .center
        icon.translatesAutoresizingMaskIntoConstraints = false
        chip.addSubview(icon)

        NSLayoutConstraint.activate([
            chip.heightAnchor.constraint(equalToConstant: 16),
            chip.widthAnchor.constraint(equalToConstant: 16),

            icon.centerXAnchor.constraint(equalTo: chip.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: chip.centerYAnchor),
        ])
        
        // Set content hugging and compression resistance priorities to prevent stretching
        chip.setContentHuggingPriority(.required, for: .horizontal)
        chip.setContentCompressionResistancePriority(.required, for: .horizontal)

        return chip
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Selection Animation
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    override var isHighlighted: Bool {
        didSet {
            guard !FrostBox.shouldReduceMotion else { return }
            UIView.animate(withDuration: 0.15) {
                self.transform = self.isHighlighted
                    ? CGAffineTransform(scaleX: 0.95, y: 0.95)
                    : .identity
            }
        }
    }
}
