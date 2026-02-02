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
            OnboardingSplashView()
                .navigationDestination(for: OnboardingRoute.self) { route in
                    switch route {
                        // 온보딩 스플래시 첫 화면
                        case .onboardingSplash:
                            OnboardingSplashView()
                        
                        // 온보딩 스플래시 두번째 화면
                        case .onboardingSplashSuccess:
                            OnboardingSplashSuccessView()
                        
                        // 목표 이름, 기간 설정
                        case .info:
                            GoalInfoSetupView(viewModel: viewModel)
                        
                        // 목표 비율 설정
                        case .ratio:
                            GoalRatioSetupView(viewModel: viewModel)
                        
                        // 유형별 비율 추천 선택
                        case .recommendation:
                            RecommendedRatioSelectionView(viewModel: viewModel)
                    }
                }
        }
        .environment(router)
    }
}

#Preview {
    OnboardingFlowView()
}
