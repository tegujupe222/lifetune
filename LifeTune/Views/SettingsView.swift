import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    @StateObject private var openAIService = OpenAIService()
    @State private var showingDatePicker = false
    @State private var showingCountryPicker = false
    @State private var showingGenderPicker = false
    @State private var showingAPIKeyInput = false
    @State private var apiKeyInput = ""
    @State private var showingAPIKeyAlert = false
    @State private var apiKeyAlertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                // プロフィール設定
                Section(header: Text("プロフィール")) {
                    if let lifeData = lifeDataManager.lifeData {
                        ProfileInfoRow(title: "生年月日", value: formatDate(lifeData.birthDate))
                        ProfileInfoRow(title: "性別", value: lifeData.gender.displayName)
                        ProfileInfoRow(title: "国", value: lifeData.country)
                        ProfileInfoRow(title: "現在の予測寿命", value: "\(Int(lifeData.currentLifeExpectancy))歳")
                    } else {
                        Text("プロフィールが設定されていません")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("プロフィールを編集") {
                        showingDatePicker = true
                    }
                }
                
                // AI設定
                Section(header: Text("AI設定")) {
                    HStack {
                        Image(systemName: "key.fill")
                            .foregroundColor(.blue)
                        Text("OpenAI APIキー")
                        Spacer()
                        Button("設定") {
                            showingAPIKeyInput = true
                        }
                        .foregroundColor(.blue)
                    }
                    .accessibilityLabel("OpenAI APIキー設定")
                    
                    if !openAIService.errorMessage.isEmpty {
                        Text(openAIService.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                // 統計情報
                Section(header: Text("統計情報")) {
                    StatRow(title: "総寿命延長効果", value: "\(String(format: "%.1f", lifeDataManager.totalLifeExtension))時間", color: .green)
                    StatRow(title: "記録した改善", value: "\(lifeDataManager.habitImprovements.count)件", color: .blue)
                    StatRow(title: "設定した目標", value: "\(lifeDataManager.goals.count)個", color: .orange)
                    StatRow(title: "完了した目標", value: "\(lifeDataManager.goals.filter { $0.isCompleted }.count)個", color: .purple)
                }
                
                // データ管理
                Section(header: Text("データ管理")) {
                    Button("データをリセット") {
                        resetData()
                    }
                    .foregroundColor(.red)
                    .accessibilityLabel("データをリセット")
                }
                
                // アプリ情報
                Section(header: Text("アプリ情報")) {
                    InfoRow(title: "バージョン", value: "1.0.0")
                    InfoRow(title: "開発者", value: "LifeTune Team")
                    InfoRow(title: "プライバシーポリシー", value: "アプリ内で確認")
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingDatePicker) {
                ProfileSetupView()
                    .environmentObject(lifeDataManager)
            }
            .sheet(isPresented: $showingAPIKeyInput) {
                APIKeyInputView(
                    apiKey: $apiKeyInput,
                    onSave: saveAPIKey,
                    onCancel: { showingAPIKeyInput = false }
                )
            }
            .alert("APIキー設定", isPresented: $showingAPIKeyAlert) {
                Button("OK") { }
            } message: {
                Text(apiKeyAlertMessage)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    private func saveAPIKey() {
        guard !apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            apiKeyAlertMessage = "APIキーを入力してください。"
            showingAPIKeyAlert = true
            return
        }
        
        let trimmedKey = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if openAIService.setAPIKey(trimmedKey) {
            apiKeyAlertMessage = "APIキーが正常に保存されました。"
            showingAPIKeyInput = false
        } else {
            apiKeyAlertMessage = "APIキーの保存に失敗しました。"
        }
        
        showingAPIKeyAlert = true
    }
    
    private func resetData() {
        // データリセットの確認ダイアログを表示
        // 実際の実装では確認ダイアログを追加
        lifeDataManager.clearErrorMessage()
    }
}

// MARK: - プロフィール情報行
struct ProfileInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
        .accessibilityLabel("\(title)、\(value)")
    }
}

// MARK: - 統計行
struct StatRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .accessibilityLabel("\(title)、\(value)")
    }
}

// MARK: - 情報行
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
        .accessibilityLabel("\(title)、\(value)")
    }
}

// MARK: - APIキー入力ビュー
struct APIKeyInputView: View {
    @Binding var apiKey: String
    let onSave: () -> Void
    let onCancel: () -> Void
    @State private var isSecure = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("OpenAI APIキー")
                        .font(.headline)
                    
                    Text("AI機能を使用するには、OpenAI APIキーが必要です。APIキーは安全に保存され、このデバイスでのみ使用されます。")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("APIキー")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        if isSecure {
                            SecureField("sk-...", text: $apiKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            TextField("sk-...", text: $apiKey)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        Button(action: { isSecure.toggle() }) {
                            Image(systemName: isSecure ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                
                VStack(spacing: 12) {
                    Button("保存") {
                        onSave()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    Button("キャンセル") {
                        onCancel()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("APIキー設定")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
    }
}

// MARK: - プロフィール設定ビュー
struct ProfileSetupView: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var birthDate = Date()
    @State private var selectedGender = LifeData.Gender.other
    @State private var selectedCountry = "日本"
    @State private var showingGenderPicker = false
    @State private var showingCountryPicker = false
    
    private let countries = ["日本", "アメリカ", "イギリス", "ドイツ", "フランス", "カナダ", "オーストラリア", "韓国", "中国", "インド"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本情報")) {
                    DatePicker("生年月日", selection: $birthDate, displayedComponents: .date)
                        .datePickerStyle(WheelDatePickerStyle())
                    
                    HStack {
                        Text("性別")
                        Spacer()
                        Button(selectedGender.displayName) {
                            showingGenderPicker = true
                        }
                        .foregroundColor(.blue)
                    }
                    
                    HStack {
                        Text("国")
                        Spacer()
                        Button(selectedCountry) {
                            showingCountryPicker = true
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("プロフィール設定")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveProfile()
                    }
                }
            }
            .actionSheet(isPresented: $showingGenderPicker) {
                ActionSheet(
                    title: Text("性別を選択"),
                    buttons: LifeData.Gender.allCases.map { gender in
                        .default(Text(gender.displayName)) {
                            selectedGender = gender
                        }
                    } + [.cancel()]
                )
            }
            .actionSheet(isPresented: $showingCountryPicker) {
                ActionSheet(
                    title: Text("国を選択"),
                    buttons: countries.map { country in
                        .default(Text(country)) {
                            selectedCountry = country
                        }
                    } + [.cancel()]
                )
            }
        }
    }
    
    private func saveProfile() {
        lifeDataManager.setLifeData(
            birthDate: birthDate,
            gender: selectedGender,
            country: selectedCountry
        )
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    SettingsView()
        .environmentObject(LifeDataManager())
} 
} 