//
//  MainFlowView.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import SwiftUI

struct MainFlowView: View {
    @State private var router = NavigationRouter<MainRoute>()
    @State private var onboardingViewModel: OnboardingViewModel
    
    init() {
        let provider = APIManager.shared.createProvider(for: OnboardingAPI.self)
        _onboardingViewModel = State(wrappedValue: OnboardingViewModel(provider: provider))
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            MainView()
                .navigationDestination(for: MainRoute.self) { route in
                    switch route {
                    case .main:
                        MainView()
                    case .activityDetail(let activityId):
                        ActivityDetailView(activityId: activityId)
                    case .onboarding:
                        GoalInfoSetupView()
                    case .onboardingRatio:
                        GoalRatioSetupView()
                    case .finalReport(let goalId):
                        ReportView(goalId: goalId)
                    case .activityPage:
                        ActivityListView()
                    }
                }
        }
        .environment(router)
        .environment(onboardingViewModel)
        .environment(NavigationRouter<ActivityRoute>())
        .environment(\.flowContext, .main)
        .environment(CalendarViewModel())
    }
}

#Preview {
    MainFlowView()
}
