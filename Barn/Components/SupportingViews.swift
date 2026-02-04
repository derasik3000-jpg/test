//
//  SupportingViews.swift
//  DAYTRACE
//
//  Supporting UI components for Today screen
//

import UIKit

// MARK: - SectionHeaderView

final class SectionHeaderView: UIView {
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ColorPalette.primary
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = ColorPalette.primary
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
        
        addSubview(iconView)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func configure(title: String, icon: String) {
        titleLabel.text = title
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        iconView.image = UIImage(systemName: icon, withConfiguration: config)
    }
}

// MARK: - EmptyStateView

final class EmptyStateView: UIView {
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 48)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = ColorPalette.primary.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = ColorPalette.primary.withAlphaComponent(0.5)
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
            emojiLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            emojiLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
            heightAnchor.constraint(equalToConstant: 160)
        ])
    }
    
    func configure(emoji: String, title: String, subtitle: String) {
        emojiLabel.text = emoji
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}

// MARK: - CelebrationOverlay

final class CelebrationOverlay: UIView {
    
    private let confettiEmitter = CAEmitterLayer()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "🎉 All Done!"
        label.font = .systemFont(ofSize: 32, weight: .heavy)
        label.textColor = ColorPalette.primary
        label.textAlignment = .center
        label.alpha = 0
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
        backgroundColor = ColorPalette.background.withAlphaComponent(0.9)
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        setupConfetti()
    }
    
    private func setupConfetti() {
        confettiEmitter.emitterPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: -50)
        confettiEmitter.emitterShape = .line
        confettiEmitter.emitterSize = CGSize(width: UIScreen.main.bounds.width, height: 1)
        confettiEmitter.birthRate = 0
        
        let colors: [UIColor] = [
            ColorPalette.primary,
            ColorPalette.surface,
            .white,
            ColorPalette.background
        ]
        
        let cells: [CAEmitterCell] = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 8
            cell.lifetime = 4
            cell.velocity = 150
            cell.velocityRange = 50
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 4
            cell.spin = 3
            cell.spinRange = 6
            cell.scale = 0.15
            cell.scaleRange = 0.1
            cell.contents = createConfettiImage(color: color)?.cgImage
            return cell
        }
        
        confettiEmitter.emitterCells = cells
        layer.addSublayer(confettiEmitter)
    }
    
    private func createConfettiImage(color: UIColor) -> UIImage? {
        let size = CGSize(width: 12, height: 12)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let rect = CGRect(origin: .zero, size: size)
        color.setFill()
        UIBezierPath(roundedRect: rect, cornerRadius: 2).fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func animate() {
        // Start confetti
        confettiEmitter.birthRate = 1
        
        // Animate message
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
            self.messageLabel.alpha = 1
            self.messageLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.messageLabel.transform = .identity
            }
        }
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Stop confetti after a bit
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.confettiEmitter.birthRate = 0
        }
        
        // Fade out
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            UIView.animate(withDuration: 0.3) {
                self.alpha = 0
            } completion: { _ in
                self.alpha = 1
                self.messageLabel.alpha = 0
            }
        }
    }
}

// MARK: - AvatarPickerSheet

final class AvatarPickerSheet: UIViewController {
    
    var currentEmoji: String = "😊"
    var onEmojiSelected: ((String) -> Void)?
    
    private let emojis = [
        ["😊", "😎", "🥳", "😴", "🤓", "🧐"],
        ["💪", "🧘", "🏃", "🌟", "🔥", "✨"],
        ["🐱", "🐶", "🦊", "🐼", "🦁", "🐸"],
        ["🌸", "🌺", "🌻", "🌈", "🌙", "⭐️"]
    ]
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose Your Avatar"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = ColorPalette.primary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorPalette.background
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}

extension AvatarPickerSheet: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as? EmojiCell else {
            return UICollectionViewCell()
        }
        
        let emoji = emojis[indexPath.section][indexPath.item]
        cell.configure(emoji: emoji, isSelected: emoji == currentEmoji)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 60) / 6
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emoji = emojis[indexPath.section][indexPath.item]
        currentEmoji = emoji
        onEmojiSelected?(emoji)
        
        collectionView.reloadData()
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dismiss(animated: true)
        }
    }
}

// MARK: - EmojiCell

final class EmojiCell: UICollectionViewCell {
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectionRing: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.clear.cgColor
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
        contentView.addSubview(selectionRing)
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            selectionRing.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectionRing.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectionRing.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            selectionRing.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(emoji: String, isSelected: Bool) {
        emojiLabel.text = emoji
        
        if isSelected {
            selectionRing.layer.borderColor = ColorPalette.primary.cgColor
            selectionRing.backgroundColor = ColorPalette.primary.withAlphaComponent(0.1)
        } else {
            selectionRing.layer.borderColor = UIColor.clear.cgColor
            selectionRing.backgroundColor = .clear
        }
    }
}
