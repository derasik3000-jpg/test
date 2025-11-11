import Foundation
import SwiftUI
import Combine

class PartyflowViewModel: ObservableObject {
    @Published var currentPhazor: GamePhazor = .setupLaunch
    @Published var selectedDeckzi: DeckziType = .eitherOr
    @Published var playerCountzValue: Int = 4
    @Published var totalRoundzLimit: Int = 5
    @Published var playerNamezArray: [String] = []
    
    @Published var currentRoundzIndex: Int = 0
    @Published var currentPlayerIndexz: Int = 0
    @Published var currentPromptzi: QuizblinkPrompt?
    @Published var roundAnswerzCollect: [PlayerAnswerZap] = []
    
    @Published var usedPromptIndexz: Set<Int> = []
    @Published var showConfettiBlast: Bool = false
    
    private var availablePromptz: [QuizblinkPrompt] {
        selectedDeckzi == .eitherOr ? QuizblinkPrompt.eitherOrDeckz : QuizblinkPrompt.situationzDeckz
    }
    
    func startGameFlowz() {
        if playerNamezArray.isEmpty || playerNamezArray.count != playerCountzValue {
            playerNamezArray = (1...playerCountzValue).map { "P\($0)" }
        }
        currentRoundzIndex = 0
        currentPlayerIndexz = 0
        usedPromptIndexz.removeAll()
        loadNextPromptzi()
        currentPhazor = .playerTurnzFlip
    }
    
    func recordPlayerChoicez(option: Int) {
        let answerz = PlayerAnswerZap(playerIndexz: currentPlayerIndexz, chosenOptionz: option)
        roundAnswerzCollect.append(answerz)
        
        if currentPlayerIndexz < playerCountzValue - 1 {
            currentPlayerIndexz += 1
        } else {
            currentPhazor = .revealShowdown
            checkForMajorityz()
        }
    }
    
    func proceedToNextRoundz() {
        currentRoundzIndex += 1
        
        if currentRoundzIndex >= totalRoundzLimit {
            currentPhazor = .gameFinale
        } else {
            roundAnswerzCollect.removeAll()
            currentPlayerIndexz = 0
            loadNextPromptzi()
            currentPhazor = .playerTurnzFlip
        }
    }
    
    func restartGameSessionz() {
        currentPhazor = .setupLaunch
        currentRoundzIndex = 0
        currentPlayerIndexz = 0
        roundAnswerzCollect.removeAll()
        usedPromptIndexz.removeAll()
        currentPromptzi = nil
    }
    
    private func loadNextPromptzi() {
        let availablez = availablePromptz.indices.filter { !usedPromptIndexz.contains($0) }
        if let randomIndexz = availablez.randomElement() {
            usedPromptIndexz.insert(randomIndexz)
            currentPromptzi = availablePromptz[randomIndexz]
        } else {
            usedPromptIndexz.removeAll()
            if let randomIndexz = availablePromptz.indices.randomElement() {
                usedPromptIndexz.insert(randomIndexz)
                currentPromptzi = availablePromptz[randomIndexz]
            }
        }
    }
    
    func getVotezCount() -> (alphaVotez: Int, bravoVotez: Int) {
        let alphaCountz = roundAnswerzCollect.filter { $0.chosenOptionz == 0 }.count
        let bravoCountz = roundAnswerzCollect.filter { $0.chosenOptionz == 1 }.count
        return (alphaCountz, bravoCountz)
    }
    
    func getMajorityTextz() -> String {
        let votez = getVotezCount()
        if votez.alphaVotez > votez.bravoVotez {
            return "Majority chose A!"
        } else if votez.bravoVotez > votez.alphaVotez {
            return "Majority chose B!"
        } else {
            return "Perfect tie!"
        }
    }
    
    private func checkForMajorityz() {
        let votez = getVotezCount()
        if votez.alphaVotez != votez.bravoVotez {
            showConfettiBlast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showConfettiBlast = false
            }
        }
    }
}

