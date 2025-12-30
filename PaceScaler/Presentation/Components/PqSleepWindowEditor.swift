import UIKit

final class PqSleepWindowEditor: UIViewController {
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let startTimePicker = UIDatePicker()
    private let endTimePicker = UIDatePicker()
    private let saveButton = PqPrimaryButton()
    private let cancelButton = UIButton(type: .system)
    
    private var startHour: Int
    private var startMinute: Int
    private var endHour: Int
    private var endMinute: Int
    
    var onSave: ((Int, Int, Int, Int) -> Void)?
    
    init(startHour: Int, startMinute: Int, endHour: Int, endMinute: Int) {
        self.startHour = startHour
        self.startMinute = startMinute
        self.endHour = endHour
        self.endMinute = endMinute
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pqArrangeEditorLayout()
    }
    
    private func pqArrangeEditorLayout() {
        view.backgroundColor = PqColors.deepIndigoBase
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        let titleLabel = UILabel()
        titleLabel.text = "Sleep Window"
        titleLabel.font = PqFonts.title2Bold()
        titleLabel.textColor = PqColors.textPrimaryLight
        titleLabel.textAlignment = .center
        contentStack.addArrangedSubview(titleLabel)
        
        let startLabel = UILabel()
        startLabel.text = "Start Time"
        startLabel.font = PqFonts.headlineRegular()
        startLabel.textColor = PqColors.textPrimaryLight
        contentStack.addArrangedSubview(startLabel)
        
        startTimePicker.datePickerMode = .time
        startTimePicker.preferredDatePickerStyle = .wheels
        if #available(iOS 14.0, *) {
            startTimePicker.tintColor = PqColors.brightTurquoiseAccent
        }
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = startHour
        components.minute = startMinute
        if let startDate = calendar.date(from: components) {
            startTimePicker.date = startDate
        }
        startTimePicker.addTarget(self, action: #selector(startTimeChanged), for: .valueChanged)
        contentStack.addArrangedSubview(startTimePicker)
        
        let endLabel = UILabel()
        endLabel.text = "End Time"
        endLabel.font = PqFonts.headlineRegular()
        endLabel.textColor = PqColors.textPrimaryLight
        contentStack.addArrangedSubview(endLabel)
        
        endTimePicker.datePickerMode = .time
        endTimePicker.preferredDatePickerStyle = .wheels
        if #available(iOS 14.0, *) {
            endTimePicker.tintColor = PqColors.brightTurquoiseAccent
        }
        components.hour = endHour
        components.minute = endMinute
        if let endDate = calendar.date(from: components) {
            endTimePicker.date = endDate
        }
        endTimePicker.addTarget(self, action: #selector(endTimeChanged), for: .valueChanged)
        contentStack.addArrangedSubview(endTimePicker)
        
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 20).isActive = true
        contentStack.addArrangedSubview(spacer)
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(pqConfirmChanges), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveButton)
        
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(PqColors.textSecondaryFaded, for: .normal)
        cancelButton.titleLabel?.font = PqFonts.headlineRegular()
        cancelButton.addTarget(self, action: #selector(pqDismissEditor), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -16),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -12),
            
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func startTimeChanged() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: startTimePicker.date)
        startHour = components.hour ?? 22
        startMinute = components.minute ?? 30
    }
    
    @objc private func endTimeChanged() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: endTimePicker.date)
        endHour = components.hour ?? 23
        endMinute = components.minute ?? 30
    }
    
    @objc private func pqConfirmChanges() {
        onSave?(startHour, startMinute, endHour, endMinute)
        dismiss(animated: true)
    }
    
    @objc private func pqDismissEditor() {
        dismiss(animated: true)
    }
}

