import SwiftUI

struct MainView: View {
    @StateObject private var lifeDataManager = LifeDataManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LifeTimerView()
                .environmentObject(lifeDataManager)
                .tabItem {
                    Image(systemName: "timer")
                    Text("寿命タイマー")
                }
                .tag(0)
            
            HabitTrackingView()
                .environmentObject(lifeDataManager)
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("習慣改善")
                }
                .tag(1)
            
            GoalsView()
                .environmentObject(lifeDataManager)
                .tabItem {
                    Image(systemName: "target")
                    Text("目標設定")
                }
                .tag(2)
            
            StatisticsView()
                .environmentObject(lifeDataManager)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("統計")
                }
                .tag(3)
            
            SettingsView()
                .environmentObject(lifeDataManager)
                .tabItem {
                    Image(systemName: "gear")
                    Text("設定")
                }
                .tag(4)
        }
        .accentColor(.green)
    }
}

#Preview {
    MainView()
} 