import UIKit

struct PqFonts {
    static func title2Bold() -> UIFont {
        UIFont.preferredFont(forTextStyle: .title2).withWeight(.bold)
    }
    
    static func headlineRegular() -> UIFont {
        UIFont.preferredFont(forTextStyle: .headline)
    }
    
    static func footnoteRegular() -> UIFont {
        UIFont.preferredFont(forTextStyle: .footnote)
    }
    
    static func monospacedDigit(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        return systemFont.monospacedDigitFont()
    }
}

extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let descriptor = fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: weight]
        ])
        return UIFont(descriptor: descriptor, size: pointSize)
    }
    
    func monospacedDigitFont() -> UIFont {
        let features: [[UIFontDescriptor.FeatureKey: Int]] = [
            [
                .type: kNumberSpacingType,
                .selector: kMonospacedNumbersSelector
            ]
        ]
        let descriptor = fontDescriptor.addingAttributes([
            .featureSettings: features
        ])
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}

