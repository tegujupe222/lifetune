import Foundation
import Combine

class OpenAIService: ObservableObject {
    @Published var isLoading = false
    @Published var lastResponse: String = ""
    
    private var apiKey: String {
        // Vercel環境変数から取得（開発時はダミー値）
        return ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "dummy-key"
    }
    
    private let baseURL = "https://lifetune.vercel.app/api/openai-proxy"
    
    // MARK: - AIコーチング機能
    func getDailyAdvice(lifeData: LifeData, habitImprovements: [HabitImprovement]) async -> String {
        let prompt = createAdvicePrompt(lifeData: lifeData, habitImprovements: habitImprovements)
        return await sendChatRequest(prompt: prompt)
    }
    
    // MARK: - チャットボット機能
    func sendMessage(_ message: String, context: String = "") async -> String {
        let prompt = createChatPrompt(userMessage: message, context: context)
        return await sendChatRequest(prompt: prompt)
    }
    
    // MARK: - 目標振り返り機能
    func generateGoalReview(goals: [Goal], habitImprovements: [HabitImprovement]) async -> String {
        let prompt = createGoalReviewPrompt(goals: goals, habitImprovements: habitImprovements)
        return await sendChatRequest(prompt: prompt)
    }
    
    // MARK: - プライベートメソッド
    private func sendChatRequest(prompt: String) async -> String {
        // 開発時はダミーレスポンスを返す
        if apiKey == "dummy-key" {
            return getDummyResponse(for: prompt)
        }
        
        await MainActor.run {
            isLoading = true
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        do {
            let request = createChatRequest(prompt: prompt)
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            
            await MainActor.run {
                lastResponse = response.choices.first?.message.content ?? "申し訳ございません。応答を生成できませんでした。"
            }
            
            return lastResponse
        } catch {
            print("OpenAI API Error: \(error)")
            return "申し訳ございません。エラーが発生しました。"
        }
    }
    
    private func createChatRequest(prompt: String) -> URLRequest {
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = OpenAIRequest(
            model: "gpt-3.5-turbo",
            messages: [
                Message(role: "system", content: "あなたはLifeTuneアプリのAIコーチです。健康・習慣改善の専門家として、ユーザーの悩みや相談に対し、親身でやさしく、具体的かつ実践的な日本語アドバイスや励ましの言葉を1-2文で返してください。"),
                Message(role: "user", content: prompt)
            ],
            max_tokens: 500,
            temperature: 0.7
        )
        
        request.httpBody = try? JSONEncoder().encode(requestBody)
        return request
    }
    
    // MARK: - プロンプト生成
    private func createAdvicePrompt(lifeData: LifeData, habitImprovements: [HabitImprovement]) -> String {
        let recentImprovements = habitImprovements.suffix(7)
        let totalExtension = habitImprovements.reduce(0) { $0 + $1.lifeExtension }
        
        return """
        ユーザーの情報：
        - 年齢: \(Int(Date().timeIntervalSince(lifeData.birthDate) / 365.25 / 24 / 60 / 60))歳
        - 性別: \(lifeData.gender.displayName)
        - 現在の予測寿命: \(Int(lifeData.currentLifeExpectancy))歳
        - 総寿命延長効果: \(String(format: "%.1f", totalExtension))時間
        - 最近の改善記録: \(recentImprovements.count)件
        
        最近の習慣改善:
        \(recentImprovements.map { "- \($0.type.displayName): \(String(format: "%.1f", $0.value))" }.joined(separator: "\n"))
        
        上記の情報を基に、今日のユーザーへの励ましと具体的なアドバイスを1-2文で提供してください。
        """
    }
    
    private func createChatPrompt(userMessage: String, context: String) -> String {
        return """
        ユーザーからの相談: \(userMessage)
        \(context.isEmpty ? "" : "追加情報: \(context)")
        
        上記の相談内容に対して、健康・習慣改善の専門家として、やさしく具体的な日本語アドバイスや励ましの言葉を1-2文で返してください。
        """
    }
    
    private func createGoalReviewPrompt(goals: [Goal], habitImprovements: [HabitImprovement]) -> String {
        let activeGoals = goals.filter { !$0.isCompleted }
        let completedGoals = goals.filter { $0.isCompleted }
        
        return """
        ユーザーの目標状況：
        - アクティブな目標: \(activeGoals.count)個
        - 完了した目標: \(completedGoals.count)個
        - 最近の改善記録: \(habitImprovements.suffix(7).count)件
        
        アクティブな目標:
        \(activeGoals.map { "- \($0.title): \(Int($0.progress * 100))%完了" }.joined(separator: "\n"))
        
        上記の情報を基に、目標達成に向けた励ましと具体的なアドバイスを提供してください。
        """
    }
    
    // MARK: - ダミーレスポンス（開発用）
    private func getDummyResponse(for prompt: String) -> String {
        if prompt.contains("今日のユーザーへの励まし") {
            return "素晴らしい改善の記録ですね！今日も小さな一歩を積み重ねて、健康な未来を築いていきましょう。特に睡眠改善の記録が印象的です。"
        } else if prompt.contains("目標達成に向けた励まし") {
            return "目標に向かって着実に進んでいますね！完璧を求めすぎず、継続を大切にしてください。小さな進歩も大きな成果につながります。"
        } else {
            return "健康と習慣改善について、何かお手伝いできることはありますか？具体的なアドバイスや励ましの言葉をお届けできます。"
        }
    }
}

// MARK: - OpenAI API データモデル
struct OpenAIRequest: Codable {
    let model: String
    let messages: [Message]
    let max_tokens: Int
    let temperature: Double
}

struct Message: Codable {
    let role: String
    let content: String
}

struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

// MARK: - AIコーチングデータモデル
struct AICoachingData {
    let dailyAdvice: String
    let lastUpdated: Date
    let userMood: String?
    let suggestedActions: [String]
} 