//
//  OnboardingFlowView.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import SwiftUI

struct OnboardingFlowView: View {
    @State private var router = NavigationRouter<OnboardingRoute>()
    @StateObject private var viewModel = GoalSetupViewModel()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            GoalInfoSetupView(viewModel: viewModel)
                .navigationDestination(for: OnboardingRoute.self) { route in
                    switch route {
                        
                    // 목표 이름, 기간 설정
                    case .info:
                        GoalInfoSetupView(viewModel: viewModel)
                    
                    // 목표 비율 설정
                    case .ratio:
                        GoalRatioSetupView(viewModel: viewModel)
                    }
                }
        }
        .environment(router)
    }
}

#Preview {
    OnboardingFlowView()
}
