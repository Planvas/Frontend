//  GoalRatioSetupView.swift
//  Planvas
//
//  Created by 황민지 on 1/23/26.
//

import SwiftUI

struct GoalRatioSetupView: View {
    @Environment(NavigationRouter<OnboardingRoute>.self) private var router
    @ObservedObject var viewModel: GoalSetupViewModel
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 125)
                    
                    // 멘트 그룹
                    InfoGroup
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.bottom, 20)
                    
                    // 비율 설정 네모 그룹
                    RatioSetupCard(vm: viewModel)
                        .padding(.bottom, 30)
                    
                    // 유형별 추천 비율 그룹
                    RecommendedRatiosGroup
                    
                    // 회색 라인
                    Rectangle()
                        .fill(.line)
                        .frame(height: 10)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 30)
                    
                    // 이런 활동들이 있어요! 그룹
                    ActivityListGroup
                        .padding(.bottom, 48.78)
                    
                    // 다음 버튼
                    PrimaryButton(title: "다음") {
                        print("성장: \(viewModel.growthPercent)% / 휴식: \(viewModel.restPercent)%")
                        
                        // TODO: 목표 이름, 기간, 비율 설정 내용 저장하는 API 호출
                        
                        // TODO: 다음 화면 이동 로직
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 66)
                    .zIndex(1)
                }
                
                // 바닥 그라데이션
                .background(
                    VStack {
                        Spacer()
                        LinearGradient(
                            gradient: Gradient(colors: [.primary20, Color.white.opacity(0)]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        .frame(height: 200)
                    },
                    alignment: .bottom
                )
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
    }
    
    // MARK: - 맨 위 멘트 그룹
    private var InfoGroup: some View {
        VStack(alignment:.leading, spacing: 0) {
            Text("목표 기간 내 채울")
                .textStyle(.semibold30)
                .foregroundStyle(.black1)
                .padding(.bottom, 5)
            
            HStack(spacing: 0) {
                Text("활동의 비율")
                    .textStyle(.semibold30)
                    .foregroundStyle(.primary1)
                
                Text("을 설정해주세요")
                    .textStyle(.semibold30)
                    .foregroundStyle(.black1)
            }
            
            Spacer().frame(height: 10)
            
            Text("이번 기간, 어떤 모습을 원하나요?")
                .textStyle(.medium20)
                .foregroundStyle(.black1)
        }
    }
    
    // MARK: - 유형별 추천 비율 멘트 그룹
    private var RecommendedRatiosGroup: some View {
        VStack(alignment:.center, spacing: 0) {
            Text("비율 설정이 어렵다면?")
                .textStyle(.medium14)
                .foregroundStyle(.black1)
                .padding(.bottom, 7)
            
            Button(action: {
                print("유형별 추천 비율 선택 버튼 클릭")
                
                // TODO: 유형별 추천 비율 선택 화면 연결
                router.push(.recommendation)
            }) {
                Text("유형별 추천 비율 선택하기")
                    .textStyle(.semibold18)
                    .foregroundStyle(.primary1)
                    .padding(.bottom, 0.05)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .frame(height: 1.8)
                            .foregroundStyle(.primary1)
                    }
            }
        }
        .padding(.bottom, 35)
    }
    
    // MARK: - 이런 활동들이 있어요~ 그룹
    private var ActivityListGroup: some View {
        VStack(alignment:.leading, spacing: 0) {
            Text("이런 활동들이 있어요!")
                .textStyle(.semibold25)
                .foregroundColor(.primary1)
                .padding(.bottom, 15)
            
            Text("성장 활동")
                .textStyle(.medium20)
                .foregroundColor(.black1)
                .padding(.bottom, 17)
            
            // 성장 활동 리스트
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 23), count: 3),
                spacing: 18
            ) {
                ForEach(viewModel.growthActivityTypes) { item in
                    ActivityComponent(emoji: item.emoji, title: item.title, ringColor: .green60, labelColor: .green1)
                }
            }
            .padding(.bottom, 27)
            
            Text("휴식 활동")
                .textStyle(.medium20)
                .foregroundColor(.black1)
                .padding(.bottom, 17)
            
            // 휴식 활동 리스트
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 23), count: 3),
                spacing: 18
            ) {
                ForEach(viewModel.restActivityTypes) { item in
                    ActivityComponent(emoji: item.emoji, title: item.title, ringColor: .blue60, labelColor: .blue1)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - 프리부
#Preview {
    let router = NavigationRouter<OnboardingRoute>()
    NavigationStack {
        GoalRatioSetupView(viewModel: GoalSetupViewModel())
    }
    .environment(router)
}
