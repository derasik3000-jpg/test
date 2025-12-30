import UIKit

final class PqOnboardingViewController: UIViewController {
    private let pageControl = UIPageControl()
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let nextButton = PqPrimaryButton()
    
    private var currentPage = 0
    private let pages = 3
    
    // Page 2: Sleep window settings
    private let startTimePicker = UIDatePicker()
    private let endTimePicker = UIDatePicker()
    private let showStatusToggle = UISwitch()
    
    var onComplete: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pqApplyGradientBackdrop()
        pqConstructInterface()
    }
    
    private func pqApplyGradientBackdrop() {
        let gradientView = PqGradientView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(gradientView, at: 0)
        
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func pqConstructInterface() {
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentStackView.axis = .horizontal
        contentStackView.distribution = .fillEqually
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        
        createPage1()
        createPage2()
        createPage3()
        
        pageControl.numberOfPages = pages
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = PqColors.dividerSubtle
        pageControl.currentPageIndicatorTintColor = PqColors.brightTurquoiseAccent
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        
        nextButton.setTitle("Continue", for: .normal)
        nextButton.addTarget(self, action: #selector(pqAdvanceOnboarding), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func createPage1() {
        let page = UIView()
        page.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Evening Closing Ritual"
        titleLabel.font = PqFonts.title2Bold()
        titleLabel.textColor = PqColors.textPrimaryLight
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        page.addSubview(titleLabel)
        
        let iconStack = UIStackView()
        iconStack.axis = .horizontal
        iconStack.spacing = 20
        iconStack.distribution = .fillEqually
        iconStack.translatesAutoresizingMaskIntoConstraints = false
        
        let icons = ["lightbulb.fill", "drop.fill", "iphone.slash"]
        for iconName in icons {
            let iconView = UIImageView(image: UIImage(systemName: iconName))
            iconView.tintColor = PqColors.brightTurquoiseAccent
            iconView.contentMode = .scaleAspectFit
            iconView.widthAnchor.constraint(equalToConstant: 60).isActive = true
            iconView.heightAnchor.constraint(equalToConstant: 60).isActive = true
            iconStack.addArrangedSubview(iconView)
        }
        page.addSubview(iconStack)
        
        let descLabel = UILabel()
        descLabel.text = "Build calm evenings with simple steps"
        descLabel.font = PqFonts.headlineRegular()
        descLabel.textColor = PqColors.textSecondaryFaded
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        page.addSubview(descLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: page.topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: page.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: page.trailingAnchor, constant: -40),
            
            iconStack.centerYAnchor.constraint(equalTo: page.centerYAnchor),
            iconStack.leadingAnchor.constraint(equalTo: page.leadingAnchor, constant: 40),
            iconStack.trailingAnchor.constraint(equalTo: page.trailingAnchor, constant: -40),
            
            descLabel.topAnchor.constraint(equalTo: iconStack.bottomAnchor, constant: 40),
            descLabel.leadingAnchor.constraint(equalTo: page.leadingAnchor, constant: 40),
            descLabel.trailingAnchor.constraint(equalTo: page.trailingAnchor, constant: -40)
        ])
        
        contentStackView.addArrangedSubview(page)
        page.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    private func createPage2() {
        let page = UIView()
        page.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Sleep Window"
        titleLabel.font = PqFonts.title2Bold()
        titleLabel.textColor = PqColors.textPrimaryLight
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        page.addSubview(titleLabel)
        
        let descLabel = UILabel()
        descLabel.text = "Set your ideal bedtime window"
        descLabel.font = PqFonts.headlineRegular()
        descLabel.textColor = PqColors.textSecondaryFaded
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        page.addSubview(descLabel)
        
        // From time picker
        let fromLabel = UILabel()
        fromLabel.text = "From:"
        fromLabel.font = PqFonts.headlineRegular()
        fromLabel.textColor = PqColors.textPrimaryLight
        fromLabel.translatesAutoresizingMaskIntoConstraints = false
        page.addSubview(fromLabel)
        
        startTimePicker.datePickerMode = .time
        startTimePicker.preferredDatePickerStyle = .wheels
        startTimePicker.date = Calendar.current.date(from: DateComponents(hour: 22, minute: 30)) ?? Date()
        if #available(iOS 14.0, *) {
            startTimePicker.tintColor = PqColors.brightTurquoiseAccent
        }
        startTimePicker.translatesAutoresizingMaskIntoConstraints = false
        page.addSubview(startTimePicker)
        
        // To time picker
        let toLabel = UILabel()
        toLabel.text = "To:"
        toLabel.font = PqFonts.headlineRegular()
        toLabel.textColor = PqColors.textPrimaryLight
        toLabel.translatesAutoresizingMaskIntoConstraints = false
        page.addSubview(toLabel)
        
        endTimePicker.datePickerMode = .time
        endTimePicker.preferredDatePickerStyle = .wheels
        endTimePicker.date = Calendar.current.date(from: DateComponents(hour: 23, minute: 30)) ?? Date()
        if #available(iOS 14.0, *) {
            endTimePicker.tintColor = PqColors.brightTurquoiseAccent
        }
        endTimePicker.translatesAutoresizingMaskIntoConstraints = false
        page.addSubview(endTimePicker)
        
        // Toggle for showing status
        let toggleLabel = UILabel()
        toggleLabel.text = "Show window status on Today screen"
        toggleLabel.font = PqFonts.headlineRegular()
        toggleLabel.textColor = PqColors.textPrimaryLight
        toggleLabel.numberOfLines = 0
        toggleLabel.translatesAutoresizingMaskIntoConstraints = false
        page.addSubview(toggleLabel)
        
        showStatusToggle.isOn = true
        showStatusToggle.onTintColor = PqColors.brightTurquoiseAccent
        showStatusToggle.translatesAutoresizingMaskIntoConstraints = false
        page.addSubview(showStatusToggle)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: page.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: page.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: page.trailingAnchor, constant: -40),
            
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descLabel.leadingAnchor.constraint(equalTo: page.leadingAnchor, constant: 40),
            descLabel.trailingAnchor.constraint(equalTo: page.trailingAnchor, constant: -40),
            
            fromLabel.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 30),
            fromLabel.leadingAnchor.constraint(equalTo: page.leadingAnchor, constant: 40),
            
            startTimePicker.topAnchor.constraint(equalTo: fromLabel.bottomAnchor, constant: 8),
            startTimePicker.centerXAnchor.constraint(equalTo: page.centerXAnchor),
            startTimePicker.leadingAnchor.constraint(greaterThanOrEqualTo: page.leadingAnchor, constant: 20),
            startTimePicker.trailingAnchor.constraint(lessThanOrEqualTo: page.trailingAnchor, constant: -20),
            
            toLabel.topAnchor.constraint(equalTo: startTimePicker.bottomAnchor, constant: 16),
            toLabel.leadingAnchor.constraint(equalTo: page.leadingAnchor, constant: 40),
            
            endTimePicker.topAnchor.constraint(equalTo: toLabel.bottomAnchor, constant: 8),
            endTimePicker.centerXAnchor.constraint(equalTo: page.centerXAnchor),
            endTimePicker.leadingAnchor.constraint(greaterThanOrEqualTo: page.leadingAnchor, constant: 20),
            endTimePicker.trailingAnchor.constraint(lessThanOrEqualTo: page.trailingAnchor, constant: -20),
            
            toggleLabel.topAnchor.constraint(equalTo: endTimePicker.bottomAnchor, constant: 24),
            toggleLabel.leadingAnchor.constraint(equalTo: page.leadingAnchor, constant: 40),
            toggleLabel.trailingAnchor.constraint(equalTo: showStatusToggle.leadingAnchor, constant: -12),
            
            showStatusToggle.centerYAnchor.constraint(equalTo: toggleLabel.centerYAnchor),
            showStatusToggle.trailingAnchor.constraint(equalTo: page.trailingAnchor, constant: -40)
        ])
        
        contentStackView.addArrangedSubview(page)
        page.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    private func createPage3() {
        let page = UIView()
        page.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "How to Track"
        titleLabel.font = PqFonts.title2Bold()
        titleLabel.textColor = PqColors.textPrimaryLight
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        page.addSubview(titleLabel)
        
        let descLabel = UILabel()
        descLabel.text = "Check off your ritual steps, rate your calm (0-10), add tags, and build your streak"
        descLabel.font = PqFonts.footnoteRegular()
        descLabel.textColor = PqColors.textSecondaryFaded
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        page.addSubview(descLabel)
        
        // Demo checklist
        let demoSteps = [
            ("lightbulb.fill", "Dim lights"),
            ("drop.fill", "Drink water"),
            ("iphone.slash", "Put phone away")
        ]
        
        let demoStack = UIStackView()
        demoStack.axis = .vertical
        demoStack.spacing = 12
        demoStack.translatesAutoresizingMaskIntoConstraints = false
        page.addSubview(demoStack)
        
        for (icon, title) in demoSteps {
            let stepRow = UIStackView()
            stepRow.axis = .horizontal
            stepRow.spacing = 12
            stepRow.alignment = .center
            
            let checkbox = UIImageView(image: UIImage(systemName: "circle"))
            checkbox.tintColor = PqColors.brightTurquoiseAccent
            checkbox.contentMode = .scaleAspectFit
            checkbox.translatesAutoresizingMaskIntoConstraints = false
            checkbox.widthAnchor.constraint(equalToConstant: 28).isActive = true
            checkbox.heightAnchor.constraint(equalToConstant: 28).isActive = true
            stepRow.addArrangedSubview(checkbox)
            
            let iconView = UIImageView(image: UIImage(systemName: icon))
            iconView.tintColor = PqColors.brightTurquoiseAccent
            iconView.contentMode = .scaleAspectFit
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.widthAnchor.constraint(equalToConstant: 24).isActive = true
            iconView.heightAnchor.constraint(equalToConstant: 24).isActive = true
            stepRow.addArrangedSubview(iconView)
            
            let stepLabel = UILabel()
            stepLabel.text = title
            stepLabel.font = PqFonts.headlineRegular()
            stepLabel.textColor = PqColors.textPrimaryLight
            stepRow.addArrangedSubview(stepLabel)
            
            demoStack.addArrangedSubview(stepRow)
        }
        
        // Demo rating
        let ratingStack = UIStackView()
        ratingStack.axis = .horizontal
        ratingStack.spacing = 8
        ratingStack.alignment = .center
        ratingStack.translatesAutoresizingMaskIntoConstraints = false
        page.addSubview(ratingStack)
        
        let ratingLabel = UILabel()
        ratingLabel.text = "Calm Rating:"
        ratingLabel.font = PqFonts.headlineRegular()
        ratingLabel.textColor = PqColors.textPrimaryLight
        ratingStack.addArrangedSubview(ratingLabel)
        
        let ratingValue = UILabel()
        ratingValue.text = "7"
        ratingValue.font = PqFonts.monospacedDigit(size: 24, weight: .bold)
        ratingValue.textColor = PqColors.brightTurquoiseAccent
        ratingStack.addArrangedSubview(ratingValue)
        
        // Demo tags
        let tagsStack = UIStackView()
        tagsStack.axis = .horizontal
        tagsStack.spacing = 8
        tagsStack.distribution = .fillProportionally
        tagsStack.translatesAutoresizingMaskIntoConstraints = false
        page.addSubview(tagsStack)
        
        for tagName in ["calm", "no screens"] {
            let tagLabel = UILabel()
            tagLabel.text = tagName
            tagLabel.font = PqFonts.footnoteRegular()
            tagLabel.textColor = PqColors.textPrimaryLight
            tagLabel.backgroundColor = PqColors.brightTurquoiseAccent.withAlphaComponent(0.3)
            tagLabel.layer.cornerRadius = 8
            tagLabel.layer.masksToBounds = true
            tagLabel.textAlignment = .center
            tagLabel.translatesAutoresizingMaskIntoConstraints = false
            tagLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
            tagLabel.heightAnchor.constraint(equalToConstant: 28).isActive = true
            tagsStack.addArrangedSubview(tagLabel)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: page.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: page.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: page.trailingAnchor, constant: -40),
            
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descLabel.leadingAnchor.constraint(equalTo: page.leadingAnchor, constant: 40),
            descLabel.trailingAnchor.constraint(equalTo: page.trailingAnchor, constant: -40),
            
            demoStack.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 30),
            demoStack.leadingAnchor.constraint(equalTo: page.leadingAnchor, constant: 40),
            demoStack.trailingAnchor.constraint(equalTo: page.trailingAnchor, constant: -40),
            
            ratingStack.topAnchor.constraint(equalTo: demoStack.bottomAnchor, constant: 24),
            ratingStack.centerXAnchor.constraint(equalTo: page.centerXAnchor),
            
            tagsStack.topAnchor.constraint(equalTo: ratingStack.bottomAnchor, constant: 16),
            tagsStack.centerXAnchor.constraint(equalTo: page.centerXAnchor)
        ])
        
        contentStackView.addArrangedSubview(page)
        page.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    @objc private func pqAdvanceOnboarding() {
        if currentPage < pages - 1 {
            currentPage += 1
            let offset = CGPoint(x: scrollView.frame.width * CGFloat(currentPage), y: 0)
            scrollView.setContentOffset(offset, animated: true)
        } else {
            // Save sleep window settings from page 2
            Task { @MainActor in
                await saveSleepWindowSettings()
                onComplete?()
            }
        }
    }
    
    private func saveSleepWindowSettings() async {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTimePicker.date)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTimePicker.date)
        
        let startHour = startComponents.hour ?? 22
        let startMinute = startComponents.minute ?? 30
        let endHour = endComponents.hour ?? 23
        let endMinute = endComponents.minute ?? 30
        
        do {
            let settingsRepo = PqCoreDataSettingsRepository(context: PqPersistenceController.shared.viewContext)
            let settings = try await settingsRepo.pqRetrieveData()
            let updatedSettings = SettingsDTO(
                defSleepStart: (h: startHour, m: startMinute),
                defSleepEnd: (h: endHour, m: endMinute),
                hapticsEnabled: settings.hapticsEnabled
            )
            try await settingsRepo.pqPersistData(updatedSettings)
        } catch {
            print("Error saving sleep settings: \(error)")
        }
    }
}

extension PqOnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        currentPage = page
        pageControl.currentPage = page
        
        if page == pages - 1 {
            nextButton.setTitle("Start", for: .normal)
        } else {
            nextButton.setTitle("Continue", for: .normal)
        }
    }
}

