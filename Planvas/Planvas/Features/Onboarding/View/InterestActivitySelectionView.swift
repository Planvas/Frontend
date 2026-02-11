//
//  InterestActivitySelectionView.swift
//  Planvas
//
//  Created by 황민지 on 1/26/26.
//

import SwiftUI

struct InterestActivitySelectionView: View {
    // TODO: 캘린더까지 연동 완료 후 이 페이지로 이동하도록 라우팅 연결해야 함
    @Environment(LoginViewModel.self) private var loginVM
    @Environment(GoalSetupViewModel.self) private var viewModel

    var onFinish: (() -> Void)?
        
    private var isStartEnabled: Bool {
        !viewModel.selectedInterestIds.isEmpty
    }
    
    var body: some View {
        VStack (spacing: 0) {
            // 멘트 그룹
            InfoGroup
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 29)
            
            // 회색 라인
            Rectangle()
                .fill(.line)
                .frame(height: 10)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 30)
            
            // 관심 분야 선택
            InterestActivitySelectionGroup
                .padding(.horizontal, 20)
            
            Spacer()
            
            // 버튼
            ZStack {
                PrimaryButton(title: "플랜바스 시작하기") {
                    // TODO: 온보딩 저장 API 연결
                    
                    let items = viewModel.interestActivityTypes
                    let selectedNumbers = items.enumerated().compactMap { index, item in
                        viewModel.selectedInterestIds.contains(item.id) ? (index + 1) : nil
                    }
                    let text = selectedNumbers.map(String.init).joined(separator: ",")
                    print("관심 분야 : \(text)")
                    
                    // 메인 화면으로 이동
                    onFinish?()
                }
                .disabled(!isStartEnabled)

                // 비활성화 오버레이
                if !isStartEnabled {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.primary1)
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.black20)

                        Text("플랜바스 시작하기")
                            .textStyle(.medium20)
                            .foregroundStyle(.fff20)
                    }
                    .frame(height: 56)
                    .allowsHitTesting(true) // 아래 버튼 탭 막기
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 66)
            .zIndex(1)
        }
        .padding(.top, 125)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .ignoresSafeArea()
    }
    
    // MARK: - 멘트 그룹
    private var InfoGroup: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 사용자 이름 연동
            Text("\(loginVM.userName.isEmpty ? "사용자" : loginVM.userName)님,")
                .textStyle(.semibold30)
                .foregroundStyle(.black1)
            
            Spacer().frame(height: 8)
            
            HStack(spacing: 0) {
                Text("어떤 활동에 ")
                    .foregroundStyle(.black1)
                Text("관심 ")
                    .foregroundStyle(.primary1)
                Text("있나요?")
                    .foregroundStyle(.black1)
            }
            .textStyle(.semibold30)
            
            Spacer().frame(height: 10)
            
            Text("딱 맞는 활동을 추천해 드릴게요")
                .textStyle(.medium20)
                .foregroundStyle(.black1)
        }
    }
    
    // MARK: - 관심 분야 선택
    private var InterestActivitySelectionGroup: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("관심 분야 선택")
                .textStyle(.semibold20)
                .foregroundStyle(.black1)
            
            Spacer().frame(height: 2)
            
            Text("최대 3개")
                .textStyle(.medium16)
                .foregroundStyle(.primary1)
                .padding(.bottom, 15)
            
            let items = viewModel.interestActivityTypes
            
            VStack(alignment: .leading, spacing: 10) {
                rowView(Array(items.prefix(3)))
                rowView(Array(items.dropFirst(3).prefix(3)))
                rowView(Array(items.dropFirst(6)))
            }
        }
    }
    
    // MARK: - 관심 분야 배열 한 줄씩
    private func rowView(_ rowItems: [InterestActivityType]) -> some View {
        HStack(spacing: 7) {
            ForEach(rowItems) { item in
                InterestActivityComponent(
                    emoji: item.emoji,
                    title: item.title,
                    isSelected: viewModel.isInterestSelected(item.id),
                    onTap: { viewModel.toggleInterest(item.id) }
                )
            }
            Spacer()
        }
    }
}

#Preview {
    InterestActivitySelectionView()
        .environment(GoalSetupViewModel())
}
