
import UIKit

final class SimpleDishCell: UITableViewCell {

    // ── Reuse Identifier ──────────────────────

    static let reuseTag = "SimpleDishCell"

    // ── UI Elements ────────────────────────────

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = SaffronPalette.honeyComb
        v.layer.cornerRadius = PlatingCorner.biscuit
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let iconImageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.tintColor = .black
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = TypographyRecipe.servingBody()
        lbl.textColor = .black
        lbl.numberOfLines = 1
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "trash"), for: .normal)
        btn.tintColor = .black
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let editButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "pencil"), for: .normal)
        btn.tintColor = .black
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let favoriteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "star"), for: .normal)
        btn.tintColor = .black
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let emptyPlaceholder: UILabel = {
        let lbl = UILabel()
        lbl.text = "+"
        lbl.font = TypographyRecipe.chefTitle()
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.isHidden = true
        return lbl
    }()

    // ── Callbacks ──────────────────────────────

    var onDeleteTapped: (() -> Void)?
    var onEditTapped: (() -> Void)?
    var onFavoriteTapped: (() -> Void)?

    // ── State ──────────────────────────────────

    private var currentEntree: Entree?

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Init
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Setup
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Add container view to contentView
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(deleteButton)
        containerView.addSubview(editButton)
        containerView.addSubview(favoriteButton)
        containerView.addSubview(emptyPlaceholder)

        // Button actions
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            // Container view with padding
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: KitchenSpacing.napkin),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: KitchenSpacing.plate),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -KitchenSpacing.plate),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -KitchenSpacing.napkin),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),

            // Icon (left)
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: KitchenSpacing.plate),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),

            // Title (after icon)
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: KitchenSpacing.plate),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: deleteButton.leadingAnchor, constant: -KitchenSpacing.plate),

            // Favorite button (rightmost)
            favoriteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -KitchenSpacing.plate),
            favoriteButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44),

            // Edit button (before favorite)
            editButton.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -KitchenSpacing.garnish),
            editButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 44),
            editButton.heightAnchor.constraint(equalToConstant: 44),

            // Delete button (before edit)
            deleteButton.trailingAnchor.constraint(equalTo: editButton.leadingAnchor, constant: -KitchenSpacing.garnish),
            deleteButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 44),
            deleteButton.heightAnchor.constraint(equalToConstant: 44),

            // Empty placeholder (centered)
            emptyPlaceholder.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            emptyPlaceholder.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Configuration
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    func configure(with entree: Entree) {
        currentEntree = entree

        let isEmpty = !entree.isReadyToServe

        // Empty cell state
        emptyPlaceholder.isHidden = !isEmpty
        iconImageView.isHidden = isEmpty
        titleLabel.isHidden = isEmpty
        deleteButton.isHidden = isEmpty
        editButton.isHidden = isEmpty
        favoriteButton.isHidden = isEmpty

        if isEmpty {
            return
        }

        // Filled cell state
        // Set icon (use first course tag by priority order, not random from Set)
        // Priority: Breakfast > Lunch > Dinner > Snack
        let iconTag = CourseKind.allCases.first { entree.courseTags.contains($0) }
        if let tag = iconTag {
            iconImageView.image = UIImage(systemName: tag.sfIcon)
        } else {
            iconImageView.image = UIImage(systemName: "fork.knife")
        }

        titleLabel.text = entree.title

        // Configure favorite button
        updateFavoriteButton(isFavorite: entree.isFavorite)
    }

    private func updateFavoriteButton(isFavorite: Bool) {
        favoriteButton.layer.cornerRadius = 8
        favoriteButton.clipsToBounds = true
        
        if isFavorite {
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            favoriteButton.backgroundColor = .white
            favoriteButton.tintColor = SaffronPalette.honeyComb
            favoriteButton.layer.borderWidth = 0
        } else {
            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            favoriteButton.backgroundColor = .clear
            favoriteButton.tintColor = .black
            favoriteButton.layer.borderWidth = 1
            favoriteButton.layer.borderColor = UIColor.black.cgColor
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Actions
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    @objc private func deleteTapped() {
        onDeleteTapped?()
    }

    @objc private func editTapped() {
        onEditTapped?()
    }

    @objc private func favoriteTapped() {
        onFavoriteTapped?()
    }
}
