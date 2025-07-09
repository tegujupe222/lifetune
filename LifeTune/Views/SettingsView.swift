import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    @State private var showingResetAlert = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            List {
                // ユーザー情報セクション
                Section("ユーザー情報") {
                    if let lifeData = lifeDataManager.lifeData {
                        UserInfoRow(title: "生年月日", value: formatDate(lifeData.birthDate))
                        UserInfoRow(title: "性別", value: lifeData.gender.displayName)
                        UserInfoRow(title: "国", value: lifeData.country)
                        UserInfoRow(title: "現在の予測寿命", value: "\(Int(lifeData.currentLifeExpectancy))歳")
                    } else {
                        Text("ユーザー情報が設定されていません")
                            .foregroundColor(.secondary)
                    }
                }
                
                // アプリ設定セクション
                Section("アプリ設定") {
                    NavigationLink(destination: NotificationSettingsView()) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.blue)
                            Text("通知設定")
                        }
                    }
                    
                    NavigationLink(destination: AppearanceSettingsView()) {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .foregroundColor(.purple)
                            Text("外観設定")
                        }
                    }
                    
                    NavigationLink(destination: DataExportView()) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.green)
                            Text("データエクスポート")
                        }
                    }
                }
                
                // データ管理セクション
                Section("データ管理") {
                    Button(action: { showingResetAlert = true }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                            Text("データをリセット")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // アプリ情報セクション
                Section("アプリ情報") {
                    Button(action: { showingAbout = true }) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("アプリについて")
                        }
                    }
                    
                    HStack {
                        Image(systemName: "app.badge")
                            .foregroundColor(.orange)
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
            .alert("データリセット", isPresented: $showingResetAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("リセット", role: .destructive) {
                    resetData()
                }
            } message: {
                Text("すべてのデータが削除されます。この操作は取り消せません。")
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    private func resetData() {
        // UserDefaultsからデータを削除
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "lifeData")
        userDefaults.removeObject(forKey: "habitImprovements")
        userDefaults.removeObject(forKey: "goals")
        
        // LifeDataManagerをリセット
        lifeDataManager.lifeData = nil
        lifeDataManager.habitImprovements = []
        lifeDataManager.goals = []
        lifeDataManager.totalLifeExtension = 0
    }
}

// MARK: - ユーザー情報行
struct UserInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - 通知設定画面
struct NotificationSettingsView: View {
    @State private var dailyReminder = true
    @State private var weeklyReport = true
    @State private var goalReminders = true
    @State private var reminderTime = Date()
    
    var body: some View {
        Form {
            Section("通知設定") {
                Toggle("毎日の習慣改善リマインダー", isOn: $dailyReminder)
                Toggle("週間レポート", isOn: $weeklyReport)
                Toggle("目標達成リマインダー", isOn: $goalReminders)
            }
            
            Section("リマインダー時間") {
                DatePicker("通知時間", selection: $reminderTime, displayedComponents: .hourAndMinute)
            }
            
            Section("通知例") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("毎日のリマインダー")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("今日の習慣改善を記録して、寿命を延ばしましょう！")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("週間レポート")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("今週は+5.2時間の寿命延長効果がありました！")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("通知設定")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 外観設定画面
struct AppearanceSettingsView: View {
    @State private var selectedTheme = "システム"
    @State private var accentColor = "緑"
    
    private let themes = ["システム", "ライト", "ダーク"]
    private let accentColors = ["緑", "青", "紫", "オレンジ"]
    
    var body: some View {
        Form {
            Section("テーマ") {
                Picker("テーマ", selection: $selectedTheme) {
                    ForEach(themes, id: \.self) { theme in
                        Text(theme).tag(theme)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section("アクセントカラー") {
                Picker("アクセントカラー", selection: $accentColor) {
                    ForEach(accentColors, id: \.self) { color in
                        Text(color).tag(color)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section("プレビュー") {
                VStack(spacing: 15) {
                    Text("LifeTune")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Image(systemName: "timer")
                                .font(.title2)
                            Text("寿命タイマー")
                                .font(.caption)
                        }
                        
                        VStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.title2)
                            Text("習慣改善")
                                .font(.caption)
                        }
                        
                        VStack {
                            Image(systemName: "target")
                                .font(.title2)
                            Text("目標設定")
                                .font(.caption)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
        .navigationTitle("外観設定")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - データエクスポート画面
struct DataExportView: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    @State private var showingExportSheet = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("データエクスポート")
                .font(.title)
                .fontWeight(.bold)
            
            Text("あなたの習慣改善データをエクスポートできます")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 15) {
                DataExportItem(
                    title: "習慣改善履歴",
                    count: lifeDataManager.habitImprovements.count,
                    icon: "list.bullet"
                )
                
                DataExportItem(
                    title: "目標設定",
                    count: lifeDataManager.goals.count,
                    icon: "target"
                )
                
                DataExportItem(
                    title: "寿命延長効果",
                    value: "\(String(format: "%.1f", lifeDataManager.totalLifeExtension))時間",
                    icon: "arrow.up.circle"
                )
            }
            
            Button("エクスポート") {
                showingExportSheet = true
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(lifeDataManager.habitImprovements.isEmpty)
            
            Spacer()
        }
        .padding()
        .navigationTitle("データエクスポート")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingExportSheet) {
            ExportSheetView()
                .environmentObject(lifeDataManager)
        }
    }
}

// MARK: - データエクスポートアイテム
struct DataExportItem: View {
    let title: String
    let count: Int?
    let value: String?
    let icon: String
    
    init(title: String, count: Int, icon: String) {
        self.title = title
        self.count = count
        self.value = nil
        self.icon = icon
    }
    
    init(title: String, value: String, icon: String) {
        self.title = title
        self.count = nil
        self.value = value
        self.icon = icon
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            if let count = count {
                Text("\(count)件")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else if let value = value {
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

// MARK: - エクスポートシート
struct ExportSheetView: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("エクスポート完了")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("データが正常にエクスポートされました")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Button("完了") {
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
            .navigationTitle("エクスポート")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - アプリについて画面
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // アプリアイコン
                    Image(systemName: "heart.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    // アプリ名と説明
                    VStack(spacing: 15) {
                        Text("LifeTune")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("あなたの未来を奏でる寿命予測＆改善コーチ")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // 機能説明
                    VStack(alignment: .leading, spacing: 20) {
                        FeatureRow(
                            icon: "timer",
                            title: "寿命カウントダウン",
                            description: "リアルタイムで残り寿命を表示し、行動の重要性を実感できます"
                        )
                        
                        FeatureRow(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "習慣改善トラッキング",
                            description: "毎日の習慣改善を記録し、寿命延長効果を可視化します"
                        )
                        
                        FeatureRow(
                            icon: "target",
                            title: "目標設定",
                            description: "具体的な目標を設定し、段階的に習慣改善を進めます"
                        )
                        
                        FeatureRow(
                            icon: "chart.bar.fill",
                            title: "統計分析",
                            description: "改善効果を詳細に分析し、モチベーションを維持します"
                        )
                    }
                    
                    // 開発者情報
                    VStack(spacing: 10) {
                        Text("開発者")
                            .font(.headline)
                        
                        Text("LifeTune Team")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("バージョン 1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("アプリについて")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 機能説明行
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.green)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
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
    SettingsView()
        .environmentObject(LifeDataManager())
} 