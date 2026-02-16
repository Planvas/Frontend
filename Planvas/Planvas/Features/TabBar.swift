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
            try? await Task.sleep(nanoseconds: 50_000_000)

            if shouldShowSheet {
                showOnboardingSuccessSheet = true
                shouldShowSheet = false
            }
        }

        .sheet(isPresented: $showOnboardingSuccessSheet) {
            OnboardingSuccessView(
                onGoActivityList: {
                    selectedTab = 2
                },
                onGoHome: {
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
