//
//  RecommendedRatioSelectionView.swift
//  Planvas
//
//  Created by 황민지 on 1/27/26.
//

import SwiftUI

struct RecommendedRatioSelectionView: View {
    @Environment(NavigationRouter<OnboardingRoute>.self) private var router
    @EnvironmentObject private var container: DIContainer
    @Environment(GoalSetupViewModel.self) private var goalVM
    @Environment(OnboardingViewModel.self) private var onboardingVM

    private func selectRatio(step: Int) {
        goalVM.ratioStep = step
        router.pop()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("내가 바라는 모습대로")
                .textStyle(.medium20)
                .foregroundStyle(.black1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 0) {
                Text("유형별 추천 비율 ")
                    .foregroundStyle(.primary1)
                
                Text("선택하기")
                    .foregroundStyle(.black1)
            }
            .textStyle(.semibold30)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer().frame(height: 40)
            
            // 로딩/에러/성공 상태 처리
            if onboardingVM.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if let msg = onboardingVM.errorMessage {
                VStack(spacing: 12) {
                    Text(msg)
                        .textStyle(.medium14)
                        .foregroundStyle(.gray888)

                    PrimaryButton(title: "다시 시도") {
                        onboardingVM.fetchRatioPresets()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(onboardingVM.ratioPresets, id: \.presetId) { preset in
                            let lines = preset.description
                                .components(separatedBy: "\n")
                                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                .filter { !$0.isEmpty }
                            
                            let shortDesc = lines.last ?? ""
                            let description = lines.dropLast().joined(separator: "\n")
                            
                            RecommendedRatioComponent(
                                title: preset.title,
                                ratioText: "성장 \(preset.growthRatio)% | 휴식 \(preset.restRatio)%",
                                description: description,
                                shortDesc: shortDesc,
                                targetText: preset.recommendedFor,
                                onSelect: {
                                    onboardingVM.selectPreset(preset)
                                    goalVM.ratioStep = preset.growthRatio / 10
                                    router.pop()
                                }
                            )
                        }
                        Spacer().frame(width: 20)
                    }
                }
                .scrollClipDisabled()
            }
            
            Spacer()
            
            // 다음 버튼
            PrimaryButton(title: "이전으로") {
                print("이전으로 버튼 클릭")
                
                // 이전으로 화면 이동 로직
                router.pop()
            }
            .padding(.bottom, 89)
            .zIndex(1)
        }
        .padding(.horizontal, 20)
        .padding(.top, 134)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .ignoresSafeArea()
        .task {
            if onboardingVM.ratioPresets.isEmpty && !onboardingVM.isLoading {
                onboardingVM.fetchRatioPresets()
            }
        }
    }
}

#Preview {
    let router = NavigationRouter<OnboardingRoute>()

    NavigationStack(path: .constant(router.path)) {
        RecommendedRatioSelectionView()
            .environment(GoalSetupViewModel())
    }
    .environment(router)
}

