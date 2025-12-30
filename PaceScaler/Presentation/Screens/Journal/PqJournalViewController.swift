import UIKit

final class PqJournalViewController: UIViewController {
    private let viewModel: PqJournalViewModel
    private let segmentControl = UISegmentedControl(items: ["Week", "Month"])
    private let weekBarsView = PqWeekBarsView()
    private let tableView = UITableView()
    
    // Month view
    private var monthCollectionView: UICollectionView!
    
    init(viewModel: PqJournalViewModel) {
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
        title = "Journal"
        
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(pqTimeframeSegmentSwitched), for: .valueChanged)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentControl)
        
        // Week view
        weekBarsView.translatesAutoresizingMaskIntoConstraints = false
        weekBarsView.onBarTap = { [weak self] date in
            self?.viewModel.openDay(date)
            self?.pqDisplayDayInspector()
        }
        view.addSubview(weekBarsView)
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Month view
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        let cellWidth = (UIScreen.main.bounds.width - 60) / 7
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        
        monthCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        monthCollectionView.backgroundColor = .clear
        monthCollectionView.delegate = self
        monthCollectionView.dataSource = self
        monthCollectionView.register(MonthDayCell.self, forCellWithReuseIdentifier: "MonthDayCell")
        monthCollectionView.translatesAutoresizingMaskIntoConstraints = false
        monthCollectionView.isHidden = true
        view.addSubview(monthCollectionView)
        
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            weekBarsView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 20),
            weekBarsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            weekBarsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            weekBarsView.heightAnchor.constraint(equalToConstant: 200),
            
            tableView.topAnchor.constraint(equalTo: weekBarsView.bottomAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            monthCollectionView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 20),
            monthCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            monthCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            monthCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func pqAttachDataSource() {
        viewModel.onUpdate = { [weak self] in
            self?.pqSynchronizeDisplay()
        }
    }
    
    private func pqSynchronizeDisplay() {
        weekBarsView.data = viewModel.week
        tableView.reloadData()
    }
    
    @objc private func pqTimeframeSegmentSwitched() {
        let isWeek = segmentControl.selectedSegmentIndex == 0
        
        UIView.transition(with: view, duration: 0.16, options: .transitionCrossDissolve) {
            self.weekBarsView.isHidden = !isWeek
            self.tableView.isHidden = !isWeek
            self.monthCollectionView.isHidden = isWeek
        }
        
        if !isWeek {
            monthCollectionView.reloadData()
        }
    }
    
    private func pqDisplayDayInspector() {
        guard let day = viewModel.selectedDay else { return }
        
        let dayRepo = PqCoreDataDayRepository(context: PqPersistenceController.shared.viewContext)
        let detailsVC = PqDayDetailsViewController(day: day, dayRepo: dayRepo)
        detailsVC.onApplyToToday = { [weak self] date in
            self?.viewModel.applyFromDayToToday(date)
        }
        detailsVC.onUpdate = { [weak self] in
            self?.viewModel.pqDidBecomeVisible()
        }
        
        let navController = UINavigationController(rootViewController: detailsVC)
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(navController, animated: true)
    }
}

extension PqJournalViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.week.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let item = viewModel.week.items[indexPath.row]
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        
        cell.textLabel?.text = "\(formatter.string(from: item.date)) - \(Int(item.ratio * 100))%"
        cell.textLabel?.textColor = PqColors.textPrimaryLight
        cell.textLabel?.font = PqFonts.headlineRegular()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let date = viewModel.week.items[indexPath.row].date
        viewModel.openDay(date)
        pqDisplayDayInspector()
    }
}

extension PqJournalViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 35 cells (5 weeks max) or 42 (6 weeks)
        return 35
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthDayCell", for: indexPath) as! MonthDayCell
        
        let calendar = Calendar.current
        let today = Date()
        guard let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)),
              let firstWeekday = calendar.dateComponents([.weekday], from: firstOfMonth).weekday else {
            cell.configure(day: nil, status: .empty)
            return cell
        }
        
        let offset = indexPath.row - (firstWeekday - 1)
        if offset < 0 {
            cell.configure(day: nil, status: .empty)
            return cell
        }
        
        guard let dayDate = calendar.date(byAdding: .day, value: offset, to: firstOfMonth),
              calendar.component(.month, from: dayDate) == calendar.component(.month, from: today) else {
            cell.configure(day: nil, status: .empty)
            return cell
        }
        
        let day = calendar.component(.day, from: dayDate)
        
        // Check if day has data (simplified: check if in week.items)
        let hasData = viewModel.week.items.contains { calendar.isDate($0.date, inSameDayAs: dayDate) }
        if hasData {
            let item = viewModel.week.items.first { calendar.isDate($0.date, inSameDayAs: dayDate) }
            let status: MonthDayCell.DayStatus = item?.isCalm == true ? .calm : .partial
            cell.configure(day: day, status: status)
        } else {
            cell.configure(day: day, status: .empty)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let calendar = Calendar.current
        let today = Date()
        guard let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)),
              let firstWeekday = calendar.dateComponents([.weekday], from: firstOfMonth).weekday else {
            return
        }
        
        let offset = indexPath.row - (firstWeekday - 1)
        if offset < 0 { return }
        
        guard let dayDate = calendar.date(byAdding: .day, value: offset, to: firstOfMonth),
              calendar.component(.month, from: dayDate) == calendar.component(.month, from: today) else {
            return
        }
        
        viewModel.openDay(dayDate)
        pqDisplayDayInspector()
    }
}

// Month Calendar Cell
private class MonthDayCell: UICollectionViewCell {
    enum DayStatus {
        case empty, partial, calm
    }
    
    private let dayLabel = UILabel()
    private let indicator = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 8
        contentView.backgroundColor = PqColors.deepIndigoBase.withAlphaComponent(0.3)
        
        dayLabel.font = PqFonts.headlineRegular()
        dayLabel.textColor = PqColors.textPrimaryLight
        dayLabel.textAlignment = .center
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dayLabel)
        
        indicator.layer.cornerRadius = 4
        indicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -4),
            
            indicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            indicator.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 2),
            indicator.widthAnchor.constraint(equalToConstant: 8),
            indicator.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    func configure(day: Int?, status: DayStatus) {
        if let day = day {
            dayLabel.text = "\(day)"
            dayLabel.alpha = 1.0
            
            switch status {
            case .empty:
                indicator.isHidden = true
            case .partial:
                indicator.isHidden = false
                indicator.backgroundColor = PqColors.brightTurquoiseAccent
            case .calm:
                indicator.isHidden = false
                indicator.backgroundColor = PqColors.successLeafGreen
            }
        } else {
            dayLabel.text = ""
            dayLabel.alpha = 0.3
            indicator.isHidden = true
        }
    }
}

