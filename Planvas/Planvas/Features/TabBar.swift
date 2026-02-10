//
//  TabBar.swift
//  Planvas
//
//  Created by 정서영 on 1/16/26.
//

import SwiftUI

struct TabBar: View {
    var body: some View {
        TabView {
            MainView()
                .tabItem {
                    Label("홈", systemImage: "house")
                }
            CalendarFlowView()
                .tabItem {
                    Label("캘린더", systemImage: "calendar")
                }
            ActivityView()
                .tabItem {
                    Label("활동 탐색", systemImage: "magnifyingglass")
                }
            MyPageFlowView()
                .tabItem {
                    Label("마이", systemImage: "person")
                }

        }
        .accentColor(.primary1)
    }
}

#Preview {
    TabBar()
}
