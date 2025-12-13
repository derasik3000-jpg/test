import Foundation
import CoreData

extension GamingRecordEntity {
    func toRecord() -> GamingRecord {
        GamingRecord(
            id: id ?? UUID(),
            text: text ?? "",
            recordDate: recordDate,
            imageData: imageData,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }
}

extension GamingProgramEntity {
    func toProgram() -> GamingProgram {
        var steps: [GamingStep] = []
        if let data = stepsData {
            steps = (try? JSONDecoder().decode([GamingStep].self, from: data)) ?? []
        }
        
        return GamingProgram(
            id: id ?? UUID(),
            name: name ?? "",
            steps: steps,
            imageData: imageData,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }
}

extension GamingPlanEntity {
    func toPlan() -> GamingPlan {
        GamingPlan(
            id: id ?? UUID(),
            planDate: planDate ?? Date(),
            planType: planType ?? "",
            refId: refId,
            note: note,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }
}

extension GamingMarkEntity {
    func toMark() -> GamingMark {
        GamingMark(
            id: id ?? UUID(),
            markDate: markDate ?? Date(),
            count: count,
            note: note
        )
    }
}

extension GamingPreferenceEntity {
    func toPreference() -> GamingPreference {
        GamingPreference(
            id: id ?? UUID(),
            iconColorHex: iconColorHex ?? "#6A00FF",
            iconViewType: iconViewType ?? "joystick",
            lastExportDate: lastExportDate
        )
    }
}
