import SwiftUI

struct AddGoalView: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var selectedType: HabitImprovement.HabitType = .sleep
    @State private var targetValue: Double = 0
    @State private var deadline = Date().addingTimeInterval(30 * 24 * 60 * 60) // 30日後
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("目標の基本情報") {
                    TextField("目標タイトル", text: $title)
                    
                    Picker("習慣タイプ", selection: $selectedType) {
                        ForEach(HabitImprovement.HabitType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundColor(type.color)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }
                }
                
                Section("目標値") {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(getValueLabel(for: selectedType))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        switch selectedType {
                        case .sleep:
                            SleepGoalInput(value: $targetValue)
                        case .steps:
                            StepsGoalInput(value: $targetValue)
                        case .exercise:
                            ExerciseGoalInput(value: $targetValue)
                        case .diet:
                            DietGoalInput(value: $targetValue)
                        case .stress:
                            StressGoalInput(value: $targetValue)
                        case .smoking:
                            SmokingGoalInput(value: $targetValue)
                        case .alcohol:
                            AlcoholGoalInput(value: $targetValue)
                        }
                    }
                }
                
                Section("期限") {
                    DatePicker(
                        "目標期限",
                        selection: $deadline,
                        in: Date()...,
                        displayedComponents: .date
                    )
                }
                
                Section("目標プレビュー") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: selectedType.icon)
                                .foregroundColor(selectedType.color)
                            Text(title.isEmpty ? "目標タイトル" : title)
                                .font(.headline)
                        }
                        
                        Text("\(selectedType.displayName): \(String(format: "%.1f", targetValue))\(getValueUnit(for: selectedType))")
                            .font(.subheadline)
                        
                        Text("期限: \(formatDate(deadline))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("新しい目標")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveGoal()
                    }
                    .disabled(title.isEmpty || targetValue <= 0)
                }
            }
            .alert("目標設定完了！", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("新しい目標が設定されました。頑張って達成しましょう！")
            }
        }
    }
    
    private func saveGoal() {
        lifeDataManager.addGoal(
            title: title,
            type: selectedType,
            targetValue: targetValue,
            deadline: deadline
        )
        showingSuccess = true
    }
    
    private func getValueLabel(for type: HabitImprovement.HabitType) -> String {
        switch type {
        case .sleep: return "目標睡眠時間（時間）"
        case .steps: return "目標歩数（歩）"
        case .exercise: return "目標運動時間（分）"
        case .diet: return "目標食事改善スコア（1-10）"
        case .stress: return "目標ストレスレベル（1-10、低いほど良い）"
        case .smoking: return "目標禁煙日数（日）"
        case .alcohol: return "目標飲酒量削減（杯）"
        }
    }
    
    private func getValueUnit(for type: HabitImprovement.HabitType) -> String {
        switch type {
        case .sleep: return "時間"
        case .steps: return "歩"
        case .exercise: return "分"
        case .diet: return ""
        case .stress: return ""
        case .smoking: return "日"
        case .alcohol: return "杯"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - 目標値入力ビュー
struct SleepGoalInput: View {
    @Binding var value: Double
    
    var body: some View {
        VStack(spacing: 10) {
            Text("\(String(format: "%.1f", value))時間")
                .font(.title2)
                .fontWeight(.bold)
            
            Slider(value: $value, in: 6...10, step: 0.5)
                .accentColor(.blue)
        }
    }
}

struct StepsGoalInput: View {
    @Binding var value: Double
    
    var body: some View {
        VStack(spacing: 10) {
            Text("\(Int(value))歩")
                .font(.title2)
                .fontWeight(.bold)
            
            Slider(value: $value, in: 5000...15000, step: 500)
                .accentColor(.green)
        }
    }
}

struct ExerciseGoalInput: View {
    @Binding var value: Double
    
    var body: some View {
        VStack(spacing: 10) {
            Text("\(Int(value))分")
                .font(.title2)
                .fontWeight(.bold)
            
            Slider(value: $value, in: 15...120, step: 5)
                .accentColor(.red)
        }
    }
}

struct DietGoalInput: View {
    @Binding var value: Double
    
    var body: some View {
        VStack(spacing: 10) {
            Text("スコア: \(Int(value))")
                .font(.title2)
                .fontWeight(.bold)
            
            Slider(value: $value, in: 5...10, step: 1)
                .accentColor(.orange)
            
            Text("5: 改善中 〜 10: 完璧な食事")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct StressGoalInput: View {
    @Binding var value: Double
    
    var body: some View {
        VStack(spacing: 10) {
            Text("レベル: \(Int(value))")
                .font(.title2)
                .fontWeight(.bold)
            
            Slider(value: $value, in: 1...7, step: 1)
                .accentColor(.purple)
            
            Text("1: リラックス 〜 7: 軽度ストレス")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct SmokingGoalInput: View {
    @Binding var value: Double
    
    var body: some View {
        VStack(spacing: 10) {
            Text("\(Int(value))日")
                .font(.title2)
                .fontWeight(.bold)
            
            Slider(value: $value, in: 7...365, step: 7)
                .accentColor(.gray)
        }
    }
}

struct AlcoholGoalInput: View {
    @Binding var value: Double
    
    var body: some View {
        VStack(spacing: 10) {
            Text("削減: \(Int(value))杯")
                .font(.title2)
                .fontWeight(.bold)
            
            Slider(value: $value, in: 1...5, step: 1)
                .accentColor(.yellow)
        }
    }
}

#Preview {
    AddGoalView()
        .environmentObject(LifeDataManager())
} 