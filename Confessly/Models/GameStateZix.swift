import Foundation

enum GamePhazor {
    case setupLaunch
    case playerTurnzFlip
    case revealShowdown
    case gameFinale
}

struct PlayerAnswerZap {
    let playerIndexz: Int
    let chosenOptionz: Int
}

