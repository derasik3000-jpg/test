//
//  ModernTabBar.swift
//  DAYTRACE
//
//  Modern tab bar with glass morphism, smooth animations
//  Compatible with iOS 15 - iOS 26+
//

import UIKit

// MARK: - Modern Tab Bar

final class ModernTabBar: UITabBar {
    
    // MARK: - Properties
    
    private var shapeLayer: CAShapeLayer?
    private var glowLayer: CAGradientLayer?
    
    private let blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemChromeMaterialDark)
        let view = UIVisualEffectView(effect: effect)
        view.clipsToBounds = true
        return view
    }()
    
    private let glassOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        return view
    }()
    
    private let activeIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let indicatorGlow: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.6
        return view
    }()
    
    private var indicatorCenterX: NSLayoutConstraint?
    private var currentIndex: Int = 0
    
    // Customizable accent color
    var accentColor: UIColor = UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0) {
        didSet { updateAccentColor() }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        // Clear default appearance
        backgroundImage = UIImage()
        shadowImage = UIImage()
        backgroundColor = .clear
        isTranslucent = true
        
        // Add blur background
        insertSubview(blurView, at: 0)
        
        // Glass overlay for depth
        blurView.contentView.addSubview(glassOverlay)
        
        // Setup indicator
        setupIndicator()
        
        // Configure item appearance
        configureItemAppearance()
    }
    
    private func setupIndicator() {
        // Glow effect behind indicator
        addSubview(indicatorGlow)
        addSubview(activeIndicator)
        
        // Indicator pill shape
        activeIndicator.backgroundColor = accentColor
        activeIndicator.layer.cornerRadius = 2
        
        // Glow setup
        indicatorGlow.backgroundColor = accentColor
        indicatorGlow.layer.cornerRadius = 10
        
        NSLayoutConstraint.activate([
            activeIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            activeIndicator.heightAnchor.constraint(equalToConstant: 4),
            activeIndicator.widthAnchor.constraint(equalToConstant: 28),
            
            indicatorGlow.centerXAnchor.constraint(equalTo: activeIndicator.centerXAnchor),
            indicatorGlow.centerYAnchor.constraint(equalTo: activeIndicator.centerYAnchor),
            indicatorGlow.widthAnchor.constraint(equalToConstant: 40),
            indicatorGlow.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        indicatorCenterX = activeIndicator.centerXAnchor.constraint(equalTo: leadingAnchor)
        indicatorCenterX?.isActive = true
        
        // Apply blur to glow
        applyGlowEffect()
    }
    
    private func applyGlowEffect() {
        indicatorGlow.layer.shadowColor = accentColor.cgColor
        indicatorGlow.layer.shadowOffset = .zero
        indicatorGlow.layer.shadowRadius = 12
        indicatorGlow.layer.shadowOpacity = 0.8
    }
    
    private func configureItemAppearance() {
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.5)
        ]
        
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .bold),
            .foregroundColor: accentColor
        ]
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.5)
            appearance.stackedLayoutAppearance.selected.iconColor = accentColor
            
            standardAppearance = appearance
            scrollEdgeAppearance = appearance
        }
        
        tintColor = accentColor
        unselectedItemTintColor = UIColor.white.withAlphaComponent(0.5)
    }
    
    private func updateAccentColor() {
        activeIndicator.backgroundColor = accentColor
        indicatorGlow.backgroundColor = accentColor
        applyGlowEffect()
        configureItemAppearance()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Frame updates
        blurView.frame = bounds
        glassOverlay.frame = bounds
        
        // Apply rounded corners
        applyRoundedCorners()
        
        // Update indicator position if needed
        if let items = items, currentIndex < items.count {
            updateIndicatorPosition(to: currentIndex, animated: false)
        }
    }
    
    private func applyRoundedCorners() {
        let cornerRadius: CGFloat = 24
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        
        // Main mask
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        
        // Blur mask
        let blurMask = CAShapeLayer()
        blurMask.path = path.cgPath
        blurView.layer.mask = blurMask
        
        // Top highlight line
        updateTopHighlight(path: path, cornerRadius: cornerRadius)
    }
    
    private func updateTopHighlight(path: UIBezierPath, cornerRadius: CGFloat) {
        // Remove existing
        layer.sublayers?.filter { $0.name == "topHighlight" }.forEach { $0.removeFromSuperlayer() }
        
        let highlight = CAShapeLayer()
        highlight.name = "topHighlight"
        
        let highlightPath = UIBezierPath()
        highlightPath.move(to: CGPoint(x: cornerRadius, y: 0.5))
        highlightPath.addLine(to: CGPoint(x: bounds.width - cornerRadius, y: 0.5))
        
        highlight.path = highlightPath.cgPath
        highlight.strokeColor = UIColor.white.withAlphaComponent(0.15).cgColor
        highlight.lineWidth = 1
        highlight.fillColor = nil
        
        layer.addSublayer(highlight)
    }
    
    // MARK: - Indicator Animation
    
    func updateIndicatorPosition(to index: Int, animated: Bool = true) {
        guard let items = items, index < items.count, bounds.width > 0 else { return }
        
        currentIndex = index
        
        let itemWidth = bounds.width / CGFloat(items.count)
        let centerX = itemWidth * CGFloat(index) + itemWidth / 2
        
        indicatorCenterX?.constant = centerX
        
        if animated {
            // Smooth spring animation
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.3,
                options: [.curveEaseOut],
                animations: {
                    self.layoutIfNeeded()
                }
            )
            
            // Pulse glow
            UIView.animate(withDuration: 0.15, animations: {
                self.indicatorGlow.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                self.indicatorGlow.alpha = 1.0
            }) { _ in
                UIView.animate(withDuration: 0.3) {
                    self.indicatorGlow.transform = .identity
                    self.indicatorGlow.alpha = 0.6
                }
            }
        } else {
            layoutIfNeeded()
        }
    }
    
    // MARK: - Hit Testing
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Extend hit area slightly above tab bar for easier tapping
        let extendedBounds = bounds.inset(by: UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0))
        if extendedBounds.contains(point) {
            return super.hitTest(point, with: event)
        }
        return nil
    }
}

// MARK: - Modern Tab Bar Controller

final class ModernTabBarController: UITabBarController {
    
    private let modernTabBar = ModernTabBar()
    
    var tabBarAccentColor: UIColor {
        get { modernTabBar.accentColor }
        set { modernTabBar.accentColor = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Replace default tab bar
        setValue(modernTabBar, forKey: "tabBar")
        
        delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Initial indicator position
        modernTabBar.updateIndicatorPosition(to: selectedIndex, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Adjust tab bar height
        var frame = tabBar.frame
        let height: CGFloat = 60 + view.safeAreaInsets.bottom
        frame.size.height = height
        frame.origin.y = view.frame.height - height
        tabBar.frame = frame
    }
    
    // Programmatic selection
    func selectTab(_ index: Int, animated: Bool = true) {
        guard let viewControllers = viewControllers, index < viewControllers.count else { return }
        
        selectedIndex = index
        modernTabBar.updateIndicatorPosition(to: index, animated: animated)
    }
}

// MARK: - UITabBarControllerDelegate

extension ModernTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let index = viewControllers?.firstIndex(of: viewController) else { return }
        
        // Update indicator
        modernTabBar.updateIndicatorPosition(to: index, animated: true)
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
        
        // Icon bounce animation
        animateSelectedIcon(at: index)
    }
    
    private func animateSelectedIcon(at index: Int) {
        // Find the tab bar button
        let tabBarButtons = tabBar.subviews.filter { String(describing: type(of: $0)).contains("Button") }
        guard index < tabBarButtons.count else { return }
        
        let button = tabBarButtons[index]
        
        // Bounce animation
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4) {
                button.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.3) {
                button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3) {
                button.transform = .identity
            }
        })
    }
}

// MARK: - Floating Glass Tab Bar (Alternative Style)

final class FloatingGlassTabBar: UIView {
    
    // MARK: - Callback
    
    var onTabSelected: ((Int) -> Void)?
    
    // MARK: - Properties
    
    var accentColor: UIColor = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0) {
        didSet { updateColors() }
    }
    
    private var selectedIndex: Int = 0
    private var tabButtons: [TabButton] = []
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let view = UIVisualEffectView(effect: effect)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 28
        return view
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let selectionBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        return view
    }()
    
    private var selectionLeading: NSLayoutConstraint?
    private var selectionWidth: NSLayoutConstraint?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.addSubview(blurView)
        containerView.addSubview(selectionBackground)
        containerView.addSubview(stackView)
        
        // Selection background styling
        selectionBackground.backgroundColor = accentColor.withAlphaComponent(0.2)
        
        // Container shadow
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        containerView.layer.shadowRadius = 24
        containerView.layer.shadowOpacity = 0.4
        
        // Border
        blurView.layer.borderWidth = 1
        blurView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 56),
            
            blurView.topAnchor.constraint(equalTo: containerView.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4),
            
            selectionBackground.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            selectionBackground.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        selectionLeading = selectionBackground.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8)
        selectionLeading?.isActive = true
        
        selectionWidth = selectionBackground.widthAnchor.constraint(equalToConstant: 60)
        selectionWidth?.isActive = true
    }
    
    // MARK: - Configuration
    
    func configure(tabs: [(icon: String, title: String)]) {
        // Clear existing
        tabButtons.forEach { $0.removeFromSuperview() }
        tabButtons.removeAll()
        
        // Create buttons
        for (index, tab) in tabs.enumerated() {
            let button = TabButton()
            button.configure(icon: tab.icon, title: tab.title)
            button.tag = index
            button.isSelected = index == 0
            button.accentColor = accentColor
            button.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            
            tabButtons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        // Position selection after layout
        DispatchQueue.main.async {
            self.updateSelection(to: 0, animated: false)
        }
    }
    
    // MARK: - Actions
    
    @objc private func tabTapped(_ sender: TabButton) {
        selectTab(at: sender.tag)
        onTabSelected?(sender.tag)
    }
    
    func selectTab(at index: Int, animated: Bool = true) {
        guard index != selectedIndex, index < tabButtons.count else { return }
        
        // Update button states
        tabButtons[selectedIndex].isSelected = false
        tabButtons[index].isSelected = true
        
        selectedIndex = index
        
        updateSelection(to: index, animated: animated)
        
        // Haptic
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func updateSelection(to index: Int, animated: Bool) {
        guard index < tabButtons.count else { return }
        
        layoutIfNeeded()
        
        let button = tabButtons[index]
        let buttonFrame = button.convert(button.bounds, to: containerView)
        
        selectionLeading?.constant = buttonFrame.minX
        selectionWidth?.constant = buttonFrame.width
        
        if animated {
            UIView.animate(
                withDuration: 0.4,
                delay: 0,
                usingSpringWithDamping: 0.75,
                initialSpringVelocity: 0.5,
                options: [],
                animations: {
                    self.layoutIfNeeded()
                }
            )
        } else {
            layoutIfNeeded()
        }
    }
    
    private func updateColors() {
        selectionBackground.backgroundColor = accentColor.withAlphaComponent(0.2)
        tabButtons.forEach { $0.accentColor = accentColor }
    }
}

// MARK: - Tab Button

private final class TabButton: UIControl {
    
    var accentColor: UIColor = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0) {
        didSet { updateAppearance() }
    }
    
    override var isSelected: Bool {
        didSet { updateAppearance() }
    }
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(iconView)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),
            
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 2),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2)
        ])
    }
    
    func configure(icon: String, title: String) {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        iconView.image = UIImage(systemName: icon, withConfiguration: config)
        titleLabel.text = title
        updateAppearance()
    }
    
    private func updateAppearance() {
        let color = isSelected ? accentColor : UIColor.white.withAlphaComponent(0.5)
        
        UIView.animate(withDuration: 0.25) {
            self.iconView.tintColor = color
            self.titleLabel.textColor = color
            self.transform = self.isSelected ? CGAffineTransform(scaleX: 1.05, y: 1.05) : .identity
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = self.isSelected ? CGAffineTransform(scaleX: 1.05, y: 1.05) : .identity
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        UIView.animate(withDuration: 0.1) {
            self.transform = self.isSelected ? CGAffineTransform(scaleX: 1.05, y: 1.05) : .identity
        }
    }
}

// MARK: - Usage Example

/*
 
 // Option 1: Full Tab Bar Controller
 
 let tabBarController = ModernTabBarController()
 tabBarController.tabBarAccentColor = UIColor(red: 0.4, green: 0.8, blue: 0.6, alpha: 1.0)
 
 let homeVC = UINavigationController(rootViewController: HomeViewController())
 homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
 
 let searchVC = UINavigationController(rootViewController: SearchViewController())
 searchVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)
 
 let profileVC = UINavigationController(rootViewController: ProfileViewController())
 profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill"), tag: 2)
 
 tabBarController.viewControllers = [homeVC, searchVC, profileVC]
 
 
 // Option 2: Floating Tab Bar (Custom positioning)
 
 let floatingTabBar = FloatingGlassTabBar()
 floatingTabBar.accentColor = .systemCyan
 view.addSubview(floatingTabBar)
 
 NSLayoutConstraint.activate([
     floatingTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
     floatingTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
     floatingTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
 ])
 
 floatingTabBar.configure(tabs: [
     (icon: "house.fill", title: "Home"),
     (icon: "magnifyingglass", title: "Search"),
     (icon: "heart.fill", title: "Favorites"),
     (icon: "person.fill", title: "Profile")
 ])
 
 floatingTabBar.onTabSelected = { index in
     print("Selected tab: \(index)")
 }
 
 */
