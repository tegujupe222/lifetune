import Foundation
import SwiftUI

// MARK: - 寿命データモデル
struct LifeData: Codable, Identifiable {
    let id = UUID()
    var nickname: String // ニックネームを追加
    var birthDate: Date
    var gender: Gender
    var country: String
    var averageLifeExpectancy: Double
    var currentLifeExpectancy: Double
    var lastUpdated: Date
    
    enum Gender: String, CaseIterable, Codable {
        case male = "male"
        case female = "female"
        case other = "other"
        
        var displayName: String {
            switch self {
            case .male: return "男性"
            case .female: return "女性"
            case .other: return "その他"
            }
        }
    }
    
    var remainingLife: TimeInterval {
        let totalLifeSeconds = currentLifeExpectancy * 365.25 * 24 * 60 * 60
        let livedSeconds = Date().timeIntervalSince(birthDate)
        return max(0, totalLifeSeconds - livedSeconds)
    }
    
    var remainingDays: Int {
        return Int(remainingLife / (24 * 60 * 60))
    }
    
    var remainingHours: Int {
        return Int((remainingLife.truncatingRemainder(dividingBy: 24 * 60 * 60)) / (60 * 60))
    }
    
    var remainingMinutes: Int {
        return Int((remainingLife.truncatingRemainder(dividingBy: 60 * 60)) / 60)
    }
    
    var remainingSeconds: Int {
        return Int(remainingLife.truncatingRemainder(dividingBy: 60))
    }
}

// MARK: - 習慣改善・悪化データ
struct HabitImprovement: Codable, Identifiable {
    let id = UUID()
    var date: Date
    var type: HabitType
    var value: Double
    var lifeExtension: Double // 延びた時間（時間単位、マイナス値も含む）
    
    enum HabitType: String, CaseIterable, Codable {
        case sleep = "sleep"
        case steps = "steps"
        case exercise = "exercise"
        case diet = "diet"
        case stress = "stress"
        case smoking = "smoking"
        case alcohol = "alcohol"
        case smoking_negative = "smoking_negative"
        case alcohol_negative = "alcohol_negative"
        case stress_negative = "stress_negative"
        case diet_negative = "diet_negative"
        case exercise_negative = "exercise_negative"
        
        var displayName: String {
            switch self {
            case .sleep: return "睡眠改善"
            case .steps: return "歩数増加"
            case .exercise: return "運動"
            case .diet: return "食事改善"
            case .stress: return "ストレス軽減"
            case .smoking: return "禁煙"
            case .alcohol: return "節酒"
            case .smoking_negative: return "喫煙"
            case .alcohol_negative: return "過度な飲酒"
            case .stress_negative: return "ストレス増加"
            case .diet_negative: return "不健康な食事"
            case .exercise_negative: return "運動不足"
            }
        }
        
        var icon: String {
            switch self {
            case .sleep: return "bed.double.fill"
            case .steps: return "figure.walk"
            case .exercise: return "heart.fill"
            case .diet: return "leaf.fill"
            case .stress: return "brain.head.profile"
            case .smoking: return "smoke.fill"
            case .alcohol: return "wineglass.fill"
            case .smoking_negative: return "smoke"
            case .alcohol_negative: return "wineglass"
            case .stress_negative: return "exclamationmark.triangle.fill"
            case .diet_negative: return "xmark.circle.fill"
            case .exercise_negative: return "minus.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .sleep: return .blue
            case .steps: return .green
            case .exercise: return .red
            case .diet: return .orange
            case .stress: return .purple
            case .smoking: return .gray
            case .alcohol: return .yellow
            case .smoking_negative: return .red
            case .alcohol_negative: return .orange
            case .stress_negative: return .red
            case .diet_negative: return .red
            case .exercise_negative: return .red
            }
        }
        
        var isNegative: Bool {
            switch self {
            case .smoking_negative, .alcohol_negative, .stress_negative, .diet_negative, .exercise_negative:
                return true
            default:
                return false
            }
        }
        
        var positiveCounterpart: HabitType? {
            switch self {
            case .smoking_negative: return .smoking
            case .alcohol_negative: return .alcohol
            case .stress_negative: return .stress
            case .diet_negative: return .diet
            case .exercise_negative: return .exercise
            default: return nil
            }
        }
        
        var negativeCounterpart: HabitType? {
            switch self {
            case .smoking: return .smoking_negative
            case .alcohol: return .alcohol_negative
            case .stress: return .stress_negative
            case .diet: return .diet_negative
            case .exercise: return .exercise_negative
            default: return nil
            }
        }
    }
}

// MARK: - 目標設定
struct Goal: Codable, Identifiable {
    let id = UUID()
    var title: String
    var type: HabitImprovement.HabitType
    var targetValue: Double
    var currentValue: Double
    var deadline: Date
    var isCompleted: Bool
    var createdAt: Date
    
    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(currentValue / targetValue, 1.0)
    }
}

// MARK: - 国別平均寿命データ
struct CountryLifeExpectancy: Codable {
    let country: String
    let maleLifeExpectancy: Double
    let femaleLifeExpectancy: Double
    
    func getLifeExpectancy(for gender: LifeData.Gender) -> Double {
        switch gender {
        case .male:
            return maleLifeExpectancy
        case .female:
            return femaleLifeExpectancy
        case .other:
            return (maleLifeExpectancy + femaleLifeExpectancy) / 2
        }
    }
} 