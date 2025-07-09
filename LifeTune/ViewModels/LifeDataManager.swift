import Foundation
import SwiftUI
import Combine

class LifeDataManager: ObservableObject {
    @Published var lifeData: LifeData?
    @Published var habitImprovements: [HabitImprovement] = []
    @Published var goals: [Goal] = []
    @Published var totalLifeExtension: Double = 0
    
    private var timer: Timer?
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadData()
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - タイマー管理
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.objectWillChange.send()
        }
    }
    
    // MARK: - データ保存・読み込み
    private func loadData() {
        if let data = userDefaults.data(forKey: "lifeData"),
           let lifeData = try? JSONDecoder().decode(LifeData.self, from: data) {
            self.lifeData = lifeData
        }
        
        if let data = userDefaults.data(forKey: "habitImprovements"),
           let improvements = try? JSONDecoder().decode([HabitImprovement].self, from: data) {
            self.habitImprovements = improvements
        }
        
        if let data = userDefaults.data(forKey: "goals"),
           let goals = try? JSONDecoder().decode([Goal].self, from: data) {
            self.goals = goals
        }
        
        calculateTotalLifeExtension()
    }
    
    private func saveData() {
        if let lifeData = lifeData,
           let data = try? JSONEncoder().encode(lifeData) {
            userDefaults.set(data, forKey: "lifeData")
        }
        
        if let data = try? JSONEncoder().encode(habitImprovements) {
            userDefaults.set(data, forKey: "habitImprovements")
        }
        
        if let data = try? JSONEncoder().encode(goals) {
            userDefaults.set(data, forKey: "goals")
        }
    }
    
    // MARK: - 寿命データ設定
    func setLifeData(birthDate: Date, gender: LifeData.Gender, country: String) {
        let lifeExpectancy = getLifeExpectancy(for: country, gender: gender)
        self.lifeData = LifeData(
            nickname: "",
            birthDate: birthDate,
            gender: gender,
            country: country,
            averageLifeExpectancy: lifeExpectancy,
            currentLifeExpectancy: lifeExpectancy,
            lastUpdated: Date()
        )
        saveData()
    }
    
    // MARK: - 習慣改善記録
    func addHabitImprovement(type: HabitImprovement.HabitType, value: Double) {
        let lifeExtension = calculateLifeExtension(for: type, value: value)
        let improvement = HabitImprovement(
            date: Date(),
            type: type,
            value: value,
            lifeExtension: lifeExtension
        )
        
        habitImprovements.append(improvement)
        
        // 現在の寿命を更新
        if var lifeData = lifeData {
            lifeData.currentLifeExpectancy += lifeExtension / 24 / 365.25 // 時間を年に変換
            lifeData.lastUpdated = Date()
            self.lifeData = lifeData
        }
        
        totalLifeExtension += lifeExtension
        saveData()
    }
    
    // MARK: - 目標管理
    func addGoal(title: String, type: HabitImprovement.HabitType, targetValue: Double, deadline: Date) {
        let goal = Goal(
            title: title,
            type: type,
            targetValue: targetValue,
            currentValue: 0,
            deadline: deadline,
            isCompleted: false,
            createdAt: Date()
        )
        goals.append(goal)
        saveData()
    }
    
    func updateGoalProgress(goalId: UUID, currentValue: Double) {
        if let index = goals.firstIndex(where: { $0.id == goalId }) {
            goals[index].currentValue = currentValue
            goals[index].isCompleted = currentValue >= goals[index].targetValue
            saveData()
        }
    }
    
    // MARK: - 寿命延長計算
    private func calculateLifeExtension(for type: HabitImprovement.HabitType, value: Double) -> Double {
        switch type {
        case .sleep:
            // 睡眠時間が7-8時間の範囲で最適、それ以外は寿命短縮
            if value >= 7 && value <= 8 {
                return 0.5 // 0.5時間延長
            } else if value < 6 || value > 9 {
                return -0.5 // 0.5時間短縮
            } else {
                return 0.1
            }
        case .steps:
            // 8000歩以上で寿命延長
            if value >= 8000 {
                return 0.3
            } else if value >= 6000 {
                return 0.1
            } else {
                return -0.1
            }
        case .exercise:
            // 運動時間（分）に応じて寿命延長
            return value * 0.01 // 1分につき0.01時間延長
        case .diet:
            // 食事改善スコア（1-10）に応じて寿命延長
            return value * 0.1
        case .stress:
            // ストレスレベル（1-10、低いほど良い）に応じて寿命延長
            return (11 - value) * 0.1
        case .smoking:
            // 禁煙日数に応じて寿命延長
            return value * 0.1
        case .alcohol:
            // 飲酒量削減に応じて寿命延長
            return value * 0.05
        }
    }
    
    private func calculateTotalLifeExtension() {
        totalLifeExtension = habitImprovements.reduce(0) { $0 + $1.lifeExtension }
    }
    
    // MARK: - 国別平均寿命データ
    private func getLifeExpectancy(for country: String, gender: LifeData.Gender) -> Double {
        // 簡易的な国別平均寿命データ
        let lifeExpectancyData: [String: (male: Double, female: Double)] = [
            "日本": (81.6, 87.7),
            "アメリカ": (76.1, 81.1),
            "イギリス": (79.4, 83.1),
            "ドイツ": (78.9, 83.6),
            "フランス": (79.7, 85.6),
            "カナダ": (80.9, 84.8),
            "オーストラリア": (81.2, 85.4),
            "韓国": (80.3, 86.3),
            "中国": (75.0, 78.0),
            "インド": (69.4, 72.0)
        ]
        
        let data = lifeExpectancyData[country] ?? (80.0, 85.0)
        
        switch gender {
        case .male:
            return data.male
        case .female:
            return data.female
        case .other:
            return (data.male + data.female) / 2
        }
    }
    
    // MARK: - 統計データ
    func getWeeklyImprovements() -> [HabitImprovement] {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return habitImprovements.filter { $0.date >= oneWeekAgo }
    }
    
    func getMonthlyImprovements() -> [HabitImprovement] {
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return habitImprovements.filter { $0.date >= oneMonthAgo }
    }
    
    func getImprovementsByType() -> [HabitImprovement.HabitType: [HabitImprovement]] {
        return Dictionary(grouping: habitImprovements) { $0.type }
    }
} 