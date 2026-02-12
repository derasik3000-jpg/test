//
//  IntroMomentsScene.swift
//  PULSE
//
//  Onboarding Page 2
//

import UIKit

class IntroMomentsScene: UIViewController {
    
    weak var coordinator: IntroPulseCoordinator?
    let pageIndex: Int
    
    private let animationContainer = UIView()
    private var moodViews: [UILabel] = []
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
        startMoodAnimation()
    }
    
    private func setupAnimationContainer() {
        view.addSubview(animationContainer)
        animationContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            animationContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            animationContainer.widthAnchor.constraint(equalToConstant: 250),
            animationContainer.heightAnchor.constraint(equalToConstant: 250)
        ])
        
        // Создаём три emoji для цен
        let priceEmojis = ["💵", "💰", "💸"]
        let colors: [UIColor] = [.pulseCalm, .pulsePrimary, .pulseIntense]
        
        for i in 0..<3 {
            let moodView = UILabel()
            moodView.text = priceEmojis[i]
            moodView.font = .systemFont(ofSize: 60)
            moodView.textAlignment = .center
            moodView.alpha = 0
            moodView.layer.shadowColor = colors[i].cgColor
            moodView.layer.shadowRadius = 20
            moodView.layer.shadowOpacity = 0.6
            moodView.layer.shadowOffset = .zero
            
            animationContainer.addSubview(moodView)
            moodView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                moodView.centerXAnchor.constraint(equalTo: animationContainer.centerXAnchor),
                moodView.centerYAnchor.constraint(equalTo: animationContainer.centerYAnchor)
            ])
            
            moodViews.append(moodView)
        }
    }
    
    private func setupLabels() {
        titleLabel.text = "Rate Your Purchases"
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .pulsePrimary
        titleLabel.textAlignment = .center
        
        descriptionLabel.text = "Mark each expense as Cheap, Normal, or Expensive to understand your spending perception"
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
    
    private func startMoodAnimation() {
        guard !PulseMotion.isReduceMotionEnabled else { return }
        
        // Анимация смены emoji (дешево -> нормально -> дорого)
        var currentIndex = 0
        
        func showNextMood() {
            // Скрываем предыдущий
            if currentIndex > 0 {
                UIView.animate(withDuration: 0.3) {
                    self.moodViews[currentIndex - 1].alpha = 0
                    self.moodViews[currentIndex - 1].transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                }
            }
            
            // Показываем текущий
            let currentMood = moodViews[currentIndex]
            currentMood.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            
            UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: []) {
                currentMood.alpha = 1.0
                currentMood.transform = .identity
            }
            
            // Пульсация
            UIView.animate(withDuration: 0.8, delay: 0.7, options: [.autoreverse, .repeat]) {
                currentMood.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
            
            currentIndex = (currentIndex + 1) % moodViews.count
            
            // Следующий через 2 секунды
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                showNextMood()
            }
        }
        
        showNextMood()
    }
}
