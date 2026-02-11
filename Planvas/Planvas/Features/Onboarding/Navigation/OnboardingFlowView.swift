//
//  OnboardingFlowView.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import SwiftUI

struct OnboardingFlowView: View {
    @State private var router = NavigationRouter<OnboardingRoute>()
    @EnvironmentObject private var container: DIContainer
    @State private var showOnboardingSuccessSheet = false
    
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
                            GoalInfoSetupView()
                        
                        // 목표 비율 설정
                        case .ratio:
                            GoalRatioSetupView()
                        
                        // 유형별 비율 추천 선택
                        case .recommendation:
                            RecommendedRatioSelectionView()
                        
                        // 관심 분야 선택
                        case .interest:
                            InterestActivitySelectionView(
                                onFinish: {
                                    // 먼저 메인으로 push
                                    router.push(.mainPage)
                                    
                                    // 그 다음 프레임에 sheet 띄우기
                                    DispatchQueue.main.async {
                                        showOnboardingSuccessSheet = true
                                    }
                                }
                            )
                        
                        // 메인 페이지
                        case .mainPage:
                                MainView()
                    }
                }
        }
        .environment(router)
        .environment(container.goalVM)
        .environment(container.onboardingVM)
        .environment(container.loginVM)
        .sheet(isPresented: $showOnboardingSuccessSheet, onDismiss: {
            showOnboardingSuccessSheet = false
        }) {
            OnboardingSuccessView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(.white)
        }
    }
}

#Preview {
    OnboardingFlowView()
}
