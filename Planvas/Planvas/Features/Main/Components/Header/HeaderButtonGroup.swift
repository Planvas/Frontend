//
//  HeaderButtonGroup.swift
//  Planvas
//
//  Created by 정서영 on 1/26/26.
//

import SwiftUI

// MARK: - 헤더 / 버튼 그룹
struct HeaderButtonGroup: View {
    @Environment(NavigationRouter<MainRoute>.self) var router
    let goalSetting: GoalSetting
    let goalId: Int
    
    var body: some View {
        VStack{
            Button {
                goalSetting == .ENDED
                ?  router.push(.finalReport(goalId: goalId))
                : router.push(.onboarding)
            } label: {
                Text(
                    goalSetting == .ENDED
                    ? "최종 리포트 확인하러 가기"
                    : "목표 설정하러 가기"
                )
                .textStyle(.semibold20)
                .foregroundStyle(.fff)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(.primary1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(
                            LinearGradient(
                                colors: [.subPurple, .primary1],
                                startPoint: UnitPoint(x: -0.1, y: 0),
                                endPoint: UnitPoint(x: 0.3, y: 1)
                            ),
                            lineWidth: 1
                        )
                )
                .padding(.vertical)
                .padding(.top, 20)
            }
            
            if goalSetting == .ENDED {
                Text("목표한 균형을")
                    .textStyle(.medium20)
                    .foregroundStyle(.subPurple)
                Text("잘 지켰는지")
                    .textStyle(.bold20)
                    .foregroundStyle(.primary1)
                    .background(.subPurple)
                Text("확인해보세요")
                    .textStyle(.medium20)
                    .foregroundStyle(.subPurple)
            } else {
                Text("이번 시즌,\n지수님이")
                    .textStyle(.medium20)
                    .foregroundStyle(.subPurple)
                    .multilineTextAlignment(.center)
                HStack(spacing: 0){
                    Text("바라는 모습")
                        .textStyle(.bold20)
                        .foregroundStyle(.primary1)
                        .background(.subPurple)
                    Text(" 은")
                        .textStyle(.medium20)
                        .foregroundStyle(.subPurple)
                }
                Text("무엇인가요?")
                    .textStyle(.medium20)
                    .foregroundStyle(.subPurple)
            }
        }
    }
}
