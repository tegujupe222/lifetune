import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var lifeDataManager: LifeDataManager
    @State private var birthDate = Date()
    @State private var selectedGender: LifeData.Gender = .male
    @State private var selectedCountry = "日本"
    @State private var currentStep = 0
    
    private let countries = [
        "日本", "アメリカ", "イギリス", "ドイツ", "フランス", 
        "カナダ", "オーストラリア", "韓国", "中国", "インド"
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            // ヘッダー
            VStack(spacing: 20) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("LifeTune")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("あなたの未来を奏でる寿命予測＆改善コーチ")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // ステップインジケーター
            HStack(spacing: 8) {
                ForEach(0..<3) { step in
                    Circle()
                        .fill(step <= currentStep ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                }
            }
            
            // ステップコンテンツ
            VStack(spacing: 30) {
                switch currentStep {
                case 0:
                    birthDateStep
                case 1:
                    genderStep
                case 2:
                    countryStep
                default:
                    EmptyView()
                }
            }
            .frame(height: 200)
            
            Spacer()
            
            // ナビゲーションボタン
            HStack {
                if currentStep > 0 {
                    Button("戻る") {
                        withAnimation {
                            currentStep -= 1
                        }
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                
                Spacer()
                
                Button(currentStep == 2 ? "完了" : "次へ") {
                    if currentStep == 2 {
                        completeOnboarding()
                    } else {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding()
    }
    
    // MARK: - 生年月日ステップ
    private var birthDateStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            Text("生年月日を教えてください")
                .font(.title2)
                .fontWeight(.medium)
            
            DatePicker(
                "生年月日",
                selection: $birthDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(WheelDatePickerStyle())
            .labelsHidden()
        }
    }
    
    // MARK: - 性別ステップ
    private var genderStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.fill")
                .font(.system(size: 40))
                .foregroundColor(.purple)
            
            Text("性別を選択してください")
                .font(.title2)
                .fontWeight(.medium)
            
            HStack(spacing: 20) {
                ForEach(LifeData.Gender.allCases, id: \.self) { gender in
                    GenderButton(
                        gender: gender,
                        isSelected: selectedGender == gender,
                        action: { selectedGender = gender }
                    )
                }
            }
        }
    }
    
    // MARK: - 国ステップ
    private var countryStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text("お住まいの国を選択してください")
                .font(.title2)
                .fontWeight(.medium)
            
            Picker("国", selection: $selectedCountry) {
                ForEach(countries, id: \.self) { country in
                    Text(country).tag(country)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .labelsHidden()
        }
    }
    
    // MARK: - オンボーディング完了
    private func completeOnboarding() {
        lifeDataManager.setLifeData(
            birthDate: birthDate,
            gender: selectedGender,
            country: selectedCountry
        )
    }
}

// MARK: - 性別選択ボタン
struct GenderButton: View {
    let gender: LifeData.Gender
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: gender == .male ? "person.fill" : gender == .female ? "person.fill" : "person.2.fill")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(gender.displayName)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 80, height: 80)
            .background(isSelected ? Color.green : Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - ボタンスタイル
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(Color.green)
            .cornerRadius(25)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.primary)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(25)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(LifeDataManager())
} 