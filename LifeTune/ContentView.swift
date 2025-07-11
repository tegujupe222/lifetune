//
//  ContentView.swift
//  LifeTune
//
//  Created by Gouta Igasaki on 2025/07/09.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var lifeDataManager = LifeDataManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 寿命タイマー画面
            LifeTimerView()
                .environmentObject(lifeDataManager)
                .tabItem {
                    Image(systemName: "timer")
                    Text("寿命タイマー")
                }
                .tag(0)
            
            // 習慣改善トラッキング画面
            HabitTrackingView()
                .environmentObject(lifeDataManager)
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("習慣改善")
                }
                .tag(1)
            
            // 目標設定画面
            GoalsView()
                .environmentObject(lifeDataManager)
                .tabItem {
                    Image(systemName: "target")
                    Text("目標設定")
                }
                .tag(2)
            
            // AIコーチング画面
            AICoachingView()
                .environmentObject(lifeDataManager)
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("AIコーチ")
                }
                .tag(3)
            
            // 統計画面
            StatisticsView()
                .environmentObject(lifeDataManager)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("統計")
                }
                .tag(4)
            
            // 設定画面
            SettingsView()
                .environmentObject(lifeDataManager)
                .tabItem {
                    Image(systemName: "gear")
                    Text("設定")
                }
                .tag(5)
        }
        .accentColor(.green)
        .onAppear {
            // 初期設定が必要な場合は設定画面に移動
            if lifeDataManager.lifeData == nil {
                selectedTab = 5
            }
        }
    }
}

#Preview {
    ContentView()
}
