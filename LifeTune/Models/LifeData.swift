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

// MARK: - 習慣改善データ
struct HabitImprovement: Codable, Identifiable {
    let id = UUID()
    var date: Date
    var type: HabitType
    var value: Double
    var lifeExtension: Double // 延びた時間（時間単位）
    
    enum HabitType: String, CaseIterable, Codable {
        case sleep = "sleep"
        case steps = "steps"
        case exercise = "exercise"
        case diet = "diet"
        case stress = "stress"
        case smoking = "smoking"
        case alcohol = "alcohol"
        
        var displayName: String {
            switch self {
            case .sleep: return "睡眠改善"
            case .steps: return "歩数増加"
            case .exercise: return "運動"
            case .diet: return "食事改善"
            case .stress: return "ストレス軽減"
            case .smoking: return "禁煙"
            case .alcohol: return "節酒"
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