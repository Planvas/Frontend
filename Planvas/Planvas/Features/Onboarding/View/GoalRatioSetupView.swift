//  GoalRatioSetupView.swift
//  Planvas
//
//  Created by 황민지 on 1/23/26.
//

import SwiftUI

struct GoalRatioSetupView: View {
    @Environment(NavigationRouter<OnboardingRoute>.self) private var router
    @Environment(GoalSetupViewModel.self) private var vm
    @Environment(OnboardingViewModel.self) private var onboardingVM

    // 토글 상태를 위한 @State 변수 추가
    @State private var showGrowthActivities = false
    @State private var showRestActivities = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [.primary20, Color.white.opacity(0)]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 200)
            }
            .ignoresSafeArea(edges: .bottom)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 125)
                    
                    // 멘트 그룹
                    InfoGroup
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    
                    // 비율 설정 네모 그룹
                    RatioSetupCard()
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
                        print("성장: \(vm.growthPercent)% / 휴식: \(vm.restPercent)%")
                        // 목표 이름, 기간, 비율 저장 API 연동
                        onboardingVM.createGoal(
                            title: vm.goalName,
                            startDate: onboardingVM.formatDateForAPI(vm.startDate),
                            endDate: onboardingVM.formatDateForAPI(vm.endDate),
                            targetGrowthRatio: vm.growthPercent,
                            targetRestRatio: vm.restPercent
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 66)
                }
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(edges: .bottom)
        }
        .ignoresSafeArea(edges: .top)
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
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.bottom, 35)
    }
    
    // MARK: - 이런 활동들이 있어요~ 그룹
    private var ActivityListGroup: some View {
        VStack(alignment:.leading, spacing: 0) {
            Text("이런 활동들이 있어요!")
                .textStyle(.semibold25)
                .foregroundColor(.primary1)
                .padding(.leading, 20)
                .padding(.bottom, 36)
            
            // 성장 활동 토글 구역
            Button(action: {
                withAnimation {
                    showGrowthActivities.toggle()
                }
            }) {
                HStack {
                    Image("plant")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .padding(.leading, 20)
                
                    Text("성장 활동")
                        .textStyle(.semibold20)
                        .foregroundColor(.black1)
                    
                    Spacer()
                    
                    Image(systemName: showGrowthActivities ? "chevron.up" : "chevron.down")
                        .foregroundColor(.black1)
                        .padding(.trailing, 20)
                }
            }
            
            // 성장 활동 리스트 보이기/숨기기
            if showGrowthActivities {
                Spacer().frame(height: 12)
                
                let items = vm.growthActivityTypes
                
                VStack(alignment: .leading, spacing: 12) {
                    rowView(Array(items.prefix(3)))
                    rowView(Array(items.dropFirst(3).prefix(3)))
                    rowView(Array(items.dropFirst(6)))
                }
                .padding(.top, 12)
                .padding(.leading, 25)
                .padding(.bottom, 3)
            }
            
            Spacer().frame(height: 32)
            
            
            // 휴식 활동 토글 구역
            Button(action: {
                withAnimation {
                    showRestActivities.toggle()
                }
            }) {
                HStack {
                    Image("moon")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .padding(.leading, 20)
                    
                    Text("휴식 활동")
                        .textStyle(.semibold20)
                        .foregroundColor(.black1)
                    
                    Spacer()
                    
                    Image(systemName: showRestActivities ? "chevron.up" : "chevron.down")
                        .foregroundColor(.black1)
                        .padding(.trailing, 20)
                }
            }
            
            // 휴식 활동 리스트 보이기/숨기기
            if showRestActivities {
                Spacer().frame(height: 12)
                
                let items = vm.restActivityTypes
                
                VStack(alignment: .leading, spacing: 12) {
                    rowView(Array(items.prefix(3)))
                    rowView(Array(items.dropFirst(3).prefix(2)))
                    rowView(Array(items.dropFirst(5).prefix(2)))
                    rowView(Array(items.dropFirst(7)))
                }
                .padding(.top, 12)
                .padding(.leading, 25)
                .padding(.bottom, 3)
            }
        }
    }
    
    // MARK: - 활동 배열 한 줄씩
    private func rowView(_ rowItems: [ActivityType]) -> some View {
        HStack(spacing: 7) {
            ForEach(rowItems) { item in
                ActivityComponent(
                    emoji: item.emoji,
                    title: item.title
                )
            }
        }
    }
}

// MARK: - 프리부
#Preview {
    let router = NavigationRouter<OnboardingRoute>()
    let goalVM = GoalSetupViewModel()
    let onboardingVM = OnboardingViewModel(provider: APIManager.shared.createProvider(for: OnboardingAPI.self))

    NavigationStack {
        GoalRatioSetupView()
            .environment(goalVM)
            .environment(onboardingVM)
    }
    .environment(router)
}
