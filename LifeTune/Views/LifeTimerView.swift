import SwiftUI

struct LifeTimerView: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 寿命タイマー
                    if let lifeData = lifeDataManager.lifeData {
                        LifeTimerCard(lifeData: lifeData)
                            .accessibilityLabel("残り寿命タイマー")
                    } else {
                        OnboardingPrompt()
                    }
                    
                    // 今日の改善提案
                    DailySuggestionCard()
                        .environmentObject(lifeDataManager)
                        .accessibilityLabel("今日の改善提案")
                    
                    // 最近の改善記録
                    RecentImprovementsCard()
                        .environmentObject(lifeDataManager)
                        .accessibilityLabel("最近の改善記録")
                }
                .padding()
            }
            .navigationTitle("寿命タイマー")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - 寿命タイマーカード
struct LifeTimerCard: View {
    let lifeData: LifeData
    
    var body: some View {
        VStack(spacing: 20) {
            // 残り時間表示
            VStack(spacing: 15) {
                Text("残り寿命")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 20) {
                    TimeUnitView(value: lifeData.remainingDays, unit: "日")
                        .accessibilityLabel("残り\(lifeData.remainingDays)日")
                    
                    TimeUnitView(value: lifeData.remainingHours, unit: "時間")
                        .accessibilityLabel("残り\(lifeData.remainingHours)時間")
                    
                    TimeUnitView(value: lifeData.remainingMinutes, unit: "分")
                        .accessibilityLabel("残り\(lifeData.remainingMinutes)分")
                }
            }
            
            // 寿命延長効果
            VStack(spacing: 10) {
                Text("総寿命延長効果")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("\(String(format: "%.1f", lifeData.currentLifeExpectancy - lifeData.averageLifeExpectancy))年")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .accessibilityLabel("総寿命延長効果\(String(format: "%.1f", lifeData.currentLifeExpectancy - lifeData.averageLifeExpectancy))年")
            }
            
            // 現在の予測寿命
            VStack(spacing: 5) {
                Text("現在の予測寿命")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(Int(lifeData.currentLifeExpectancy))歳")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .accessibilityLabel("現在の予測寿命\(Int(lifeData.currentLifeExpectancy))歳")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// MARK: - オンボーディングプロンプト
struct OnboardingPrompt: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("プロフィールを設定してください")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("寿命タイマーを開始するには、生年月日や性別などの基本情報を設定してください。")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            NavigationLink(destination: SettingsView()) {
                Text("設定画面へ")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .accessibilityLabel("設定画面へ移動")
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// MARK: - 時間単位ビュー
struct TimeUnitView: View {
    let value: Int
    let unit: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text("\(value)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 60)
    }
}

// MARK: - 今日の改善提案カード
struct DailySuggestionCard: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("今日の改善提案")
                    .font(.headline)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 10) {
                SuggestionRow(
                    icon: "bed.double.fill",
                    title: "睡眠改善",
                    description: "7-8時間の睡眠を心がけましょう",
                    color: .blue
                )
                
                SuggestionRow(
                    icon: "figure.walk",
                    title: "歩数増加",
                    description: "今日は8000歩を目標に歩きましょう",
                    color: .green
                )
                
                SuggestionRow(
                    icon: "leaf.fill",
                    title: "食事改善",
                    description: "野菜を1皿追加してみましょう",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// MARK: - 提案行
struct SuggestionRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .accessibilityLabel("\(title)、\(description)")
    }
}

// MARK: - 最近の改善記録カード
struct RecentImprovementsCard: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.green)
                Text("最近の改善記録")
                    .font(.headline)
                Spacer()
            }
            
            let recentImprovements = lifeDataManager.getWeeklyImprovements()
            
            if recentImprovements.isEmpty {
                Text("まだ改善記録がありません。習慣改善を記録して、寿命を延ばしましょう！")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(recentImprovements.prefix(3)) { improvement in
                        ImprovementRow(improvement: improvement)
                    }
                }
            }
            
            NavigationLink(destination: HabitTrackingView().environmentObject(lifeDataManager)) {
                Text("詳細を見る")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .accessibilityLabel("習慣改善の詳細画面へ移動")
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
            
            Text("+\(String(format: "%.1f", improvement.lifeExtension))時間")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }
        .accessibilityLabel("\(improvement.type.displayName)、値\(String(format: "%.1f", improvement.value))、寿命延長\(String(format: "%.1f", improvement.lifeExtension))時間")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    LifeTimerView()
        .environmentObject(LifeDataManager())
} 