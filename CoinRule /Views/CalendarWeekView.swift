//
//  CalendarWeekView.swift
//  PULSE
//
//  Visual week calendar with mood colors
//

import UIKit

class CalendarWeekView: UIView {
    
    private var records: [DailyPulseRecord] = []
    private let daysStack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        daysStack.axis = .horizontal
        daysStack.distribution = .fillEqually
        daysStack.spacing = 8
        daysStack.alignment = .fill
        
        addSubview(daysStack)
        daysStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            daysStack.topAnchor.constraint(equalTo: topAnchor),
            daysStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            daysStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            daysStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func configure(with records: [DailyPulseRecord]) {
        self.records = records
        updateDays()
    }
    
    private func updateDays() {
        daysStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let calendar = Calendar.current
        let today = Date()
        
        // Последние 7 дней
        for i in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            
            let dayView = createDayView(for: date)
            daysStack.addArrangedSubview(dayView)
        }
    }
    
    private func createDayView(for date: Date) -> UIView {
        let container = UIView()
        container.layer.cornerRadius = 12
        
        let calendar = Calendar.current
        let dayNumber = calendar.component(.day, from: date)
        let weekday = calendar.component(.weekday, from: date)
        let weekdaySymbol = calendar.shortWeekdaySymbols[weekday - 1]
        
        // Находим запись для этого дня
        let record = records.first { calendar.isDate($0.date, inSameDayAs: date) }
        
        // Определяем цвет на основе настроения
        let bgColor = getDominantBackgroundColor(for: record)
        
        container.backgroundColor = bgColor
        
        let weekdayLabel = UILabel()
        weekdayLabel.text = weekdaySymbol
        weekdayLabel.font = .systemFont(ofSize: 11, weight: .medium)
        weekdayLabel.textColor = .pulseTextSecondary
        weekdayLabel.textAlignment = .center
        
        let dayLabel = UILabel()
        dayLabel.text = "\(dayNumber)"
        dayLabel.font = .systemFont(ofSize: 18, weight: .bold)
        dayLabel.textColor = .pulsePrimary
        dayLabel.textAlignment = .center
        
        let beatsLabel = UILabel()
        if let record = record, !record.beats.isEmpty {
            beatsLabel.text = "\(record.beats.count) beats"
        } else {
            beatsLabel.text = "No beats"
        }
        beatsLabel.font = .systemFont(ofSize: 11, weight: .medium)
        beatsLabel.textColor = .pulseTextSecondary
        beatsLabel.textAlignment = .center
        
        // Emoji для настроения
        let emojiLabel = UILabel()
        if let record = record, !record.beats.isEmpty {
            let cheapCount = record.beats.filter { $0.mood == .cheap }.count
            let expensiveCount = record.beats.filter { $0.mood == .expensive }.count
            
            if cheapCount > expensiveCount && cheapCount > record.beats.count / 2 {
                emojiLabel.text = "💵"
            } else if expensiveCount > cheapCount && expensiveCount > record.beats.count / 2 {
                emojiLabel.text = "💸"
            } else {
                emojiLabel.text = "😐"
            }
        } else {
            emojiLabel.text = "·"
        }
        emojiLabel.font = .systemFont(ofSize: 24)
        emojiLabel.textAlignment = .center
        
        container.addSubview(weekdayLabel)
        container.addSubview(dayLabel)
        container.addSubview(emojiLabel)
        container.addSubview(beatsLabel)
        
        weekdayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        beatsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            weekdayLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            weekdayLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            weekdayLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            
            dayLabel.topAnchor.constraint(equalTo: weekdayLabel.bottomAnchor, constant: 2),
            dayLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            dayLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            
            emojiLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 8),
            emojiLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            beatsLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 4),
            beatsLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            beatsLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            beatsLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])
        
        // Выделяем сегодня
        if calendar.isDateInToday(date) {
            container.layer.borderWidth = 2
            container.layer.borderColor = UIColor.pulsePrimary.cgColor
        }
        
        return container
    }
    
    private func getDominantColor(for record: DailyPulseRecord?) -> UIColor {
        guard let record = record, !record.beats.isEmpty else {
            return .pulseSurface.withAlphaComponent(0.3)
        }
        
        let cheapCount = record.beats.filter { $0.mood == .cheap }.count
        let expensiveCount = record.beats.filter { $0.mood == .expensive }.count
        
        if cheapCount > expensiveCount && cheapCount > record.beats.count / 2 {
            return .pulseCalm
        } else if expensiveCount > cheapCount && expensiveCount > record.beats.count / 2 {
            return .pulseIntense
        } else {
            return .pulseSurface
        }
    }
    
    private func getDominantBackgroundColor(for record: DailyPulseRecord?) -> UIColor {
        guard let record = record, !record.beats.isEmpty else {
            return .pulseSurfaceLight
        }
        
        let cheapCount = record.beats.filter { $0.mood == .cheap }.count
        let expensiveCount = record.beats.filter { $0.mood == .expensive }.count
        
        if cheapCount > expensiveCount && cheapCount > record.beats.count / 2 {
            return .pulseCalm.withAlphaComponent(0.15)
        } else if expensiveCount > cheapCount && expensiveCount > record.beats.count / 2 {
            return .pulseIntense.withAlphaComponent(0.15)
        } else {
            return .pulseSurface.withAlphaComponent(0.15)
        }
    }
}
