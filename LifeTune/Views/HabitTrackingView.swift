import SwiftUI

struct HabitTrackingView: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    @State private var showingAddHabit = false
    @State private var selectedHabitType: HabitImprovement.HabitType = .sleep
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 今日の改善記録
                    TodayImprovementCard()
                        .environmentObject(lifeDataManager)
                    
                    // 習慣改善ボタン
                    HabitButtonsGrid()
                        .environmentObject(lifeDataManager)
                    
                    // 最近の改善履歴
                    RecentImprovementsList()
                        .environmentObject(lifeDataManager)
                }
                .padding()
            }
            .navigationTitle("習慣改善")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddHabit = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
                    .environmentObject(lifeDataManager)
            }
        }
    }
}

// MARK: - 今日の改善カード
struct TodayImprovementCard: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    
    var todayImprovements: [HabitImprovement] {
        let today = Calendar.current.startOfDay(for: Date())
        return lifeDataManager.habitImprovements.filter {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }
    }
    
    var todayTotalExtension: Double {
        todayImprovements.reduce(0) { $0 + $1.lifeExtension }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.blue)
                Text("今日の改善")
                    .font(.headline)
                Spacer()
            }
            
            if todayImprovements.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("今日はまだ改善を記録していません")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("下のボタンから記録を始めましょう！")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                VStack(spacing: 12) {
                    HStack {
                        Text("寿命延長効果")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("+\(String(format: "%.1f", todayTotalExtension))時間")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    ForEach(todayImprovements) { improvement in
                        HStack {
                            Image(systemName: improvement.type.icon)
                                .foregroundColor(improvement.type.color)
                                .frame(width: 20)
                            
                            Text(improvement.type.displayName)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("+\(String(format: "%.1f", improvement.lifeExtension))時間")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 4)
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

// MARK: - 習慣改善ボタングリッド
struct HabitButtonsGrid: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    @State private var showingAddHabit = false
    @State private var selectedHabitType: HabitImprovement.HabitType = .sleep
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("習慣改善を記録")
                .font(.headline)
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(HabitImprovement.HabitType.allCases, id: \.self) { habitType in
                    HabitButton(
                        habitType: habitType,
                        action: {
                            selectedHabitType = habitType
                            showingAddHabit = true
                        }
                    )
                }
            }
        }
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView(selectedType: selectedHabitType)
                .environmentObject(lifeDataManager)
        }
    }
}

// MARK: - 習慣改善ボタン
struct HabitButton: View {
    let habitType: HabitImprovement.HabitType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: habitType.icon)
                    .font(.system(size: 30))
                    .foregroundColor(habitType.color)
                
                Text(habitType.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 3)
        }
    }
}

// MARK: - 最近の改善履歴
struct RecentImprovementsList: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    
    var recentImprovements: [HabitImprovement] {
        Array(lifeDataManager.habitImprovements.prefix(10))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("最近の改善履歴")
                .font(.headline)
            
            if recentImprovements.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("まだ改善履歴がありません")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(recentImprovements) { improvement in
                        ImprovementRow(improvement: improvement)
                    }
                }
            }
        }
    }
}

// MARK: - 改善履歴行
struct ImprovementRow: View {
    let improvement: HabitImprovement
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: improvement.type.icon)
                .foregroundColor(improvement.type.color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(improvement.type.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(formatDate(improvement.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("+\(String(format: "%.1f", improvement.lifeExtension))時間")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
                
                Text("値: \(String(format: "%.1f", improvement.value))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    HabitTrackingView()
        .environmentObject(LifeDataManager())
} 