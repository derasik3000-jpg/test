//
//  OnboardingPageHost.swift
//  DAYTRACE
//
//  Onboarding page controller
//

import UIKit

final class OnboardingPageHost: UIViewController {
    
    var onComplete: (() -> Void)?
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.isPagingEnabled = true
        sv.showsHorizontalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.numberOfPages = 3
        pc.currentPage = 0
        pc.pageIndicatorTintColor = ColorPalette.surface.withAlphaComponent(0.5)
        pc.currentPageIndicatorTintColor = ColorPalette.primary
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    private let skipButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Skip", for: .normal)
        btn.setTitleColor(ColorPalette.primary, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let startButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("🚀 Start Tracking", for: .normal)
        btn.setTitleColor(ColorPalette.textOnPrimary, for: .normal)
        btn.backgroundColor = ColorPalette.primary
        btn.layer.cornerRadius = 16
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.alpha = 0
        btn.isUserInteractionEnabled = true
        
        // Shadow
        btn.layer.shadowColor = ColorPalette.primary.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowRadius = 12
        btn.layer.shadowOpacity = 0.4
        
        return btn
    }()
    
    private var pages: [OnboardingPage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorPalette.background
        
        // Ensure full screen
        modalPresentationStyle = .fullScreen
        
        setupPages()
        setupUI()
        setupActions()
    }
    
    private func setupPages() {
        let page1 = OnboardingPage(
            emoji: "✨",
            title: "Track Your Day",
            description: "Simple daily actions that shape your lifestyle. Notice what matters most.",
            pageIndex: 0
        )
        
        let page2 = OnboardingPage(
            emoji: "📊",
            title: "See Your Progress",
            description: "Watch your patterns emerge over time. Understand your energy and productivity.",
            pageIndex: 1
        )
        
        let page3 = OnboardingPage(
            emoji: "🎯",
            title: "Build Better Habits",
            description: "Small consistent actions lead to big changes. Start your journey today.",
            pageIndex: 2
        )
        
        pages = [page1, page2, page3]
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        view.addSubview(skipButton)
        view.addSubview(startButton)
        
        // Ensure buttons are on top
        view.bringSubviewToFront(skipButton)
        view.bringSubviewToFront(startButton)
        
        scrollView.delegate = self
        
        NSLayoutConstraint.activate([
            // ScrollView fills entire screen
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // PageControl near bottom
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            
            // Skip button top right
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Start button at bottom
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            startButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        let stackView = UIStackView(arrangedSubviews: pages)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: CGFloat(pages.count))
        ])
    }
    
    private func setupActions() {
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
    }
    
    @objc private func skipTapped() {
        print("🔵 Skip button tapped")
        triggerHaptic()
        TraceStorage.shared.hasCompletedOnboarding = true
        onComplete?()
        print("🔵 onComplete called, hasCompletedOnboarding: \(TraceStorage.shared.hasCompletedOnboarding)")
    }
    
    @objc private func startTapped() {
        print("🟢 Start tracking button tapped")
        triggerHaptic()
        
        // Visual feedback
        UIView.animate(withDuration: 0.1, animations: {
            self.startButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.startButton.transform = .identity
            }
        }
        
        TraceStorage.shared.hasCompletedOnboarding = true
        print("🟢 hasCompletedOnboarding set to: \(TraceStorage.shared.hasCompletedOnboarding)")
        print("🟢 onComplete closure exists: \(onComplete != nil)")
        onComplete?()
        print("🟢 onComplete called")
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            let location = touch.location(in: view)
            print("🔵 Touch at: \(location)")
            print("🔵 Start button frame: \(startButton.frame)")
            print("🔵 Start button alpha: \(startButton.alpha)")
            print("🔵 Start button isHidden: \(startButton.isHidden)")
            print("🔵 Start button isUserInteractionEnabled: \(startButton.isUserInteractionEnabled)")
        }
    }
}

extension OnboardingPageHost: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        
        if pageIndex == 2 {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                self.startButton.alpha = 1
                self.startButton.transform = .identity
                self.skipButton.alpha = 0
            } completion: { _ in
                self.pulseStartButton()
            }
        } else {
            startButton.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.3) {
                self.startButton.alpha = 0
                self.startButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                self.skipButton.alpha = 1
            }
        }
    }
    
    private func pulseStartButton() {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0
        pulse.toValue = 1.05
        pulse.duration = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        startButton.layer.add(pulse, forKey: "pulse")
        
        // Glow animation
        let glow = CABasicAnimation(keyPath: "shadowOpacity")
        glow.fromValue = 0.4
        glow.toValue = 0.8
        glow.duration = 1.0
        glow.autoreverses = true
        glow.repeatCount = .infinity
        glow.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        startButton.layer.add(glow, forKey: "glow")
    }
}
