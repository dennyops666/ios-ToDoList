import UIKit

enum Theme: Int {
    case light
    case dark
    case system
    
    var colors: ThemeColors {
        switch self {
        case .light:
            return ThemeColors.lightColors
        case .dark:
            return ThemeColors.darkColors
        case .system:
            return UITraitCollection.current.userInterfaceStyle == .dark ? 
                ThemeColors.darkColors : ThemeColors.lightColors
        }
    }
}

struct ThemeColors {
    let background: UIColor
    let navigationBar: UIColor
    let cellBackground: UIColor
    let completedCellBackground: UIColor
    let primaryText: UIColor
    let secondaryText: UIColor
    let completedText: UIColor
    let accentColor: UIColor
    
    static let lightColors = ThemeColors(
        background: UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0),
        navigationBar: UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.0),
        cellBackground: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
        completedCellBackground: UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1.0),
        primaryText: UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1.0),
        secondaryText: UIColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1.0),
        completedText: UIColor(red: 0.6, green: 0.6, blue: 0.65, alpha: 1.0),
        accentColor: UIColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1.0)
    )
    
    static let darkColors = ThemeColors(
        background: UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0),
        navigationBar: UIColor(red: 0.13, green: 0.13, blue: 0.14, alpha: 1.0),
        cellBackground: UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1.0),
        completedCellBackground: UIColor(red: 0.15, green: 0.15, blue: 0.16, alpha: 1.0),
        primaryText: UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0),
        secondaryText: UIColor(red: 0.75, green: 0.75, blue: 0.8, alpha: 1.0),
        completedText: UIColor(red: 0.55, green: 0.55, blue: 0.6, alpha: 1.0),
        accentColor: UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0)
    )
}

class ThemeManager {
    static let shared = ThemeManager()
    private init() {}
    
    var currentTheme: Theme {
        get {
            let rawValue = UserDefaults.standard.integer(forKey: "AppTheme")
            return Theme(rawValue: rawValue) ?? .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "AppTheme")
            NotificationCenter.default.post(name: .themeChanged, object: nil)
        }
    }
    
    func getCurrentColors(for traitCollection: UITraitCollection) -> ThemeColors {
        switch currentTheme {
        case .system:
            return traitCollection.userInterfaceStyle == .dark ? 
                ThemeColors.darkColors : ThemeColors.lightColors
        case .light:
            return ThemeColors.lightColors
        case .dark:
            return ThemeColors.darkColors
        }
    }
}

extension Notification.Name {
    static let themeChanged = Notification.Name("ThemeChanged")
} 