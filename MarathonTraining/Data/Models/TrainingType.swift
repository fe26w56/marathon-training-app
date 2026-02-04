import Foundation

/// Training type enum for workout categorization
enum TrainingType: String, Codable, CaseIterable {
    case easy = "easy"
    case tempo = "tempo"
    case interval = "interval"
    case longRun = "longRun"
    case recovery = "recovery"
    case rest = "rest"
    case crossTraining = "crossTraining"

    var displayName: String {
        switch self {
        case .easy: return "イージーラン"
        case .tempo: return "テンポ走"
        case .interval: return "インターバル"
        case .longRun: return "ロング走"
        case .recovery: return "リカバリー"
        case .rest: return "休息"
        case .crossTraining: return "クロストレーニング"
        }
    }

    var icon: String {
        switch self {
        case .easy: return "figure.run"
        case .tempo: return "speedometer"
        case .interval: return "timer"
        case .longRun: return "figure.run.circle"
        case .recovery: return "heart.circle"
        case .rest: return "bed.double"
        case .crossTraining: return "figure.mixed.cardio"
        }
    }
}
