import Foundation

/// Tab enum for app navigation
enum Tab: Int, CaseIterable, Identifiable {
    case home
    case weeklyMenu
    case records
    case goals
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "ホーム"
        case .weeklyMenu: return "メニュー"
        case .records: return "記録"
        case .goals: return "目標"
        case .settings: return "設定"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .weeklyMenu: return "calendar"
        case .records: return "chart.line.uptrend.xyaxis"
        case .goals: return "flag.fill"
        case .settings: return "gearshape.fill"
        }
    }
}
