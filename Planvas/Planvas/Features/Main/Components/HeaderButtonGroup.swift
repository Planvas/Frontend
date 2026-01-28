//
//  HeaderButtonGroup.swift
//  Planvas
//
//  Created by 정서영 on 1/26/26.
//

import SwiftUI

// MARK: - 헤더 / 버튼 그룹
struct HeaderButtonGroup: View {
    let goalSetting: GoalSetting

    var body: some View {
        Button {
            print(
                goalSetting == .end
                ? "최종 리포트 확인하러 가기"
                : "목표 설정하러 가기"
            )
        } label: {
            Text(
                goalSetting == .end
                ? "최종 리포트 확인하러 가기"
                : "목표 설정하러 가기"
            )
            .textStyle(.semibold20)
            .foregroundStyle(.black1)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(.subPurple)
            )
            .padding(.vertical)
        }
    }
}
