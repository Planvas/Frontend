//
//  MainHeaderView.swift
//  Planvas
//
//  Created by 정서영 on 1/26/26.
//

import SwiftUI

// MARK: - 메인 헤더 그룹
struct MainHeaderView: View {
    let goalSetting: GoalSetting
    let stateTitle: String
    let stateDescription: String

    var body: some View {
        ZStack {
            Rectangle()
                .modifier(
                    GradientModifier(
                        startColor: .subPurple,
                        endColor: .primary1
                    )
                )

            VStack(alignment: .leading) {
                Image(.logo)
                    .resizable()
                    .frame(width: 180, height: 43)
                    .padding(.top, 60)

                Text(stateTitle)
                    .lineLimit(nil)
                    .textStyle(.semibold30)
                    .foregroundStyle(
                        goalSetting == .ing ? .black1 : .fff
                    )

                Text(stateDescription)
                    .textStyle(
                        goalSetting == .ing ? .semibold16 : .semibold20
                    )
                    .foregroundStyle(.black1)
                    .padding(.top, 10)

                if goalSetting == .ing {
                    PresentGoalGroup()
                } else {
                    HeaderButtonGroup(goalSetting: goalSetting)
                }
            }
            .padding()
        }
    }
}
