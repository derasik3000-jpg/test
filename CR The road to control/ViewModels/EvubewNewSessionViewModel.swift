import SwiftUI
import CoreData
import Combine

class EvubewNewSessionViewModel: ObservableObject {
    @Published var cuqavuTitle: String = ""
    @Published var axemobSelectedType: EhonohSessionType = .work
    @Published var degubaStartTime: Date = Date()
    @Published var evubewEndTime: Date = Date().addingTimeInterval(3600)
    @Published var ehonohEnergyLevel: Double = 5
    @Published var axemobMood: Double = 3
    @Published var cuqavuNote: String = ""
    @Published var degubaShowResult = false
    @Published var evubewCreatedSession: AxemobSessionModel?
    @Published var axemobValidationError: String?
    
    private let ehonohCreateSession: EvubewCreateSessionUseCase
    private let axemobCalculateSummary: DegubaCalculateSummaryUseCase
    
    init(context: NSManagedObjectContext = DegubaPersistenceController.shared.container.viewContext, defaultMood: Int16 = 3) {
        self.ehonohCreateSession = EvubewCreateSessionUseCase(context: context)
        self.axemobCalculateSummary = DegubaCalculateSummaryUseCase(context: context)
        self.axemobMood = Double(defaultMood)
        
        // Устанавливаем даты только на текущий день
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        
        // Устанавливаем время начала на текущее время или начало дня
        if let startTime = calendar.date(bySettingHour: calendar.component(.hour, from: now), 
                                         minute: calendar.component(.minute, from: now), 
                                         second: 0, 
                                         of: startOfToday) {
            self.degubaStartTime = startTime
        } else {
            self.degubaStartTime = now
        }
        
        // Устанавливаем время окончания на час позже от начала
        if let endTime = calendar.date(byAdding: .hour, value: 1, to: self.degubaStartTime),
           calendar.isDate(endTime, inSameDayAs: now) {
            self.evubewEndTime = endTime
        } else {
            // Если час позже выходит за пределы дня, устанавливаем на конец дня
            if let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startOfToday) {
                self.evubewEndTime = endOfDay
            } else {
                self.evubewEndTime = now.addingTimeInterval(3600)
            }
        }
    }
    
    func cuqavuSaveSession() -> Bool {
        guard !cuqavuTitle.isEmpty else { return false }
        
        axemobValidationError = nil
        
        // Проверяем, что даты относятся только к текущему дню
        let calendar = Calendar.current
        let today = Date()
        
        if !calendar.isDate(degubaStartTime, inSameDayAs: today) {
            axemobValidationError = "Session can only be created for today"
            return false
        }
        
        if !calendar.isDate(evubewEndTime, inSameDayAs: today) {
            axemobValidationError = "Session can only be created for today"
            return false
        }
        
        if degubaStartTime >= evubewEndTime {
            axemobValidationError = "Start time must be before end time"
            return false
        }
        
        let result = ehonohCreateSession.cuqavuExecute(
            title: cuqavuTitle,
            type: axemobSelectedType,
            startTime: degubaStartTime,
            endTime: evubewEndTime,
            energyLevel: Int16(ehonohEnergyLevel),
            mood: Int16(axemobMood),
            note: cuqavuNote.isEmpty ? nil : cuqavuNote
        )
        
        switch result {
        case .success(let session):
            evubewCreatedSession = session
            _ = axemobCalculateSummary.evubewExecuteForDate(Date())
            NotificationCenter.default.post(name: NSNotification.Name("SessionsUpdated"), object: nil)
            return true
        case .failure:
            return false
        }
    }
    
    func degubaIsFormValid() -> Bool {
        guard !cuqavuTitle.isEmpty else { return false }
        
        if degubaStartTime >= evubewEndTime {
            return false
        }
        
        return true
    }
    
    func ehonohGetValidationHint() -> String? {
        if cuqavuTitle.isEmpty {
            return "Enter a task title to continue"
        }
        
        if degubaStartTime >= evubewEndTime {
            return "Start time must be before end time"
        }
        
        return nil
    }
    
    func degubaResetForm() {
        cuqavuTitle = ""
        axemobSelectedType = .work
        
        // Устанавливаем даты только на текущий день
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        
        if let startTime = calendar.date(bySettingHour: calendar.component(.hour, from: now), 
                                         minute: calendar.component(.minute, from: now), 
                                         second: 0, 
                                         of: startOfToday) {
            degubaStartTime = startTime
        } else {
            degubaStartTime = now
        }
        
        if let endTime = calendar.date(byAdding: .hour, value: 1, to: degubaStartTime),
           calendar.isDate(endTime, inSameDayAs: now) {
            evubewEndTime = endTime
        } else {
            if let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startOfToday) {
                evubewEndTime = endOfDay
            } else {
                evubewEndTime = now.addingTimeInterval(3600)
            }
        }
        
        ehonohEnergyLevel = 5
        axemobMood = 3
        cuqavuNote = ""
        evubewCreatedSession = nil
    }
    
    func evubewGetDuration() -> Int {
        return Int(evubewEndTime.timeIntervalSince(degubaStartTime) / 60)
    }
}

