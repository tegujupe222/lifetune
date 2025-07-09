import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    @State private var showProfileEdit = false
    @State private var notificationsEnabled = true
    @State private var selectedTheme: Theme = .system
    @State private var aiCoachEnabled = true
    @State private var showPremium = false
    @State private var showExportSheet = false
    @State private var showImportSheet = false
    
    var body: some View {
        NavigationView {
            List {
                // プロフィール
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.accentColor)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(lifeDataManager.lifeData?.nickname ?? "未設定")
                                .font(.title3).bold()
                            Text(lifeDataManager.lifeData?.gender.displayName ?? "性別未設定")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(lifeDataManager.lifeData?.birthDate != nil ? "\(formatDate(lifeDataManager.lifeData!.birthDate))生まれ" : "生年月日未設定")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(action: { showProfileEdit = true }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // 通知
                Section(header: Text("通知")) {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("通知を受け取る", systemImage: "bell.fill")
                    }
                }
                
                // テーマ
                Section(header: Text("テーマ")) {
                    Picker("テーマ", selection: $selectedTheme) {
                        ForEach(Theme.allCases, id: \.self) { theme in
                            Text(theme.displayName)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // AIコーチング
                Section(header: Text("AIコーチング")) {
                    Toggle(isOn: $aiCoachEnabled) {
                        Label("AIコーチングを有効にする", systemImage: "brain.head.profile")
                    }
                }
                
                // プレミアム
                Section {
                    Button(action: { showPremium = true }) {
                        Label("プレミアム管理", systemImage: "star.fill")
                            .foregroundColor(.yellow)
                    }
                }
                
                // データ管理
                Section(header: Text("データ管理")) {
                    Button(action: { showExportSheet = true }) {
                        Label("データをエクスポート", systemImage: "square.and.arrow.up")
                    }
                    Button(action: { showImportSheet = true }) {
                        Label("データをインポート", systemImage: "square.and.arrow.down")
                    }
                }
                
                // アプリ情報
                Section(header: Text("アプリ情報")) {
                    HStack {
                        Label("バージョン", systemImage: "info.circle")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Label("開発者", systemImage: "person.fill")
                        Spacer()
                        Text("igafactory")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("設定")
            .sheet(isPresented: $showProfileEdit) {
                ProfileEditView()
                    .environmentObject(lifeDataManager)
            }
            .sheet(isPresented: $showPremium) {
                PremiumView()
            }
            .sheet(isPresented: $showExportSheet) {
                DataExportView()
            }
            .sheet(isPresented: $showImportSheet) {
                DataImportView()
            }
        }
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// テーマ選択用enum
enum Theme: String, CaseIterable {
    case system, light, dark
    var displayName: String {
        switch self {
        case .system: return "システム"
        case .light: return "ライト"
        case .dark: return "ダーク"
        }
    }
}

// プロフィール編集画面（ダミー）
struct ProfileEditView: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    @Environment(\.dismiss) var dismiss
    @State private var nickname: String = ""
    @State private var gender: LifeData.Gender = .other
    @State private var birthDate: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("ニックネーム")) {
                    TextField("ニックネーム", text: $nickname)
                }
                Section(header: Text("性別")) {
                    Picker("性別", selection: $gender) {
                        ForEach(LifeData.Gender.allCases, id: \.self) { g in
                            Text(g.displayName)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("生年月日")) {
                    DatePicker("生年月日", selection: $birthDate, displayedComponents: .date)
                }
            }
            .navigationTitle("プロフィール編集")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        // 保存処理（ダミー）
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let data = lifeDataManager.lifeData {
                    nickname = data.nickname
                    gender = data.gender
                    birthDate = data.birthDate
                }
            }
        }
    }
}

// プレミアム管理画面（ダミー）
struct PremiumView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "star.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                Text("LifeTuneプレミアム")
                    .font(.title2).bold()
                Text("プレミアム機能の説明や購入管理をここに表示")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("プレミアム管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}

// データエクスポート画面（ダミー）
struct DataExportView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                Text("データエクスポート")
                    .font(.title2).bold()
                Text("ユーザーデータのエクスポート機能をここに実装")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("データエクスポート")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}

// データインポート画面（ダミー）
struct DataImportView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
                Text("データインポート")
                    .font(.title2).bold()
                Text("ユーザーデータのインポート機能をここに実装")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("データインポート")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
} 