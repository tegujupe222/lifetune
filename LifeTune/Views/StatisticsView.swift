import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 総合統計
                    OverallStatsCard()
                        .environmentObject(lifeDataManager)
                    
                    // 週間・月間統計
                    PeriodStatsSection()
                        .environmentObject(lifeDataManager)
                    
                    // 習慣別統計
                    HabitTypeStatsSection()
                        .environmentObject(lifeDataManager)
                    
                    // 改善履歴グラフ
                    ImprovementHistorySection()
                        .environmentObject(lifeDataManager)

                    // --- AIコーチに相談ボタン追加 ---
                    NavigationLink(destination: AICoachingView().environmentObject(lifeDataManager)) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .font(.title2)
                            Text("AIコーチに相談")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(16)
                        .shadow(radius: 5)
                    }
                    .padding(.top, 16)
                    // --- ここまで追加 ---
                }
                .padding()
            }
            .navigationTitle("統計")
            .navigationBarTitleDisplayMode(.large)
        }
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
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                StatItem(
                    title: "総寿命延長",
                    value: "\(String(format: "%.1f", lifeDataManager.totalLifeExtension))時間",
                    icon: "arrow.up.circle.fill",
                    color: .green
                )
                
                StatItem(
                    title: "改善記録数",
                    value: "\(lifeDataManager.habitImprovements.count)回",
                    icon: "list.bullet",
                    color: .blue
                )
                
                StatItem(
                    title: "アクティブ目標",
                    value: "\(lifeDataManager.goals.filter { !$0.isCompleted }.count)個",
                    icon: "target",
                    color: .orange
                )
                
                StatItem(
                    title: "完了目標",
                    value: "\(lifeDataManager.goals.filter { $0.isCompleted }.count)個",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
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
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

// MARK: - 期間別統計セクション
struct PeriodStatsSection: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    
    var weeklyImprovements: [HabitImprovement] {
        lifeDataManager.getWeeklyImprovements()
    }
    
    var monthlyImprovements: [HabitImprovement] {
        lifeDataManager.getMonthlyImprovements()
    }
    
    var weeklyExtension: Double {
        weeklyImprovements.reduce(0) { $0 + $1.lifeExtension }
    }
    
    var monthlyExtension: Double {
        monthlyImprovements.reduce(0) { $0 + $1.lifeExtension }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("期間別統計")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                PeriodStatCard(
                    title: "今週",
                    extension: weeklyExtension,
                    count: weeklyImprovements.count,
                    color: .blue
                )
                
                PeriodStatCard(
                    title: "今月",
                    extension: monthlyExtension,
                    count: monthlyImprovements.count,
                    color: .green
                )
            }
        }
    }
}

// MARK: - 期間統計カード
struct PeriodStatCard: View {
    let title: String
    let `extension`: Double
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
            
            Text("+\(String(format: "%.1f", `extension`))時間")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            Text("\(count)回の改善")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}

// MARK: - 習慣別統計セクション
struct HabitTypeStatsSection: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    
    var improvementsByType: [HabitImprovement.HabitType: [HabitImprovement]] {
        lifeDataManager.getImprovementsByType()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("習慣別統計")
                .font(.headline)
            
            LazyVStack(spacing: 10) {
                ForEach(HabitImprovement.HabitType.allCases, id: \.self) { habitType in
                    HabitTypeStatRow(
                        habitType: habitType,
                        improvements: improvementsByType[habitType] ?? []
                    )
                }
            }
        }
    }
}

// MARK: - 習慣別統計行
struct HabitTypeStatRow: View {
    let habitType: HabitImprovement.HabitType
    let improvements: [HabitImprovement]
    
    var totalExtension: Double {
        improvements.reduce(0) { $0 + $1.lifeExtension }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: habitType.icon)
                .foregroundColor(habitType.color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(habitType.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(improvements.count)回記録")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("+\(String(format: "%.1f", totalExtension))時間")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
                
                if !improvements.isEmpty {
                    Text("平均: +\(String(format: "%.1f", totalExtension / Double(improvements.count)))時間/回")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

// MARK: - 改善履歴セクション
struct ImprovementHistorySection: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    
    var recentImprovements: [HabitImprovement] {
        Array(lifeDataManager.habitImprovements.suffix(7)) // 最近7件
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
                VStack(spacing: 8) {
                    ForEach(recentImprovements.reversed()) { improvement in
                        HistoryRow(improvement: improvement)
                    }
                }
            }
        }
    }
}

// MARK: - 履歴行
struct HistoryRow: View {
    let improvement: HabitImprovement
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: improvement.type.icon)
                .foregroundColor(improvement.type.color)
                .frame(width: 16)
            
            Text(improvement.type.displayName)
                .font(.caption)
                .fontWeight(.medium)
            
            Spacer()
            
            Text("+\(String(format: "%.1f", improvement.lifeExtension))時間")
                .font(.caption)
                .foregroundColor(.green)
            
            Text(formatDate(improvement.date))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    StatisticsView()
        .environmentObject(LifeDataManager())
} 