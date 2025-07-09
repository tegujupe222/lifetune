import SwiftUI

struct AddHabitView: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: HabitImprovement.HabitType
    @State private var value: Double = 0
    @State private var showingSuccess = false
    
    init(selectedType: HabitImprovement.HabitType = .sleep) {
        self._selectedType = State(initialValue: selectedType)
        self._value = State(initialValue: Self.getDefaultValue(for: selectedType))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // ヘッダー
                VStack(spacing: 15) {
                    Image(systemName: selectedType.icon)
                        .font(.system(size: 60))
                        .foregroundColor(selectedType.color)
                    
                    Text(selectedType.displayName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(getDescription(for: selectedType))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // 値入力
                VStack(spacing: 20) {
                    Text(getValueLabel(for: selectedType))
                        .font(.headline)
                    
                    switch selectedType {
                    case .sleep:
                        SleepInputView(value: $value)
                    case .steps:
                        StepsInputView(value: $value)
                    case .exercise:
                        ExerciseInputView(value: $value)
                    case .diet:
                        DietInputView(value: $value)
                    case .stress:
                        StressInputView(value: $value)
                    case .smoking:
                        SmokingInputView(value: $value)
                    case .alcohol:
                        AlcoholInputView(value: $value)
                    }
                }
                
                // 寿命延長効果プレビュー
                if value > 0 {
                    LifeExtensionPreview(
                        type: selectedType,
                        value: value
                    )
                }
                
                Spacer()
                
                // 保存ボタン
                Button("記録する") {
                    saveHabit()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(value <= 0)
            }
            .padding()
            .navigationTitle("習慣改善記録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
            .alert("記録完了！", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("習慣改善が記録され、寿命が延びました！")
            }
        }
    }
    
    private func saveHabit() {
        lifeDataManager.addHabitImprovement(type: selectedType, value: value)
        showingSuccess = true
    }
    
    // MARK: - ヘルパー関数
    private static func getDefaultValue(for type: HabitImprovement.HabitType) -> Double {
        switch type {
        case .sleep: return 7.0
        case .steps: return 8000
        case .exercise: return 30
        case .diet: return 7
        case .stress: return 5
        case .smoking: return 1
        case .alcohol: return 0
        }
    }
    
    private func getDescription(for type: HabitImprovement.HabitType) -> String {
        switch type {
        case .sleep: return "睡眠時間を記録して、質の良い睡眠を目指しましょう"
        case .steps: return "今日の歩数を記録して、活動量を把握しましょう"
        case .exercise: return "運動時間を記録して、健康維持を目指しましょう"
        case .diet: return "食事の改善度を評価して、栄養バランスを整えましょう"
        case .stress: return "ストレスレベルを記録して、メンタルケアを心がけましょう"
        case .smoking: return "禁煙日数を記録して、健康な生活を目指しましょう"
        case .alcohol: return "飲酒量の削減を記録して、適度な飲酒を心がけましょう"
        }
    }
    
    private func getValueLabel(for type: HabitImprovement.HabitType) -> String {
        switch type {
        case .sleep: return "睡眠時間（時間）"
        case .steps: return "歩数（歩）"
        case .exercise: return "運動時間（分）"
        case .diet: return "食事改善スコア（1-10）"
        case .stress: return "ストレスレベル（1-10、低いほど良い）"
        case .smoking: return "禁煙日数（日）"
        case .alcohol: return "飲酒量削減（杯）"
        }
    }
}

// MARK: - 入力ビュー
struct SleepInputView: View {
    @Binding var value: Double
    
    var body: some View {
        VStack(spacing: 10) {
            Text("\(String(format: "%.1f", value))時間")
                .font(.title2)
                .fontWeight(.bold)
            
            Slider(value: $value, in: 0...12, step: 0.5)
                .accentColor(.blue)
        }
    }
}

struct StepsInputView: View {
    @Binding var value: Double
    
    var body: some View {
        VStack(spacing: 10) {
            Text("\(Int(value))歩")
                .font(.title2)
                .fontWeight(.bold)
            
            Slider(value: $value, in: 0...20000, step: 100)
                .accentColor(.green)
        }
    }
}

struct ExerciseInputView: View {
    @Binding var value: Double
    
    var body: some View {
        VStack(spacing: 10) {
            Text("\(Int(value))分")
                .font(.title2)
                .fontWeight(.bold)
            
            Slider(value: $value, in: 0...180, step: 5)
                .accentColor(.red)
        }
    }
}

struct DietInputView: View {
    @Binding var value: Double
    
    var body: some View {
        VStack(spacing: 10) {
            Text("スコア: \(Int(value))")
                .font(.title2)
                .fontWeight(.bold)
            
            Slider(value: $value, in: 1...10, step: 1)
                .accentColor(.orange)
            
            Text("1: 改善の余地あり 〜 10: 完璧な食事")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct StressInputView: View {
    @Binding var value: Double
    
    var body: some View {
        VStack(spacing: 10) {
            Text("レベル: \(Int(value))")
                .font(.title2)
                .fontWeight(.bold)
            
            Slider(value: $value, in: 1...10, step: 1)
                .accentColor(.purple)
            
            Text("1: リラックス 〜 10: 非常にストレス")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct SmokingInputView: View {
    @Binding var value: Double
    
    var body: some View {
        VStack(spacing: 10) {
            Text("\(Int(value))日")
                .font(.title2)
                .fontWeight(.bold)
            
            Slider(value: $value, in: 0...365, step: 1)
                .accentColor(.gray)
        }
    }
}

struct AlcoholInputView: View {
    @Binding var value: Double
    
    var body: some View {
        VStack(spacing: 10) {
            Text("削減: \(Int(value))杯")
                .font(.title2)
                .fontWeight(.bold)
            
            Slider(value: $value, in: 0...10, step: 1)
                .accentColor(.yellow)
        }
    }
}

// MARK: - 寿命延長効果プレビュー
struct LifeExtensionPreview: View {
    let type: HabitImprovement.HabitType
    let value: Double
    
    private var lifeExtension: Double {
        switch type {
        case .sleep:
            if value >= 7 && value <= 8 {
                return 0.5
            } else if value < 6 || value > 9 {
                return -0.5
            } else {
                return 0.1
            }
        case .steps:
            if value >= 8000 {
                return 0.3
            } else if value >= 6000 {
                return 0.1
            } else {
                return -0.1
            }
        case .exercise:
            return value * 0.01
        case .diet:
            return value * 0.1
        case .stress:
            return (11 - value) * 0.1
        case .smoking:
            return value * 0.1
        case .alcohol:
            return value * 0.05
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: lifeExtension > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .foregroundColor(lifeExtension > 0 ? .green : .red)
                
                Text("寿命延長効果")
                    .font(.headline)
                
                Spacer()
            }
            
            Text("\(lifeExtension > 0 ? "+" : "")\(String(format: "%.1f", lifeExtension))時間")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(lifeExtension > 0 ? .green : .red)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}

#Preview {
    AddHabitView()
        .environmentObject(LifeDataManager())
} 