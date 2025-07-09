import Foundation
import Combine
import Security

class OpenAIService: ObservableObject {
    @Published var isLoading = false
    @Published var lastResponse: String = ""
    @Published var errorMessage: String = ""
    
    private var apiKey: String {
        // 本番環境では環境変数から取得、開発環境ではKeychainから取得
        #if DEBUG
        return getAPIKeyFromKeychain() ?? ""
        #else
        return ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
        #endif
    }
    
    private let baseURL = "https://lifetune.vercel.app/api/openai-proxy"
    
    // MARK: - Keychain管理
    private func getAPIKeyFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "OpenAI_API_Key",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let apiKey = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return apiKey
    }
    
    private func saveAPIKeyToKeychain(_ apiKey: String) -> Bool {
        guard let data = apiKey.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "OpenAI_API_Key",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            // 既に存在する場合は更新
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: "OpenAI_API_Key"
            ]
            
            let updateAttributes: [String: Any] = [
                kSecValueData as String: data
            ]
            
            return SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary) == errSecSuccess
        }
        
        return status == errSecSuccess
    }
    
    // MARK: - APIキー設定
    func setAPIKey(_ apiKey: String) -> Bool {
        #if DEBUG
        return saveAPIKeyToKeychain(apiKey)
        #else
        // 本番環境では環境変数を使用
        return true
        #endif
    }
    
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
        // APIキーの検証
        guard !apiKey.isEmpty else {
            let errorMessage = "APIキーが設定されていません。設定画面でAPIキーを入力してください。"
            await MainActor.run {
                self.errorMessage = errorMessage
            }
            return errorMessage
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = ""
        }
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        do {
            let request = createChatRequest(prompt: prompt)
            let (data, httpResponse) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = httpResponse as? HTTPURLResponse {
                if !httpResponse.statusCode.isSuccess {
                    let errorMessage = getErrorMessage(for: httpResponse.statusCode)
                    await MainActor.run {
                        self.errorMessage = errorMessage
                    }
                    return errorMessage
                }
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            let content = openAIResponse.choices.first?.message.content ?? "申し訳ございません。応答を生成できませんでした。"
            
            await MainActor.run {
                lastResponse = content
            }
            
            return content
        } catch {
            let errorMessage = getErrorMessage(for: error)
            await MainActor.run {
                self.errorMessage = errorMessage
            }
            return errorMessage
        }
    }
    
    private func createChatRequest(prompt: String) -> URLRequest {
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30.0 // 30秒のタイムアウト
        
        let requestBody = OpenAIRequest(
            model: "gpt-3.5-turbo",
            messages: [
                Message(role: "system", content: "あなたはLifeTuneアプリのAIコーチです。健康・習慣改善の専門家ですが、ユーザーから他分野の相談が来た場合も、できる範囲で親切に日本語でアドバイスや案内をしてください。健康・習慣改善の質問には専門的なアドバイスを、その他の質問には『LifeTuneは健康・習慣改善サポートが専門ですが、できる範囲でお答えします』と前置きして返答してください。返答は1-2文で簡潔にまとめてください。"),
                Message(role: "user", content: prompt)
            ],
            max_tokens: 500,
            temperature: 0.7
        )
        
        do {
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
        } catch {
            // エンコードエラーは稀なので、基本的なエラーメッセージを返す
        }
        
        return request
    }
    
    // MARK: - エラーメッセージ生成
    private func getErrorMessage(for statusCode: Int) -> String {
        switch statusCode {
        case 400:
            return "リクエストが正しくありません。入力内容を確認してください。"
        case 401:
            return "認証エラーが発生しました。APIキーを確認してください。"
        case 403:
            return "アクセスが拒否されました。APIキーの権限を確認してください。"
        case 429:
            return "リクエストが多すぎます。しばらく時間をおいて再度お試しください。"
        case 500...599:
            return "サーバーエラーが発生しました。しばらく時間をおいて再度お試しください。"
        default:
            return "通信エラーが発生しました。インターネット接続を確認してください。"
        }
    }
    
    private func getErrorMessage(for error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "インターネットに接続されていません。"
            case .timedOut:
                return "通信がタイムアウトしました。しばらく時間をおいて再度お試しください。"
            case .cannotFindHost:
                return "サーバーに接続できません。"
            default:
                return "通信エラーが発生しました。インターネット接続を確認してください。"
            }
        }
        
        return "予期しないエラーが発生しました。しばらく時間をおいて再度お試しください。"
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

// MARK: - HTTP Status Code Extension
extension Int {
    var isSuccess: Bool {
        return 200...299 ~= self
    }
} 