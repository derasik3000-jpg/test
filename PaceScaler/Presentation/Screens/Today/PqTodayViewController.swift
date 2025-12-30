import UIKit

final class PqTodayViewController: UIViewController {
    private let viewModel: PqTodayViewModel
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    private let dateLabel = UILabel()
    private let sleepWindowCard = PqSleepWindowCard()
    private let donutView = PqRitualDonutView()
    private let tableView = UITableView()
    private let ratingLabel = UILabel()
    private let ratingStepper = UIStepper()
    private let ratingValueLabel = UILabel()
    private let tagsStack = UIStackView()
    private let noteTextView = UITextView()
    private let closeButton = PqPrimaryButton()
    
    private var currentRating = -1
    private var selectedTagIDs: Set<UUID> = []
    
    init(viewModel: PqTodayViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pqApplyGradientBackdrop()
        pqConstructInterface()
        pqAttachDataSource()
        viewModel.pqDidBecomeVisible()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: PqColors.textPrimaryLight
        ]
        navigationController?.navigationBar.barTintColor = PqColors.deepIndigoBase
        
        viewModel.pqDidBecomeVisible()
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
        title = "Today"
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        dateLabel.font = PqFonts.title2Bold()
        dateLabel.textColor = PqColors.textPrimaryLight
        dateLabel.textAlignment = .center
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateLabel.text = formatter.string(from: Date())
        contentStack.addArrangedSubview(dateLabel)
        
        sleepWindowCard.translatesAutoresizingMaskIntoConstraints = false
        sleepWindowCard.heightAnchor.constraint(equalToConstant: 60).isActive = true
        sleepWindowCard.onTap = { [weak self] in
            self?.pqPresentTimeEditor()
        }
        contentStack.addArrangedSubview(sleepWindowCard)
        
        donutView.translatesAutoresizingMaskIntoConstraints = false
        donutView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        contentStack.addArrangedSubview(donutView)
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PqCheckboxCell.self, forCellReuseIdentifier: PqCheckboxCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        contentStack.addArrangedSubview(tableView)
        
        ratingLabel.text = "Calm rating (0-10)"
        ratingLabel.font = PqFonts.headlineRegular()
        ratingLabel.textColor = PqColors.textPrimaryLight
        contentStack.addArrangedSubview(ratingLabel)
        
        let ratingContainer = UIStackView()
        ratingContainer.axis = .horizontal
        ratingContainer.spacing = 12
        ratingContainer.alignment = .center
        
        ratingStepper.minimumValue = 0
        ratingStepper.maximumValue = 10
        ratingStepper.value = 0
        ratingStepper.addTarget(self, action: #selector(pqCalmRatingDidChange), for: .valueChanged)
        ratingContainer.addArrangedSubview(ratingStepper)
        
        ratingValueLabel.text = "0"
        ratingValueLabel.font = PqFonts.monospacedDigit(size: 24, weight: .bold)
        ratingValueLabel.textColor = PqColors.textPrimaryLight
        ratingContainer.addArrangedSubview(ratingValueLabel)
        
        contentStack.addArrangedSubview(ratingContainer)
        
        let tagsLabel = UILabel()
        tagsLabel.text = "Tags"
        tagsLabel.font = PqFonts.headlineRegular()
        tagsLabel.textColor = PqColors.textPrimaryLight
        contentStack.addArrangedSubview(tagsLabel)
        
        tagsStack.axis = .horizontal
        tagsStack.spacing = 8
        tagsStack.distribution = .fillProportionally
        contentStack.addArrangedSubview(tagsStack)
        
        let noteLabel = UILabel()
        noteLabel.text = "Note (up to 140 chars)"
        noteLabel.font = PqFonts.headlineRegular()
        noteLabel.textColor = PqColors.textPrimaryLight
        contentStack.addArrangedSubview(noteLabel)
        
        noteTextView.backgroundColor = PqColors.deepIndigoBase.withAlphaComponent(0.3)
        noteTextView.textColor = PqColors.textPrimaryLight
        noteTextView.font = PqFonts.headlineRegular()
        noteTextView.layer.cornerRadius = 8
        noteTextView.layer.borderWidth = 1
        noteTextView.layer.borderColor = PqColors.dividerSubtle.cgColor
        noteTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        noteTextView.delegate = self
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        noteTextView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        contentStack.addArrangedSubview(noteTextView)
        
        closeButton.setTitle("Close Day", for: .normal)
        closeButton.addTarget(self, action: #selector(pqFinalizeDayEntry), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(closeButton)
        
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 20).isActive = true
        contentStack.addArrangedSubview(spacer)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
    
    private func pqAttachDataSource() {
        viewModel.onUpdate = { [weak self] in
            self?.pqSynchronizeDisplay()
        }
    }
    
    private func pqSynchronizeDisplay() {
        donutView.data = viewModel.donut
        
        if let day = viewModel.day {
            let window = PqSleepWindow(startHour: day.sleepStart.h, startMinute: day.sleepStart.m, endHour: day.sleepEnd.h, endMinute: day.sleepEnd.m)
            sleepWindowCard.pqApplyData(startHour: day.sleepStart.h, startMin: day.sleepStart.m, endHour: day.sleepEnd.h, endMin: day.sleepEnd.m, status: window.pqCalculateWindowPhase(at: Date()))
            
            if day.rating >= 0 {
                ratingStepper.value = Double(day.rating)
                ratingValueLabel.text = "\(day.rating)"
                currentRating = day.rating
            }
            
            noteTextView.text = day.note
            
            selectedTagIDs = Set(day.tags.map { $0.id })
        }
        
        pqRepaintTagsSection()
        tableView.reloadData()
    }
    
    private func pqRepaintTagsSection() {
        tagsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for tag in viewModel.availableTags.prefix(5) {
            let chip = PqTagChipView(text: tag.name)
            chip.pqApplySelectionState(selectedTagIDs.contains(tag.id))
            chip.onTap = { [weak self] in
                self?.pqSwitchTagState(tag.id)
            }
            tagsStack.addArrangedSubview(chip)
        }
    }
    
    private func pqSwitchTagState(_ tagID: UUID) {
        if selectedTagIDs.contains(tagID) {
            selectedTagIDs.remove(tagID)
        } else {
            if selectedTagIDs.count < 5 {
                selectedTagIDs.insert(tagID)
            }
        }
        viewModel.updateTags(Array(selectedTagIDs))
        pqRepaintTagsSection()
    }
    
    @objc private func pqCalmRatingDidChange() {
        let value = Int(ratingStepper.value)
        ratingValueLabel.text = "\(value)"
        currentRating = value
        viewModel.updateRating(value)
    }
    
    @objc private func pqFinalizeDayEntry() {
        if currentRating < 0 {
            let alert = UIAlertController(title: "No rating", message: "Close day without rating?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Add rating", style: .cancel))
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.viewModel.closeDay()
            })
            present(alert, animated: true)
        } else {
            viewModel.closeDay()
            PqHapticEngine.shared.pqEmitPositiveFeedback()
        }
    }
    
    private func pqPresentTimeEditor() {
        guard let day = viewModel.day else { return }
        
        let editor = PqSleepWindowEditor(
            startHour: day.sleepStart.h,
            startMinute: day.sleepStart.m,
            endHour: day.sleepEnd.h,
            endMinute: day.sleepEnd.m
        )
        
        editor.onSave = { [weak self] startH, startM, endH, endM in
            self?.viewModel.updateSleep(start: (startH, startM), end: (endH, endM))
        }
        
        if let sheet = editor.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.selectedDetentIdentifier = .large
        }
        
        present(editor, animated: true)
    }
}

extension PqTodayViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.day?.steps.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PqCheckboxCell.identifier, for: indexPath) as? PqCheckboxCell,
              let step = viewModel.day?.steps[indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.pqApplyData(title: step.title, desc: nil, icon: step.iconName, isDone: step.isDone)
        cell.onToggle = { [weak self] isDone in
            self?.viewModel.toggle(stepID: step.id, isDone: isDone)
        }
        
        return cell
    }
}

extension PqTodayViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 140 {
            textView.text = String(textView.text.prefix(140))
        }
        viewModel.updateNote(textView.text)
    }
}

