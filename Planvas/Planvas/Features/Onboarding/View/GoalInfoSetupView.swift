//
//  Untitled.swift
//  Planvas
//
//  Created by 황민지 on 1/22/26.
//

import SwiftUI

// TODO: 이름 설정 전 캘린더 접근 제한 로직 추가, 색상 변경, 이름/날짜 작성하다가 허공/엔터 클릭하면 닫히기, 캘린더 날짜 사이 선 추가

struct GoalInfoSetupView: View {
    @StateObject private var viewModel = GoalSetupViewModel()
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                
                InfoGroup
                
                Spacer().frame(height: 13)
                
                GoalNameCard(vm: viewModel)
                
                Spacer().frame(height: 10)
                
                GoalPeriodCard(vm: viewModel)
                
                Spacer()
                
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
    GoalInfoSetupView()
}
