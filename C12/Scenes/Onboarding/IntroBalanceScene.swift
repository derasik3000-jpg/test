//
//  IntroBalanceScene.swift
//  PULSE
//
//  Onboarding Page 3
//

import UIKit

class IntroBalanceScene: UIViewController {
    
    weak var coordinator: IntroPulseCoordinator?
    let pageIndex: Int
    
    private let animationContainer = UIView()
    private let progressBar = UIView()
    private let progressFill = UIView()
    private let budgetIcon = UILabel()
    private let chartLine = CAShapeLayer()
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
        startBudgetAnimation()
    }
    
    private func setupAnimationContainer() {
        view.addSubview(animationContainer)
        animationContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            animationContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            animationContainer.widthAnchor.constraint(equalToConstant: 280),
            animationContainer.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        // Иконка бюджета
        budgetIcon.text = "💰"
        budgetIcon.font = .systemFont(ofSize: 50)
        budgetIcon.textAlignment = .center
        
        animationContainer.addSubview(budgetIcon)
        budgetIcon.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            budgetIcon.topAnchor.constraint(equalTo: animationContainer.topAnchor),
            budgetIcon.centerXAnchor.constraint(equalTo: animationContainer.centerXAnchor)
        ])
        
        // Progress bar container
        progressBar.backgroundColor = .pulseSurface
        progressBar.layer.cornerRadius = 8
        
        animationContainer.addSubview(progressBar)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: budgetIcon.bottomAnchor, constant: 30),
            progressBar.leadingAnchor.constraint(equalTo: animationContainer.leadingAnchor, constant: 20),
            progressBar.trailingAnchor.constraint(equalTo: animationContainer.trailingAnchor, constant: -20),
            progressBar.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        // Progress fill
        progressFill.backgroundColor = .pulsePrimary
        progressFill.layer.cornerRadius = 8
        
        progressBar.addSubview(progressFill)
        progressFill.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            progressFill.topAnchor.constraint(equalTo: progressBar.topAnchor),
            progressFill.leadingAnchor.constraint(equalTo: progressBar.leadingAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressBar.bottomAnchor),
            progressFill.widthAnchor.constraint(equalTo: progressBar.widthAnchor, multiplier: 0)
        ])
        
        // Мини график снизу
        chartLine.strokeColor = UIColor.pulsePrimary.cgColor
        chartLine.fillColor = UIColor.clear.cgColor
        chartLine.lineWidth = 3
        chartLine.lineCap = .round
        
        let chartPath = UIBezierPath()
        chartPath.move(to: CGPoint(x: 20, y: 40))
        chartPath.addLine(to: CGPoint(x: 80, y: 20))
        chartPath.addLine(to: CGPoint(x: 140, y: 35))
        chartPath.addLine(to: CGPoint(x: 200, y: 15))
        chartPath.addLine(to: CGPoint(x: 260, y: 30))
        
        chartLine.path = chartPath.cgPath
        chartLine.strokeEnd = 0
        
        animationContainer.layer.addSublayer(chartLine)
        chartLine.frame = CGRect(x: 0, y: 120, width: 280, height: 60)
    }
    
    private func setupLabels() {
        titleLabel.text = "Stay Within Budget"
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .pulsePrimary
        titleLabel.textAlignment = .center
        
        descriptionLabel.text = "Set a trip budget and track your progress in real-time to avoid overspending"
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
    
    private func startBudgetAnimation() {
        guard !PulseMotion.isReduceMotionEnabled else { return }
        
        // Анимация иконки бюджета
        budgetIcon.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        budgetIcon.alpha = 0
        
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8) {
            self.budgetIcon.alpha = 1.0
            self.budgetIcon.transform = .identity
        }
        
        // Анимация заполнения прогресс-бара
        if let widthConstraint = progressFill.constraints.first(where: { $0.firstAttribute == .width }) {
            progressBar.layoutIfNeeded()
            
            widthConstraint.isActive = false
            
            NSLayoutConstraint.activate([
                progressFill.widthAnchor.constraint(equalTo: progressBar.widthAnchor, multiplier: 0.65)
            ])
            
            UIView.animate(withDuration: 1.5, delay: 0.8, options: [.curveEaseInOut]) {
                self.progressBar.layoutIfNeeded()
            }
        }
        
        // Анимация рисования графика
        let drawAnimation = CABasicAnimation(keyPath: "strokeEnd")
        drawAnimation.fromValue = 0
        drawAnimation.toValue = 1
        drawAnimation.duration = 2.0
        drawAnimation.beginTime = CACurrentMediaTime() + 1.2
        drawAnimation.fillMode = .forwards
        drawAnimation.isRemovedOnCompletion = false
        chartLine.add(drawAnimation, forKey: "draw")
        
        // Пульсация иконки
        UIView.animate(withDuration: 1.0, delay: 1.0, options: [.autoreverse, .repeat]) {
            self.budgetIcon.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }
    }
}
