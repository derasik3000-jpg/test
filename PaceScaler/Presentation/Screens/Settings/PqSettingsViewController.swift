import UIKit

final class PqSettingsViewController: UIViewController {
    private let viewModel: PqSettingsViewModel
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let tableView = UITableView()
    
    init(viewModel: PqSettingsViewModel) {
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
        title = "My"
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        let stepsLabel = UILabel()
        stepsLabel.text = "Ritual Steps"
        stepsLabel.font = PqFonts.title2Bold()
        stepsLabel.textColor = PqColors.textPrimaryLight
        contentStack.addArrangedSubview(stepsLabel)
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        contentStack.addArrangedSubview(tableView)
        
        let addStepButton = PqPrimaryButton()
        addStepButton.setTitle("Add Step", for: .normal)
        addStepButton.addTarget(self, action: #selector(pqInitiateStepCreation), for: .touchUpInside)
        contentStack.addArrangedSubview(addStepButton)
        
        let sleepLabel = UILabel()
        sleepLabel.text = "Default Sleep Window"
        sleepLabel.font = PqFonts.title2Bold()
        sleepLabel.textColor = PqColors.textPrimaryLight
        contentStack.addArrangedSubview(sleepLabel)
        
        let sleepDesc = UILabel()
        sleepDesc.text = "Set your default bedtime window"
        sleepDesc.font = PqFonts.footnoteRegular()
        sleepDesc.textColor = PqColors.textSecondaryFaded
        sleepDesc.numberOfLines = 0
        contentStack.addArrangedSubview(sleepDesc)
        
        let editSleepButton = PqPrimaryButton()
        editSleepButton.setTitle("Edit Sleep Window", for: .normal)
        editSleepButton.addTarget(self, action: #selector(pqLaunchSleepEditor), for: .touchUpInside)
        contentStack.addArrangedSubview(editSleepButton)
        
        let tagsLabel = UILabel()
        tagsLabel.text = "Tags"
        tagsLabel.font = PqFonts.title2Bold()
        tagsLabel.textColor = PqColors.textPrimaryLight
        contentStack.addArrangedSubview(tagsLabel)
        
        // Tags info label
        let tagsInfoLabel = UILabel()
        tagsInfoLabel.font = PqFonts.footnoteRegular()
        tagsInfoLabel.textColor = PqColors.textSecondaryFaded
        tagsInfoLabel.numberOfLines = 0
        contentStack.addArrangedSubview(tagsInfoLabel)
        tagsInfoLabel.text = "You have \(viewModel.tags.filter { !$0.isArchived }.count) active tags"
        
        let addTagButton = PqPrimaryButton()
        addTagButton.setTitle("Add Tag", for: .normal)
        addTagButton.addTarget(self, action: #selector(pqPromptTagCreation), for: .touchUpInside)
        contentStack.addArrangedSubview(addTagButton)
        
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 40).isActive = true
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
        tableView.reloadData()
        
        // Update tags count
        if let tagsInfoLabel = contentStack.arrangedSubviews.compactMap({ $0 as? UILabel }).first(where: { $0.text?.contains("tags") == true }) {
            tagsInfoLabel.text = "You have \(viewModel.tags.filter { !$0.isArchived }.count) active tags (max 20)"
        }
    }
    
    @objc private func pqInitiateStepCreation() {
        // Check max 5 steps
        if viewModel.activeSteps.count >= 5 {
            let alert = UIAlertController(title: "Maximum Reached", message: "You can have maximum 5 ritual steps", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let alert = UIAlertController(title: "Add Step", message: "Create a new ritual step", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Step name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self,
                  let title = alert.textFields?.first?.text,
                  !title.isEmpty else { return }
            let newStep = RitualStepDTO(
                id: UUID(),
                title: title,
                desc: nil,
                iconName: "star.fill",
                orderIndex: self.viewModel.activeSteps.count,
                isArchived: false
            )
            self.viewModel.upsertStep(newStep)
        })
        present(alert, animated: true)
    }
    
    @objc private func pqLaunchSleepEditor() {
        guard let settings = viewModel.settings else { return }
        
        let editor = PqSleepWindowEditor(
            startHour: settings.defSleepStart.h,
            startMinute: settings.defSleepStart.m,
            endHour: settings.defSleepEnd.h,
            endMinute: settings.defSleepEnd.m
        )
        
        editor.onSave = { [weak self] startH, startM, endH, endM in
            let newSettings = SettingsDTO(
                defSleepStart: (h: startH, m: startM),
                defSleepEnd: (h: endH, m: endM),
                hapticsEnabled: settings.hapticsEnabled
            )
            self?.viewModel.saveSettings(newSettings)
        }
        
        if let sheet = editor.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.selectedDetentIdentifier = .large
        }
        
        present(editor, animated: true)
    }
    
    @objc private func pqPromptTagCreation() {
        // Check max 20 tags
        if viewModel.tags.filter({ !$0.isArchived }).count >= 20 {
            let alert = UIAlertController(title: "Maximum Reached", message: "You can have maximum 20 tags", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let alert = UIAlertController(title: "Add Tag", message: "Create a new tag (max 24 characters)", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Tag name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard var name = alert.textFields?.first?.text, !name.isEmpty else { return }
            if name.count > 24 {
                name = String(name.prefix(24))
            }
            self?.viewModel.createTag(name)
        })
        present(alert, animated: true)
    }
}

extension PqSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.activeSteps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let step = viewModel.activeSteps[indexPath.row]
        cell.textLabel?.text = step.title
        cell.textLabel?.textColor = PqColors.textPrimaryLight
        cell.textLabel?.font = PqFonts.headlineRegular()
        
        let iconView = UIImageView(image: UIImage(systemName: step.iconName))
        iconView.tintColor = PqColors.brightTurquoiseAccent
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        cell.accessoryView = iconView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let step = viewModel.activeSteps[indexPath.row]
        
        let alert = UIAlertController(title: "Edit Step", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
            self?.showRenameAlert(for: step)
        })
        
        // Only allow archiving if more than 3 active steps
        if viewModel.activeSteps.count > 3 {
            alert.addAction(UIAlertAction(title: "Archive", style: .destructive) { [weak self] _ in
                self?.viewModel.archiveStep(id: step.id, true)
            })
        } else {
            alert.addAction(UIAlertAction(title: "Archive (min 3 steps required)", style: .default, handler: nil))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showRenameAlert(for step: RitualStepDTO) {
        let alert = UIAlertController(title: "Rename Step", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = step.title
            textField.placeholder = "Step name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let newTitle = alert.textFields?.first?.text, !newTitle.isEmpty else { return }
            let updated = RitualStepDTO(
                id: step.id,
                title: newTitle,
                desc: step.desc,
                iconName: step.iconName,
                orderIndex: step.orderIndex,
                isArchived: step.isArchived
            )
            self?.viewModel.upsertStep(updated)
        })
        present(alert, animated: true)
    }
}

