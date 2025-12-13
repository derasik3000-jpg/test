import Foundation
import SwiftUI
import Combine

@MainActor
class GamingSpawnViewModel: ObservableObject {
    @Published var records: [GamingRecord] = []
    @Published var programs: [GamingProgram] = []
    @Published var iconCount: Int = 0
    @Published var points: Int = 0
    @Published var isLoading: Bool = false
    
    private let recordRepository: GamingRecordRepositoryProtocol
    private let programRepository: GamingProgramRepositoryProtocol
    private let markRepository: GamingMarkRepositoryProtocol
    private let pointsCalculator: GamingPointsCalculator
    
    init(
        recordRepository: GamingRecordRepositoryProtocol,
        programRepository: GamingProgramRepositoryProtocol,
        markRepository: GamingMarkRepositoryProtocol,
        pointsCalculator: GamingPointsCalculator
    ) {
        self.recordRepository = recordRepository
        self.programRepository = programRepository
        self.markRepository = markRepository
        self.pointsCalculator = pointsCalculator
    }
    
    func loadData() {
        isLoading = true
        let allRecords = recordRepository.active()
        let allPrograms = programRepository.active()
        records = allRecords.prefix(5).map { $0 }
        programs = allPrograms.prefix(5).map { $0 }
        iconCount = calculateIconCount(allRecords: allRecords, allPrograms: allPrograms)
        points = pointsCalculator.totalPoints()
        isLoading = false
    }
    
    func refresh() {
        loadData()
    }
    
    private func calculateIconCount(allRecords: [GamingRecord], allPrograms: [GamingProgram]) -> Int {
        let totalMarks = markRepository.totalCount()
        let recordsCount = allRecords.count
        let programsCount = allPrograms.count
        let baseCount = max(8, recordsCount + programsCount)
        let marksBasedCount = max(8, Int(totalMarks) / 5)
        return min(max(baseCount, marksBasedCount), 20)
    }
}

