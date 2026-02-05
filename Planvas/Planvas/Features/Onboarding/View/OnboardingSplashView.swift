//
//  OnboardingSplashView.swift
//  Planvas
//
//  Created by 황민지 on 1/30/26.
//

import SwiftUI

struct OnboardingSplashView: View {
    @Environment(NavigationRouter<OnboardingRoute>.self) private var router
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.gradprimary1.opacity(0.2), Color.white]),
                startPoint: .bottom,
                endPoint: .top)
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                Image("OnboardingSplash")
                    .padding(.bottom, 81)
                
                Text("막연한 감 대신,")
                    .textStyle(.semibold22)
                    .foregroundStyle(.black1)
                    .padding(.bottom, 1)
                
                HStack(spacing: 0) {
                    
                    Text("나만의 균형")
                        .textStyle(.semibold25)
                        .foregroundStyle(.primary1)
                    
                    Text("을 세우러 가볼까요?")
                        .textStyle(.semibold22)
                        .foregroundStyle(.black1)
                }
                .padding(.bottom, 115)
                
                // 목표 설정하러 가기 버튼
                PrimaryButton(title: "목표 설정하러 가기") {
                    print("목표 설정하러 가기 버튼 클릭")
                    
                    // 온보딩 스플래시 두번째 화면 이동 로직
                    router.push(.onboardingSplashSuccess)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 66)
                .zIndex(1)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
    
}

#Preview {
    OnboardingSplashView()
        .environment(NavigationRouter<OnboardingRoute>())
}
