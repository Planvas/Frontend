//
//  OnboardingSplashView.swift
//  Planvas
//
//  Created by 황민지 on 1/30/26.
//

import SwiftUI

struct OnboardingSplashView: View {
    @State private var currentPage = 0
    
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.gradprimary1.opacity(0.2), Color.white]),
                startPoint: .bottom,
                endPoint: .top)
            .ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPage) {
                    OnboardingSplash1
                        .tag(0)
                    OnboardingSplash2
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                VStack(spacing: 17) {
                    HStack(spacing: 8) {
                        ForEach(0..<2) { index in
                            Capsule()
                                .fill(currentPage == index ? .primary20 : .gray888)
                                .frame(width: currentPage == index ? 32 : 14, height: 8)
                        }
                    }
                    
                    ZStack {
                        PrimaryButton(title: "목표 설정하러 가기") {
                            print("목표 설정하러 가기 버튼 클릭")
                            
                            
                            // TODO: 다음 화면 이동 로직
                        }
                        
                        // 비활성화 처리
                        if currentPage == 0 {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.primary1)
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.black20)

                                Text("목표 설정하러 가기")
                                    .textStyle(.semibold20)
                                    .foregroundStyle(.fff50)
                            }
                            .frame(height: 56)
                            .allowsHitTesting(true)
                        }
                    }
                    .padding(.horizontal, 20)
                    .zIndex(1)
                }
                .padding(.bottom, 90)
            }
        }
    }

    private var OnboardingSplash1: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Text("학기, 방학, 시험 기간 등...")
                .textStyle(.medium18)
                .foregroundStyle(.black1)
                .padding(.bottom, 10)
            
            HStack(spacing: 0) {
                Text("지금의 ")
                    .textStyle(.bold25)
                    .foregroundStyle(.black1)
                
                Text("시간")
                    .textStyle(.bold25)
                    .foregroundStyle(.primary1)
                
                Text("이")
                    .textStyle(.bold25)
                    .foregroundStyle(.black1)
            }
            .padding(.bottom, 1)
            
            HStack(spacing: 0) {
                Text("어떤 모습")
                    .textStyle(.bold25)
                    .foregroundStyle(.primary1)
                
                Text("으로 기억되고 싶나요?")
                    .textStyle(.bold25)
                    .foregroundStyle(.black1)
            }
            .padding(.bottom, 55)
            
            Image("OnboardingSplash1")
                .padding(.bottom, 128)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var OnboardingSplash2: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Image("OnboardingSplash2")
                .padding(.bottom, 66)
            
            Text("막연한 감 대신,")
                .textStyle(.bold22)
                .foregroundStyle(.black1)
                .padding(.bottom, 1)
            
            HStack(spacing: 0) {
                
                Text("나만의 균형")
                    .textStyle(.bold30)
                    .foregroundStyle(.primary1)
                
                Text("을 세우러 가볼까요?")
                    .textStyle(.bold22)
                    .foregroundStyle(.black1)
            }
            .padding(.bottom, 100)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    OnboardingSplashView()
}
