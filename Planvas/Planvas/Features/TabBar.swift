//
//  TabBar.swift
//  Planvas
//
//  Created by 정서영 on 1/16/26.
//

import SwiftUI

struct TabBar: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            MainView()
                .tabItem { Label("홈", systemImage: "house") }
                .tag(0)
            CalendarFlowView(selectedTab: $selectedTab, calendarTabTag: 1)
                .tabItem { Label("캘린더", systemImage: "calendar") }
                .tag(1)
            ActivityView()
                .tabItem { Label("활동 탐색", systemImage: "magnifyingglass") }
                .tag(2)
            MyPageFlowView()
                .tabItem { Label("마이", systemImage: "person") }
                .tag(3)
        }
        .accentColor(.primary1)
    }
}

#Preview {
    TabBar()
}
