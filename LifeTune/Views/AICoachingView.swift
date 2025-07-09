import SwiftUI

struct AICoachingView: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    @StateObject private var openAIService = OpenAIService()
    @State private var showingChat = false
    @State private var dailyAdvice: String = ""
    @State private var isLoadingAdvice = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // エラーメッセージ表示
                    if !openAIService.errorMessage.isEmpty {
                        ErrorMessageView(message: openAIService.errorMessage) {
                            openAIService.errorMessage = ""
                        }
                    }
                    
                    // AIコーチングカード
                    AICoachingCard(
                        advice: dailyAdvice,
                        isLoading: isLoadingAdvice,
                        onRefresh: refreshAdvice
                    )
                    .environmentObject(openAIService)
                    
                    // クイックアクション
                    QuickActionsSection()
                    
                    // 目標振り返り
                    GoalReviewSection()
                        .environmentObject(openAIService)
                        .environmentObject(lifeDataManager)
                    
                    // チャットボット
                    ChatBotSection(showingChat: $showingChat)
                }
                .padding()
            }
            .navigationTitle("AIコーチ")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: refreshAdvice) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.green)
                    }
                }
            }
            .sheet(isPresented: $showingChat) {
                AIChatView()
                    .environmentObject(openAIService)
                    .environmentObject(lifeDataManager)
            }
            .onAppear {
                if dailyAdvice.isEmpty {
                    refreshAdvice()
                }
            }
        }
    }
    
    private func refreshAdvice() {
        guard let lifeData = lifeDataManager.lifeData else { return }
        
        isLoadingAdvice = true
        
        Task {
            let advice = await openAIService.getDailyAdvice(
                lifeData: lifeData,
                habitImprovements: lifeDataManager.habitImprovements
            )
            
            await MainActor.run {
                dailyAdvice = advice
                isLoadingAdvice = false
            }
        }
    }
}

// MARK: - エラーメッセージビュー
struct ErrorMessageView: View {
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - AIコーチングカード
struct AICoachingCard: View {
    @EnvironmentObject var openAIService: OpenAIService
    let advice: String
    let isLoading: Bool
    let onRefresh: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(.purple)
                
                Text("今日のAIアドバイス")
                    .font(.headline)
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if isLoading {
                VStack(spacing: 10) {
                    ProgressView()
                        .scaleEffect(1.2)
                    
                    Text("AIがアドバイスを生成中...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 100)
            } else {
                Text(advice.isEmpty ? "アドバイスを生成中..." : advice)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack {
                Text("AIコーチ")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("更新") {
                    onRefresh()
                }
                .buttonStyle(SecondaryButtonStyle())
                .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// MARK: - クイックアクションセクション
struct QuickActionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("クイックアクション")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                QuickActionButton(
                    title: "睡眠改善",
                    icon: "bed.double.fill",
                    color: .blue,
                    action: { /* 睡眠改善のアドバイス */ }
                )
                
                QuickActionButton(
                    title: "運動習慣",
                    icon: "figure.walk",
                    color: .green,
                    action: { /* 運動のアドバイス */ }
                )
                
                QuickActionButton(
                    title: "食事改善",
                    icon: "leaf.fill",
                    color: .orange,
                    action: { /* 食事のアドバイス */ }
                )
                
                QuickActionButton(
                    title: "ストレス軽減",
                    icon: "brain.head.profile",
                    color: .purple,
                    action: { /* ストレス軽減のアドバイス */ }
                )
            }
        }
    }
}

// MARK: - クイックアクションボタン
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 目標振り返りセクション
struct GoalReviewSection: View {
    @EnvironmentObject var openAIService: OpenAIService
    @EnvironmentObject var lifeDataManager: LifeDataManager
    @State private var goalReview: String = ""
    @State private var isLoadingReview = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("目標振り返り")
                    .font(.headline)
                
                Spacer()
                
                Button("生成") {
                    generateGoalReview()
                }
                .buttonStyle(SecondaryButtonStyle())
                .font(.caption)
                .disabled(isLoadingReview)
            }
            
            if isLoadingReview {
                VStack(spacing: 10) {
                    ProgressView()
                        .scaleEffect(1.0)
                    
                    Text("目標振り返りを生成中...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 80)
            } else if !goalReview.isEmpty {
                Text(goalReview)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("目標の進捗を振り返って、AIがアドバイスを生成します。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(height: 80)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
    
    private func generateGoalReview() {
        isLoadingReview = true
        
        Task {
            let review = await openAIService.generateGoalReview(
                goals: lifeDataManager.goals,
                habitImprovements: lifeDataManager.habitImprovements
            )
            
            await MainActor.run {
                goalReview = review
                isLoadingReview = false
            }
        }
    }
}

// MARK: - チャットボットセクション
struct ChatBotSection: View {
    @Binding var showingChat: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("AIチャット")
                .font(.headline)
            
            Button(action: { showingChat = true }) {
                HStack {
                    Image(systemName: "message.fill")
                        .foregroundColor(.blue)
                    
                    Text("AIコーチとチャット")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 3)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    AICoachingView()
        .environmentObject(LifeDataManager())
} 