//
//  OnboardingFlowView.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import SwiftUI

struct OnboardingFlowView: View {
    @State private var router = NavigationRouter<OnboardingRoute>()
    @Environment(RootRouter.self) private var rootRouter
    @EnvironmentObject private var container: DIContainer
    
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
                        
                        // 캘린더
                        case .calendar:
                            CalendarFlowView(
                                selectedTab: .constant(1),
                                calendarTabTag: 1,
                                onFinishFromOnboarding: { router.push(.interest) },
                                
                                onSyncStateChange: { isConnected in
                                    container.goalVM.isCalendarConnected = isConnected
                                    print("캘린더 연동 상태 업데이트: \(isConnected)")
                                }
                            )
                            
                        // 관심 분야 선택
                        case .interest:
                            InterestActivitySelectionView(
                                onFinish: {
                                    UserDefaults.standard.set(true, forKey: "shouldShowOnboardingSuccessSheet")

                                  rootRouter.root = .main
                                }
                            )
                        

                        case .activityList:
                            ActivityFlowView()
                    }
                }
        }
        .environment(router)
        .environment(container.goalVM)
        .environment(container.onboardingVM)
        .environment(container.loginVM)
        .environment(\.flowContext, .onboarding)
    }
}

#Preview {
    OnboardingFlowView()
        .environmentObject(DIContainer())
}
