import Foundation
import SwiftUI
import Combine

@MainActor
class GamingIdeasViewModel: ObservableObject {
    @Published var records: [GamingRecord] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var showingAddModal: Bool = false
    @Published var editingRecord: GamingRecord?
    
    private let repository: GamingRecordRepositoryProtocol
    private let addUseCase: AddGamingRecordUseCase
    private let pointsCalculator: GamingPointsCalculator
    
    init(
        repository: GamingRecordRepositoryProtocol,
        addUseCase: AddGamingRecordUseCase,
        pointsCalculator: GamingPointsCalculator
    ) {
        self.repository = repository
        self.addUseCase = addUseCase
        self.pointsCalculator = pointsCalculator
    }
    
    func loadRecords() {
        isLoading = true
        if searchText.isEmpty {
            records = repository.active()
        } else {
            records = repository.search(query: searchText)
        }
        isLoading = false
    }
    
    func addRecord(text: String, date: Date?, imageData: Data? = nil) throws {
        let draft = GamingRecordDraft(text: text, recordDate: date, imageData: imageData)
        _ = try addUseCase.execute(draft)
        pointsCalculator.addPoints(for: .addRecord)
        loadRecords()
    }
    
    func updateRecord(_ record: GamingRecord, text: String, date: Date?, imageData: Data? = nil) throws {
        let draft = GamingRecordDraft(text: text, recordDate: date, imageData: imageData)
        _ = try repository.update(record.id, with: draft)
        loadRecords()
    }
    
    func deleteRecord(_ record: GamingRecord) throws {
        try repository.delete(record.id)
        loadRecords()
    }
    
    func startEdit(_ record: GamingRecord) {
        editingRecord = record
        showingAddModal = true
    }
}
