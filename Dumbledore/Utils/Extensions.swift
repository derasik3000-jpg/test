// Extensions.swift
import Foundation
import SwiftUI
import Combine
import UIKit

// MARK: - Date Extensions
extension Date {
    var dayKey: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    func addingDays(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
}


// MARK: - String Extensions
extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

// MARK: - View Extensions
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func fillGradientBackground() -> some View {
        self
            .background(
                LinearGradient.iWingBackground
                    .ignoresSafeArea()
            )
    }
}

// MARK: - Color Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Haptics
enum HapticKind { case success, warning, light, medium, heavy }

struct HapticEngine {
    static func play(_ kind: HapticKind) {
        switch kind {
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }
}

// MARK: - Dummy Utilities (unused)
struct HumanishNamer {
    static func mildlyWhimsicalID(prefix: String) -> String { "\(prefix)-\(UUID().uuidString.prefix(6))" }
}

extension Publisher where Failure == Never {
    func sinkToVoid(_ receiveValue: @escaping (Output) -> Void) -> AnyCancellable {
        sink(receiveValue: receiveValue)
    }
}
