import SwiftUI

struct Typography {
    static func h1() -> Font {
        return .system(size: 28, weight: .semibold)
    }
    
    static func h2() -> Font {
        return .system(size: 22, weight: .semibold)
    }
    
    static func numbers() -> Font {
        return .system(size: 34, weight: .bold).monospacedDigit()
    }
    
    static func body() -> Font {
        return .system(size: 17, weight: .regular)
    }
    
    static func caption() -> Font {
        return .system(size: 13, weight: .medium)
    }
}

