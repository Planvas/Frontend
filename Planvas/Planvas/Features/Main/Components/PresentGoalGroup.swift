//
//  PresentGoalGroup.swift
//  Planvas
//
//  Created by 정서영 on 1/26/26.
//

import SwiftUI

// MARK: - 헤더 / 현재 세팅된 목표 그룹
struct PresentGoalGroup: View {
    var body: some View {
        VStack(alignment: .leading){
            Text("D-17")
                .textStyle(.medium20)
                .foregroundStyle(.fff)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(.primary1)
                )
                .padding(.top, 33)
            
            Text("시험 기간 전 갓생")
                .textStyle(.medium14)
                .foregroundStyle(.fff)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(.fff20)
                )
                .padding(.bottom, 14)
            
            Text("성장")
                .textStyle(.semibold20)
                .foregroundStyle(.black1)
            
            MainProgressView(
                goal: 60,
                progress: 40,
                startColor: .primary1,
                endColor: .primary2
            )
            .padding(.bottom, 10)
            
            Text("휴식")
                .textStyle(.semibold20)
                .foregroundStyle(.black1)
            
            MainProgressView(
                goal: 40,
                progress: 10,
                startColor: .gradprimary2,
                endColor: .primary1
            )
            .padding(.bottom, 50)
        }
    }
}
