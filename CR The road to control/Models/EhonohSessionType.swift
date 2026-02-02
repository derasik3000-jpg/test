import SwiftUI

enum EhonohSessionType: Int16, CaseIterable {
    case work = 0
    case study = 1
    case sport = 2
    case rest = 3
    
    var degubaTitle: String {
        switch self {
        case .work: return "Work"
        case .study: return "Study"
        case .sport: return "Sport"
        case .rest: return "Rest"
        }
    }
    
    var evubewIcon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .study: return "book.fill"
        case .sport: return "figure.run"
        case .rest: return "bed.double.fill"
        }
    }
    
    var cuqavuColor: Color {
        switch self {
        case .work: return Color.blue
        case .study: return Color.purple
        case .sport: return Color.green
        case .rest: return Color.orange
        }
    }
}

