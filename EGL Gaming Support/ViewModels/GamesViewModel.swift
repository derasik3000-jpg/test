import Foundation
import SwiftUI
import Combine

@MainActor
class GamingGamesViewModel: ObservableObject {
    @Published var programs: [GamingProgram] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var showingAddModal: Bool = false
    @Published var editingProgram: GamingProgram?
    @Published var showingProgramMode: Bool = false
    @Published var activeProgram: GamingProgram?
    @Published var currentStepIndex: Int = 0
    
    private let repository: GamingProgramRepositoryProtocol
    private let addUseCase: AddGamingProgramUseCase
    private let markRepository: GamingMarkRepositoryProtocol
    private let pointsCalculator: GamingPointsCalculator
    
    init(
        repository: GamingProgramRepositoryProtocol,
        addUseCase: AddGamingProgramUseCase,
        markRepository: GamingMarkRepositoryProtocol,
        pointsCalculator: GamingPointsCalculator
    ) {
        self.repository = repository
        self.addUseCase = addUseCase
        self.markRepository = markRepository
        self.pointsCalculator = pointsCalculator
    }
    
    func loadPrograms() {
        isLoading = true
        if searchText.isEmpty {
            programs = repository.active()
        } else {
            programs = repository.search(query: searchText)
        }
        isLoading = false
    }
    
    func addProgram(name: String, steps: [GamingStep], imageData: Data? = nil) throws {
        let draft = GamingProgramDraft(name: name, steps: steps, imageData: imageData)
        _ = try addUseCase.execute(draft)
        pointsCalculator.addPoints(for: .addProgram)
        loadPrograms()
    }
    
    func updateProgram(_ program: GamingProgram, name: String, steps: [GamingStep], imageData: Data? = nil) throws {
        let draft = GamingProgramDraft(name: name, steps: steps, imageData: imageData)
        _ = try repository.update(program.id, with: draft)
        loadPrograms()
    }
    
    func deleteProgram(_ program: GamingProgram) throws {
        try repository.delete(program.id)
        loadPrograms()
    }
    
    func startEdit(_ program: GamingProgram) {
        editingProgram = program
        showingAddModal = true
    }
    
    func startProgram(_ program: GamingProgram) {
        activeProgram = program
        currentStepIndex = 0
        showingProgramMode = true
    }
    
    func completeCurrentStep() {
        guard var program = activeProgram else { return }
        
        if currentStepIndex < program.steps.count {
            program.steps[currentStepIndex].completed = true
            
            do {
                let draft = GamingProgramDraft(name: program.name, steps: program.steps, imageData: program.imageData)
                _ = try repository.update(program.id, with: draft)
                pointsCalculator.addPoints(for: .completeStep)
                _ = try markRepository.upsert(date: Date(), delta: 1, note: "Completed step in \(program.name)")
                
                activeProgram = program
                
                if currentStepIndex < program.steps.count - 1 {
                    currentStepIndex += 1
                } else {
                    showingProgramMode = false
                    loadPrograms()
                }
            } catch {
                print("Error completing step: \(error)")
            }
        }
    }
    
    func skipStep() {
        if currentStepIndex < (activeProgram?.steps.count ?? 0) - 1 {
            currentStepIndex += 1
        } else {
            showingProgramMode = false
        }
    }
}

