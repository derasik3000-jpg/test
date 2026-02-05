//
//  OnboardingViewController.swift
//  Control Rain Watering schedule
//
//  Created by Евгений on 04.02.2026.
//

import UIKit

final class OnboardingViewController: UIViewController {
    
    var onComplete: (() -> Void)?
    
    private var currentPage = 0
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            emoji: "🌾",
            title: "Welcome to Harvest Guardian",
            description: "Manage your irrigation plots with ease and grow healthier crops with smart watering schedules.",
            backgroundColor: FarmPalette.richSoil
        ),
        OnboardingPage(
            emoji: "💧",
            title: "Track Every Drop",
            description: "Log watering sessions, monitor soil conditions, and never miss an irrigation day with our calendar system.",
            backgroundColor: FarmPalette.richSoil
        ),
        OnboardingPage(
            emoji: "📊",
            title: "Grow Your Farm",
            description: "Earn achievements, maintain streaks, and watch your farming skills level up as you care for your fields.",
            backgroundColor: FarmPalette.richSoil
        ),
        OnboardingPage(
            emoji: "🎯",
            title: "Ready to Start?",
            description: "Let's set up your first irrigation plot and begin your journey to becoming a master farmer!",
            backgroundColor: FarmPalette.richSoil
        )
    ]
    
    // MARK: - UI Elements
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.isPagingEnabled = true
        scroll.showsHorizontalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPageIndicatorTintColor = FarmPalette.goldenHarvest
        control.pageIndicatorTintColor = FarmPalette.dustyField
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = FarmTypography.harvest
        button.backgroundColor = FarmPalette.goldenHarvest
        button.setTitleColor(FarmPalette.richSoil, for: .normal)
        button.layer.cornerRadius = FarmRadius.crop
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.titleLabel?.font = FarmTypography.crop
        button.setTitleColor(FarmPalette.goldenHarvest, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPages()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = FarmPalette.richSoil
        
        scrollView.delegate = self
        scrollView.backgroundColor = FarmPalette.richSoil
        
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        view.addSubview(continueButton)
        view.addSubview(skipButton)
        
        pageControl.numberOfPages = pages.count
        
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -FarmSpacing.fieldPadding),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -FarmSpacing.fieldPadding),
            
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: FarmSpacing.acreSpace),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -FarmSpacing.acreSpace),
            continueButton.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -FarmSpacing.rowSpacing),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            
            skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -FarmSpacing.plotMargin)
        ])
    }
    
    private func setupPages() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(stackView)
        
        for page in pages {
            let pageView = createPageView(for: page)
            stackView.addArrangedSubview(pageView)
        }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
        
        for pageView in stackView.arrangedSubviews {
            pageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        }
    }
    
    private func createPageView(for page: OnboardingPage) -> UIView {
        let container = UIView()
        container.backgroundColor = page.backgroundColor
        
        let emojiLabel = UILabel()
        emojiLabel.text = page.emoji
        emojiLabel.font = .systemFont(ofSize: 100)
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = page.title
        titleLabel.font = FarmTypography.silo
        titleLabel.textColor = FarmPalette.goldenHarvest
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = page.description
        descriptionLabel.font = FarmTypography.harvest
        descriptionLabel.textColor = FarmPalette.morningMist
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(emojiLabel)
        container.addSubview(titleLabel)
        container.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -100),
            
            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: FarmSpacing.barnGap),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: FarmSpacing.acreSpace),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -FarmSpacing.acreSpace),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: FarmSpacing.plotMargin),
            descriptionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: FarmSpacing.acreSpace),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -FarmSpacing.acreSpace)
        ])
        
        // Add animation
        emojiLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5) {
            emojiLabel.transform = .identity
        }
        
        return container
    }
    
    // MARK: - Actions
    
    @objc private func continueButtonTapped() {
        if currentPage < pages.count - 1 {
            currentPage += 1
            let offset = CGPoint(x: scrollView.frame.width * CGFloat(currentPage), y: 0)
            scrollView.setContentOffset(offset, animated: true)
            pageControl.currentPage = currentPage
            
            if currentPage == pages.count - 1 {
                continueButton.setTitle("Get Started", for: .normal)
            }
        } else {
            completeOnboarding()
        }
    }
    
    @objc private func skipButtonTapped() {
        completeOnboarding()
    }
    
    private func completeOnboarding() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0
        }) { _ in
            self.onComplete?()
        }
    }
}

// MARK: - UIScrollViewDelegate

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.frame.width > 0 else { return }
        
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        currentPage = Int(pageIndex)
        pageControl.currentPage = currentPage
        
        if currentPage == pages.count - 1 {
            continueButton.setTitle("Get Started", for: .normal)
        } else {
            continueButton.setTitle("Continue", for: .normal)
        }
    }
}

// MARK: - OnboardingPage Model

struct OnboardingPage {
    let emoji: String
    let title: String
    let description: String
    let backgroundColor: UIColor
}
