//
//  OnboardingContainerViewController.swift
//  PULSE
//
//  Onboarding Container with Paging
//

import UIKit

class OnboardingContainerViewController: UIViewController {
    
    private let pages: [UIViewController]
    private weak var coordinator: IntroPulseCoordinator?
    
    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private let skipButton = UIButton(type: .system)
    private let nextButton = PulseButton(style: .primary, title: "Next")
    
    private var currentPage = 0
    
    init(pages: [UIViewController], coordinator: IntroPulseCoordinator) {
        self.pages = pages
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .pulseBackground
        
        setupScrollView()
        setupPageControl()
        setupButtons()
        setupPages()
    }
    
    // MARK: - Setup
    
    private func setupScrollView() {
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        ])
    }
    
    private func setupButtons() {
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(.pulseTextSecondary, for: .normal)
        skipButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        
        view.addSubview(skipButton)
        view.addSubview(nextButton)
        
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .pulseSurfaceLight
        pageControl.currentPageIndicatorTintColor = .pulsePrimary
        
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupPages() {
        var previousPageView: UIView?
        
        for (index, page) in pages.enumerated() {
            addChild(page)
            scrollView.addSubview(page.view)
            
            page.view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                page.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
                page.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                page.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                page.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
            ])
            
            if let previousView = previousPageView {
                page.view.leadingAnchor.constraint(equalTo: previousView.trailingAnchor).isActive = true
            } else {
                page.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
            }
            
            if index == pages.count - 1 {
                page.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
            }
            
            previousPageView = page.view
            page.didMove(toParent: self)
        }
    }
    
    // MARK: - Actions
    
    @objc private func skipTapped() {
        PulseHaptics.selection()
        coordinator?.skip()
    }
    
    @objc private func nextTapped() {
        PulseHaptics.medium()
        
        if currentPage < pages.count - 1 {
            currentPage += 1
            let offset = CGPoint(x: scrollView.bounds.width * CGFloat(currentPage), y: 0)
            scrollView.setContentOffset(offset, animated: true)
            pageControl.currentPage = currentPage
            updateButtonTitle()
        } else {
            coordinator?.complete()
        }
    }
    
    private func updateButtonTitle() {
        if currentPage == pages.count - 1 {
            nextButton.setTitle("Start tracking", for: .normal)
        } else {
            nextButton.setTitle("Next", for: .normal)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension OnboardingContainerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        guard pageWidth > 0 else { return }
        let page = Int(round(scrollView.contentOffset.x / pageWidth))
        if page != currentPage {
            currentPage = page
            pageControl.currentPage = page
            updateButtonTitle()
        }
    }
}
