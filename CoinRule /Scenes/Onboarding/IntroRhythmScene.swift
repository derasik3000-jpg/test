//
//  IntroRhythmScene.swift
//  PULSE
//
//  Onboarding Page 1
//

import UIKit

class IntroRhythmScene: UIViewController {
    
    weak var coordinator: IntroPulseCoordinator?
    let pageIndex: Int
    
    private let animationContainer = UIView()
    private var coinViews: [UILabel] = []
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    init(coordinator: IntroPulseCoordinator, pageIndex: Int) {
        self.coordinator = coordinator
        self.pageIndex = pageIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        setupAnimationContainer()
        setupLabels()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCoinAnimation()
    }
    
    private func setupAnimationContainer() {
        view.addSubview(animationContainer)
        animationContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            animationContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            animationContainer.widthAnchor.constraint(equalToConstant: 200),
            animationContainer.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        // Создаём монеты разных типов
        let coinEmojis = ["💵", "💰", "💸", "💴", "💶", "💷"]
        
        for i in 0..<6 {
            let coin = UILabel()
            coin.text = coinEmojis[i]
            coin.font = .systemFont(ofSize: 40)
            coin.textAlignment = .center
            coin.alpha = 0
            
            animationContainer.addSubview(coin)
            coin.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                coin.centerXAnchor.constraint(equalTo: animationContainer.centerXAnchor),
                coin.centerYAnchor.constraint(equalTo: animationContainer.centerYAnchor)
            ])
            
            coinViews.append(coin)
        }
    }
    
    private func setupLabels() {
        titleLabel.text = "Track Your Spending"
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .pulsePrimary
        titleLabel.textAlignment = .center
        
        descriptionLabel.text = "Keep a detailed journal of your travel expenses and discover your spending patterns"
        descriptionLabel.font = .systemFont(ofSize: 17, weight: .regular)
        descriptionLabel.textColor = .pulseTextSecondary
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: animationContainer.bottomAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func startCoinAnimation() {
        guard !PulseMotion.isReduceMotionEnabled else { return }
        
        // Анимация монет по кругу
        let radius: CGFloat = 80
        let angleStep = (2 * .pi) / CGFloat(coinViews.count)
        
        for (index, coin) in coinViews.enumerated() {
            let angle = angleStep * CGFloat(index)
            let delay = Double(index) * 0.15
            
            // Появление с задержкой
            UIView.animate(withDuration: 0.5, delay: delay, options: [.curveEaseOut]) {
                coin.alpha = 1.0
            }
            
            // Вращение по кругу
            UIView.animate(withDuration: 3.0, delay: delay, options: [.repeat, .curveLinear]) {
                let x = cos(angle) * radius
                let y = sin(angle) * radius
                coin.transform = CGAffineTransform(translationX: x, y: y)
            }
            
            // Пульсация размера
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.fromValue = 1.0
            scaleAnimation.toValue = 1.2
            scaleAnimation.duration = 1.0
            scaleAnimation.autoreverses = true
            scaleAnimation.repeatCount = .infinity
            scaleAnimation.beginTime = CACurrentMediaTime() + delay
            coin.layer.add(scaleAnimation, forKey: "scale")
        }
    }
}
