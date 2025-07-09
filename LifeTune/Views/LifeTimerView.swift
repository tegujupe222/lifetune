import SwiftUI

struct LifeTimerView: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    @State private var showingOnboarding = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景グラデーション
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    if let lifeData = lifeDataManager.lifeData {
                        // 寿命タイマー
                        LifeTimerCircle(lifeData: lifeData)
                            .frame(width: 300, height: 300)
                        
                        // 残り時間表示
                        VStack(spacing: 10) {
                            Text("残り寿命")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 20) {
                                TimeUnitView(value: lifeData.remainingDays, unit: "日")
                                TimeUnitView(value: lifeData.remainingHours, unit: "時間")
                                TimeUnitView(value: lifeData.remainingMinutes, unit: "分")
                                TimeUnitView(value: lifeData.remainingSeconds, unit: "秒")
                            }
                        }
                        
                        // 寿命延長情報
                        if lifeDataManager.totalLifeExtension > 0 {
                            VStack(spacing: 8) {
                                HStack {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .foregroundColor(.green)
                                    Text("あなたの行動で寿命が延びました！")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                                
                                Text("+\(String(format: "%.1f", lifeDataManager.totalLifeExtension))時間")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(15)
                        }
                        
                        Spacer()
                        
                        // 今日の改善提案
                        DailySuggestionCard()
                            .environmentObject(lifeDataManager)
                        
                    } else {
                        // 初期設定画面
                        OnboardingView()
                            .environmentObject(lifeDataManager)
                    }
                }
                .padding()
            }
            .navigationTitle("LifeTune")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - 寿命タイマー円形ゲージ
struct LifeTimerCircle: View {
    let lifeData: LifeData
    
    var progress: Double {
        let totalLifeSeconds = lifeData.currentLifeExpectancy * 365.25 * 24 * 60 * 60
        let livedSeconds = Date().timeIntervalSince(lifeData.birthDate)
        return min(livedSeconds / totalLifeSeconds, 1.0)
    }
    
    var body: some View {
        ZStack {
            // 背景円
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 20)
            
            // 進行状況円
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .green]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progress)
            
            // 中央テキスト
            VStack(spacing: 5) {
                Text("\(Int(lifeData.currentLifeExpectancy))")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("歳")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("現在の予測寿命")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - 時間単位表示
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
    }
}

#Preview {
    LifeTimerView()
        .environmentObject(LifeDataManager())
} 