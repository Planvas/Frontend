//
//  MainFlowView.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import SwiftUI

struct MainFlowView: View {
    @State private var router = NavigationRouter<MainRoute>()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            MainView()
                .navigationDestination(for: MainRoute.self) { route in
                    switch route {
                    case .main:
                        MainView()
                    case .activityDetail(let activityId):
                        ActivityDetailView(activityId: activityId)
//                    case .onboarding:
//                        OnboardingFlowView()
                    case .finalReport(let goalId):
                        ReportView(goalId: goalId)
                    }
                }
        }
        .environment(router)
        .environment(CalendarViewModel())
    }
}

#Preview {
    MainFlowView()
}
