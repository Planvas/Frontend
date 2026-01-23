//
//  GoalNameCard.swift
//  Planvas
//
//  Created by 황민지 on 1/22/26.
//

import SwiftUI

struct GoalNameCard: View {
    @ObservedObject var vm: GoalSetupViewModel
    @FocusState private var isFocused: Bool
    
    private var isExpanded: Bool {
        vm.expandedSection == .name
    }
    
    private var currentCornerRadius: CGFloat {
        isExpanded ? 25 : 15
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // 닫힌 상태
            if !isExpanded {
                HStack {
                    Text("이름")
                        .textStyle(.medium14)
                        .foregroundStyle(.gray888)
                        .padding(.leading, 2)

                    Spacer()

                    Text(!vm.goalName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? vm.goalName : "이름 추가")
                        .textStyle(.medium14)
                        .foregroundStyle(.black1)
                        .padding(.trailing, 2)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    open()
                }
                .padding(18)
            }

            // 열린 상태
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    Text("이름")
                        .textStyle(.semibold30)
                        .foregroundStyle(.black1)
                        .padding(.top, 26)
                        .padding(.bottom, 40)
                    
                    Text("목표 기간의 이름을 입력해주세요")
                        .textStyle(.medium14)
                        .foregroundStyle(.gray888)
                        .padding(.bottom, 5)
                    
                    TextField("기간의 이름을 적어주세요", text: $vm.goalName)
                        .textStyle(.medium16)
                        .focused($isFocused)
                        .padding()
                        .background(.white)
                        .cornerRadius(10)
                        .onSubmit {
                            close()
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    LinearGradient(
                                        stops: [
                                            .init(color: .gradprimary2, location: 0.0),
                                            .init(color: .primary1, location: 0.15)
                                        ],
                                        startPoint: UnitPoint(x: 0.02, y: 0.02),
                                        endPoint: UnitPoint(x: 1.6, y: 12.0)
                                    ),
                                    lineWidth: 1.77
                                )
                        )
                        // 글자 수 제한 로직
                        .onChange(of: vm.goalName) { vm.validateGoalName() }
                        .padding(.bottom, 2)
                    
                    // 에러 메시지 영역
                    if vm.isOverLimit {
                        Text("*이름은 최대 20자까지 입력할 수 있어요")
                            .textStyle(.medium14)
                            .foregroundStyle(.primary1)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    Spacer().frame(height: vm.isOverLimit ? 55 : 72) // 메시지 유무에 따른 간격 조정
                }
                .padding(.horizontal, 19)
            }
        }
        .background(.white)
        .cornerRadius(currentCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: currentCornerRadius)
                .stroke(.ccc, lineWidth: 0.6)
        )
        .shadow(color: .black20, radius: 4, x:0, y: 2)
        .padding(.horizontal, 20)
        .animation(.easeInOut(duration: 0.2), value: vm.isOverLimit) // 에러 메시지 애니메이션
        .onChange(of: isFocused) { oldValue, focused in
            if !focused && isExpanded {
                close()
            }
        }
    }

    // MARK: - 카드 열고 닫기
    private func open() {
        withAnimation(.easeInOut) {
            vm.expandedSection = .name
        }
        isFocused = true
    }

    private func close() {
        // 목표 이름이 공백/줄바꿈만 있다면 데이터를 빈 문자열로 초기화
        if vm.goalName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            vm.goalName = ""
        }
        
        withAnimation(.easeInOut) {
            if vm.expandedSection == .name {
                vm.expandedSection = nil
            }
        }
        isFocused = false
    }
}

// MARK: - 프리뷰
#Preview("값 없음") {
    GoalNameCard_Preview()
}

#Preview("값 있음") {
    GoalNameCard_Preview(initialName: "플랜버스")
}

private struct GoalNameCard_Preview: View {
    @State private var goalName: String

    init(initialName: String = "") {
        _goalName = State(initialValue: initialName)
    }

    var body: some View {
        ZStack {
            Color.gray.opacity(0.1)
                .ignoresSafeArea()

            GoalNameCard(vm: GoalSetupViewModel())
        }
    }
}

