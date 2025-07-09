import SwiftUI

struct GoalsView: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    @State private var showingAddGoal = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // アクティブな目標
                    ActiveGoalsSection()
                        .environmentObject(lifeDataManager)
                    
                    // 完了した目標
                    CompletedGoalsSection()
                        .environmentObject(lifeDataManager)
                }
                .padding()
            }
            .navigationTitle("目標設定")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddGoal = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView()
                    .environmentObject(lifeDataManager)
            }
        }
    }
}

// MARK: - アクティブな目標セクション
struct ActiveGoalsSection: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    
    var activeGoals: [Goal] {
        lifeDataManager.goals.filter { !$0.isCompleted }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.blue)
                Text("アクティブな目標")
                    .font(.headline)
                Spacer()
            }
            
            if activeGoals.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "target")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("まだ目標が設定されていません")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("新しい目標を設定して、習慣改善を始めましょう！")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(activeGoals) { goal in
                        GoalCard(goal: goal)
                            .environmentObject(lifeDataManager)
                    }
                }
            }
        }
    }
}

// MARK: - 完了した目標セクション
struct CompletedGoalsSection: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    
    var completedGoals: [Goal] {
        lifeDataManager.goals.filter { $0.isCompleted }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("完了した目標")
                    .font(.headline)
                Spacer()
            }
            
            if completedGoals.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("まだ完了した目標がありません")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(completedGoals) { goal in
                        CompletedGoalCard(goal: goal)
                    }
                }
            }
        }
    }
}

// MARK: - 目標カード
struct GoalCard: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    let goal: Goal
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: goal.type.icon)
                    .foregroundColor(goal.type.color)
                    .frame(width: 20)
                
                Text(goal.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(Int(goal.progress * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            // プログレスバー
            ProgressView(value: goal.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: goal.type.color))
            
            HStack {
                Text("目標: \(String(format: "%.1f", goal.targetValue))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("現在: \(String(format: "%.1f", goal.currentValue))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("期限: \(formatDate(goal.deadline))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("更新") {
                    updateGoalProgress()
                }
                .buttonStyle(SecondaryButtonStyle())
                .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    private func updateGoalProgress() {
        // 簡易的な進捗更新（実際のアプリでは詳細な入力画面を表示）
        let newValue = min(goal.currentValue + goal.targetValue * 0.1, goal.targetValue)
        lifeDataManager.updateGoalProgress(goalId: goal.id, currentValue: newValue)
    }
}

// MARK: - 完了した目標カード
struct CompletedGoalCard: View {
    let goal: Goal
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("完了日: \(formatDate(goal.deadline))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: goal.type.icon)
                .foregroundColor(goal.type.color)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    GoalsView()
        .environmentObject(LifeDataManager())
} 