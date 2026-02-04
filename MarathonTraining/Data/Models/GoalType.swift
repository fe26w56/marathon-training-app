import Foundation

/// Goal type enum for long-term goals
enum GoalType: String, Codable, CaseIterable {
    case finishMarathon = "finishMarathon"
    case sub5 = "sub5"
    case sub4 = "sub4"
    case sub3_5 = "sub3_5"
    case sub3 = "sub3"
    case personalBest = "personalBest"
    case custom = "custom"

    var displayName: String {
        switch self {
        case .finishMarathon: return "フルマラソン完走"
        case .sub5: return "サブ5"
        case .sub4: return "サブ4"
        case .sub3_5: return "サブ3.5"
        case .sub3: return "サブ3"
        case .personalBest: return "自己ベスト更新"
        case .custom: return "カスタム"
        }
    }

    var targetTime: TimeInterval? {
        switch self {
        case .sub5: return 5 * 60 * 60  // 5 hours
        case .sub4: return 4 * 60 * 60  // 4 hours
        case .sub3_5: return 3.5 * 60 * 60  // 3.5 hours
        case .sub3: return 3 * 60 * 60  // 3 hours
        default: return nil
        }
    }
}
