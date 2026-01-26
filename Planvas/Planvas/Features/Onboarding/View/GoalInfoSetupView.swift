//
//  Untitled.swift
//  Planvas
//
//  Created by 황민지 on 1/22/26.
//

import SwiftUI

struct GoalInfoSetupView: View {
    @ObservedObject var viewModel: GoalSetupViewModel
    @Environment(NavigationRouter<OnboardingRoute>.self) private var router
    
    // 버튼 활성화 조건: 이름이 있고 + 시작일이 있고 + 종료일이 있을 때
    private var isSetupCompleted: Bool {
        let isNameValid = !viewModel.goalName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return isNameValid && viewModel.startDate != nil && viewModel.endDate != nil
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                
                InfoGroup
                
                Spacer().frame(height: 13)
                
                GoalNameCard(vm: viewModel)
                
                Spacer().frame(height: 10)
                
                GoalPeriodCard(vm: viewModel)
                
                Spacer()
                
                if isSetupCompleted && viewModel.expandedSection == nil {
                    PrimaryButton(title: "설정하기") {
                        print("설정 완료: \(viewModel.goalName), \(viewModel.formatDate(viewModel.startDate)) ~ \(viewModel.formatDate(viewModel.endDate))")
                        
                        // 목표 비율 설정 화면 이동
                        router.push(.ratio)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 89)
                }
            }
            .padding(.top, 125)
        }
        .ignoresSafeArea()
    }
    
    // MARK: - 멘트 그룹
    private var InfoGroup: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // 이름이 유효한지 확인 (공백 제외)
            let isNameValid = !viewModel.goalName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            
            // 이름 카드가 열려있거나, 이름이 아직 없을 때 (이름 설정히더록)
            if viewModel.expandedSection == .name || !isNameValid {
                // TODO: 사용자 이름 적용
                Text("지수님의")
                    .textStyle(.semibold30)
                    .foregroundStyle(.black1)

                HStack(spacing: 0) {
                    Text("목표 이름")
                        .textStyle(.semibold30)
                        .foregroundStyle(.primary1)

                    Text("을 설정해주세요")
                        .textStyle(.semibold30)
                        .foregroundStyle(.black1)
                }
            }
            
            // 이름 입력이 완료되었고, 기간 카드가 열려있거나 이름 카드가 닫혔을 때 (기간 설정하도록)
            else {
                HStack(spacing: 0) {
                    Text(viewModel.goalName)
                        .textStyle(.semibold30)
                        .foregroundStyle(.primary1)

                    Text("의")
                        .textStyle(.semibold30)
                        .foregroundStyle(.black1)
                }
                
                Text("목표 기간을 설정해주세요")
                    .textStyle(.semibold30)
                    .foregroundStyle(.black1)
            }
        }
        .padding(.leading, 20)
    }
    
}

#Preview {
    let router = NavigationRouter<OnboardingRoute>()
    NavigationStack(path: .constant(router.path)) {
        GoalInfoSetupView(viewModel: GoalSetupViewModel())
    }
    .environment(router)
}
