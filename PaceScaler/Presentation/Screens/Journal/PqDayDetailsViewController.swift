import UIKit

final class PqDayDetailsViewController: UIViewController {
    private let day: DayDTO
    private let dayRepo: PqDayRecordRepo
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    var onApplyToToday: ((Date) -> Void)?
    var onUpdate: (() -> Void)?
    
    init(day: DayDTO, dayRepo: PqDayRecordRepo) {
        self.day = day
        self.dayRepo = dayRepo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = PqColors.deepIndigoBase
        title = "Day Details"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Apply to Today", style: .done, target: self, action: #selector(applyToTodayTapped))
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        // Date
        let dateLabel = UILabel()
        dateLabel.font = PqFonts.title2Bold()
        dateLabel.textColor = PqColors.textPrimaryLight
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        dateLabel.text = formatter.string(from: day.date)
        contentStack.addArrangedSubview(dateLabel)
        
        // Sleep window
        let sleepLabel = UILabel()
        sleepLabel.font = PqFonts.headlineRegular()
        sleepLabel.textColor = PqColors.textPrimaryLight
        sleepLabel.text = "Sleep Window: \(String(format: "%02d:%02d – %02d:%02d", day.sleepStart.h, day.sleepStart.m, day.sleepEnd.h, day.sleepEnd.m))"
        contentStack.addArrangedSubview(sleepLabel)
        
        // Steps
        let stepsHeader = UILabel()
        stepsHeader.font = PqFonts.title2Bold()
        stepsHeader.textColor = PqColors.textPrimaryLight
        stepsHeader.text = "Ritual Steps"
        contentStack.addArrangedSubview(stepsHeader)
        
        for step in day.steps.sorted(by: { $0.orderIndex < $1.orderIndex }) {
            let stepRow = UIStackView()
            stepRow.axis = .horizontal
            stepRow.spacing = 12
            stepRow.alignment = .center
            
            let checkbox = UIImageView()
            checkbox.image = UIImage(systemName: step.isDone ? "checkmark.circle.fill" : "circle")
            checkbox.tintColor = step.isDone ? PqColors.brightTurquoiseAccent : PqColors.dividerSubtle
            checkbox.contentMode = .scaleAspectFit
            checkbox.translatesAutoresizingMaskIntoConstraints = false
            checkbox.widthAnchor.constraint(equalToConstant: 28).isActive = true
            checkbox.heightAnchor.constraint(equalToConstant: 28).isActive = true
            stepRow.addArrangedSubview(checkbox)
            
            let stepLabel = UILabel()
            stepLabel.font = PqFonts.headlineRegular()
            stepLabel.textColor = PqColors.textPrimaryLight
            stepLabel.text = step.title
            stepRow.addArrangedSubview(stepLabel)
            
            contentStack.addArrangedSubview(stepRow)
        }
        
        // Rating
        let ratingLabel = UILabel()
        ratingLabel.font = PqFonts.headlineRegular()
        ratingLabel.textColor = PqColors.textPrimaryLight
        ratingLabel.text = "Calm Rating: \(day.rating >= 0 ? "\(day.rating)/10" : "Not rated")"
        contentStack.addArrangedSubview(ratingLabel)
        
        // Tags
        if !day.tags.isEmpty {
            let tagsLabel = UILabel()
            tagsLabel.font = PqFonts.headlineRegular()
            tagsLabel.textColor = PqColors.textPrimaryLight
            tagsLabel.text = "Tags: \(day.tags.map { $0.name }.joined(separator: ", "))"
            tagsLabel.numberOfLines = 0
            contentStack.addArrangedSubview(tagsLabel)
        }
        
        // Note
        if let note = day.note, !note.isEmpty {
            let noteLabel = UILabel()
            noteLabel.font = PqFonts.headlineRegular()
            noteLabel.textColor = PqColors.textPrimaryLight
            noteLabel.text = "Note: \(note)"
            noteLabel.numberOfLines = 0
            contentStack.addArrangedSubview(noteLabel)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func applyToTodayTapped() {
        let alert = UIAlertController(
            title: "Apply to Today?",
            message: "This will copy the ritual steps from this day to today (checkmarks will be reset)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Apply", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.onApplyToToday?(self.day.date)
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}

