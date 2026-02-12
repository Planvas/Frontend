//
//  TabBar.swift
//  Planvas
//
//  Created by 정서영 on 1/16/26.
//

import SwiftUI

struct TabBar: View {
    @State private var selectedTab = 0
    
    @AppStorage("shouldShowOnboardingSuccessSheet") private var shouldShowSheet: Bool = false
    @State private var showOnboardingSuccessSheet = false

    var body: some View {
        TabView(selection: $selectedTab) {
            MainFlowView()
                .tabItem { Label("홈", systemImage: "house") }
                .tag(0)
            CalendarFlowView(selectedTab: $selectedTab, calendarTabTag: 1)
                .tabItem { Label("캘린더", systemImage: "calendar") }
                .tag(1)
            ActivityFlowView()
                .tabItem { Label("활동 탐색", systemImage: "magnifyingglass") }
                .tag(2)
            MyPageFlowView()
                .tabItem { Label("마이", systemImage: "person") }
                .tag(3)
        }
        .accentColor(.primary1)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            try? await Task.sleep(nanoseconds: 50_000_000) // 루트 전환 타이밍 안정화

            if shouldShowSheet {
                showOnboardingSuccessSheet = true

                // ⚠️ 반드시 다시 false로 내려줘야
                // 기존 목표 사용자나 재진입 시 깜빡임 방지
                shouldShowSheet = false
            }
        }

        .sheet(isPresented: $showOnboardingSuccessSheet) {
            OnboardingSuccessView(
                onGoActivityList: {
                    // 🔹 추천 활동으로 채우기 → 활동탐색 탭으로 이동
                    selectedTab = 2
                },
                onGoHome: {
                    // 🔹 홈으로 가기 → 홈 탭으로 이동
                    selectedTab = 0
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .presentationBackground(.white)
        }
    }
}

#Preview {
    TabBar()
}
