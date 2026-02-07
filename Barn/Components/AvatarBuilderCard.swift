//
//  AvatarBuilderCard.swift
//  DAYTRACE
//
//  Emoji avatar builder component
//

import UIKit

final class AvatarBuilderCard: UIView {
    
    var onEmojiSelected: ((String) -> Void)?
    private var selectedEmoji: String = ""
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Avatar"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let currentEmojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 80)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emojiGrid: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let emojis = ["😊", "😎", "🤓", "🥳", "😴", "🤔", "😇", "🤗", "😌", "🙃", "🤩", "😏"]
    
    init() {
        super.init(frame: .zero)
        selectedEmoji = TraceStorage.shared.loadAvatar().emoji
        setupUI()
        currentEmojiLabel.text = selectedEmoji
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = ColorPalette.surface
        layer.cornerRadius = 16
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        addSubview(currentEmojiLabel)
        addSubview(emojiGrid)
        
        emojiGrid.delegate = self
        emojiGrid.dataSource = self
        emojiGrid.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 240),
            
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            currentEmojiLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            currentEmojiLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            emojiGrid.topAnchor.constraint(equalTo: currentEmojiLabel.bottomAnchor, constant: 12),
            emojiGrid.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            emojiGrid.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            emojiGrid.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            emojiGrid.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

extension AvatarBuilderCard: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
        let emoji = emojis[indexPath.item]
        let isSelected = emoji == selectedEmoji
        cell.configure(emoji: emoji, isSelected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emoji = emojis[indexPath.item]
        selectedEmoji = emoji
        currentEmojiLabel.text = emoji
        onEmojiSelected?(emoji)
        
        // Обновить все ячейки для отображения выбранного состояния
        emojiGrid.reloadData()
        
        AnimationKit.springScale(view: currentEmojiLabel)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
