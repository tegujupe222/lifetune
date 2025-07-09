import SwiftUI

struct HabitTrackingView: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    @State private var selectedType: HabitImprovement.HabitType = .sleep
    @State private var value: String = ""
    @State private var showingAddSheet = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // エラーメッセージ表示
                    if !lifeDataManager.errorMessage.isEmpty {
                        ErrorMessageView(message: lifeDataManager.errorMessage) {
                            lifeDataManager.clearErrorMessage()
                        }
                    }
                    
                    // 総合統計カード
                    OverallStatsCard()
                        .environmentObject(lifeDataManager)
                    
                    // 習慣改善記録
                    HabitImprovementsCard()
                        .environmentObject(lifeDataManager)
                    
                    // 寿命短縮要因記録
                    LifeReductionCard()
                        .environmentObject(lifeDataManager)
                }
                .padding()
            }
            .navigationTitle("習慣記録")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("記録追加") {
                        showingAddSheet = true
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddHabitView(
                    selectedType: $selectedType,
                    value: $value,
                    onSave: addHabitImprovement,
                    onCancel: { showingAddSheet = false }
                )
            }
            .alert("記録追加", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func addHabitImprovement() {
        guard let doubleValue = Double(value) else {
            alertMessage = "数値を入力してください。"
            showingAlert = true
            return
        }
        
        lifeDataManager.addHabitImprovement(type: selectedType, value: doubleValue)
        value = ""
        showingAddSheet = false
        
        alertMessage = "記録を追加しました！"
        showingAlert = true
    }
}

// MARK: - 総合統計カード
struct OverallStatsCard: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                Text("総合統計")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 20) {
                StatItem(
                    title: "延長効果",
                    value: "\(String(format: "%.1f", lifeDataManager.totalLifeExtension))時間",
                    color: .green,
                    icon: "arrow.up.circle.fill"
                )
                
                StatItem(
                    title: "短縮効果",
                    value: "\(String(format: "%.1f", lifeDataManager.totalLifeReduction))時間",
                    color: .red,
                    icon: "arrow.down.circle.fill"
                )
            }
            
            Divider()
            
            HStack {
                Text("純変化")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(String(format: "%.1f", lifeDataManager.netLifeChange))時間")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(lifeDataManager.netLifeChange >= 0 ? .green : .red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// MARK: - 統計アイテム
struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel("\(title)、\(value)")
    }
}

// MARK: - 習慣改善記録カード
struct HabitImprovementsCard: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                Text("習慣改善記録")
                    .font(.headline)
                Spacer()
            }
            
            let positiveImprovements = lifeDataManager.getPositiveImprovements()
            
            if positiveImprovements.isEmpty {
                Text("まだ習慣改善の記録がありません。良い習慣を記録して、寿命を延ばしましょう！")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(positiveImprovements.prefix(5)) { improvement in
                        ImprovementRow(improvement: improvement)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// MARK: - 寿命短縮要因カード
struct LifeReductionCard: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text("寿命短縮要因")
                    .font(.headline)
                Spacer()
            }
            
            let negativeImprovements = lifeDataManager.getNegativeImprovements()
            
            if negativeImprovements.isEmpty {
                Text("寿命短縮要因の記録はありません。健康な生活を続けましょう！")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(negativeImprovements.prefix(5)) { improvement in
                        ImprovementRow(improvement: improvement)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// MARK: - 改善記録行
struct ImprovementRow: View {
    let improvement: HabitImprovement
    
    var body: some View {
        HStack {
            Image(systemName: improvement.type.icon)
                .foregroundColor(improvement.type.color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(improvement.type.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(String(format: "%.1f", improvement.value)) - \(formatDate(improvement.date))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(improvement.lifeExtension >= 0 ? "+" : "")\(String(format: "%.1f", improvement.lifeExtension))時間")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(improvement.lifeExtension >= 0 ? .green : .red)
        }
        .accessibilityLabel("\(improvement.type.displayName)、値\(String(format: "%.1f", improvement.value))、寿命変化\(String(format: "%.1f", improvement.lifeExtension))時間")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - 習慣追加ビュー
struct AddHabitView: View {
    @Binding var selectedType: HabitImprovement.HabitType
    @Binding var value: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    @State private var showingTypePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("習慣の種類")) {
                    HStack {
                        Text("種類")
                        Spacer()
                        Button(selectedType.displayName) {
                            showingTypePicker = true
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("値")) {
                    TextField(getPlaceholder(for: selectedType), text: $value)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("説明")) {
                    Text(getDescription(for: selectedType))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("習慣記録追加")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        onSave()
                    }
                    .disabled(value.isEmpty)
                }
            }
            .actionSheet(isPresented: $showingTypePicker) {
                ActionSheet(
                    title: Text("習慣の種類を選択"),
                    buttons: HabitImprovement.HabitType.allCases.map { type in
                        .default(Text(type.displayName)) {
                            selectedType = type
                        }
                    } + [.cancel()]
                )
            }
        }
    }
    
    private func getPlaceholder(for type: HabitImprovement.HabitType) -> String {
        switch type {
        case .sleep: return "睡眠時間（時間）"
        case .steps: return "歩数"
        case .exercise: return "運動時間（分）"
        case .diet: return "食事改善スコア（1-10）"
        case .stress: return "ストレスレベル（1-10）"
        case .smoking: return "禁煙日数"
        case .alcohol: return "節酒量（%）"
        case .smoking_negative: return "喫煙本数"
        case .alcohol_negative: return "飲酒量（%）"
        case .stress_negative: return "ストレスレベル（1-10）"
        case .diet_negative: return "不健康度（1-10）"
        case .exercise_negative: return "座り時間（時間）"
        }
    }
    
    private func getDescription(for type: HabitImprovement.HabitType) -> String {
        switch type {
        case .sleep: return "7-8時間が最適です。6時間未満や9時間以上は寿命短縮の原因になります。"
        case .steps: return "8000歩以上で寿命延長効果があります。"
        case .exercise: return "運動時間に応じて寿命延長効果があります。"
        case .diet: return "健康的な食事のスコアです。高いほど良いです。"
        case .stress: return "ストレスレベルです。低いほど良いです。"
        case .smoking: return "禁煙した日数を記録します。"
        case .alcohol: return "節酒した量を記録します。"
        case .smoking_negative: return "喫煙本数です。本数が多いほど寿命短縮効果があります。"
        case .alcohol_negative: return "過度な飲酒量です。多いほど寿命短縮効果があります。"
        case .stress_negative: return "ストレスレベルです。高いほど寿命短縮効果があります。"
        case .diet_negative: return "不健康な食事の度合いです。高いほど寿命短縮効果があります。"
        case .exercise_negative: return "座り時間です。長いほど寿命短縮効果があります。"
        }
    }
}

#Preview {
    HabitTrackingView()
        .environmentObject(LifeDataManager())
} 