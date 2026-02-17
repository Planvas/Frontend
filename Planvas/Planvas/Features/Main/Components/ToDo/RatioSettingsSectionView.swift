//
//  RatioSettingsSectionView.swift
//  Planvas
//
//  Created by 정서영 on 2/17/26.
//

import SwiftUI

struct RatioSettingsSectionView: View {
    @Bindable var viewModel: TodoViewModel
    var showRecommendation: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("활동치 설정")
                .textStyle(.semibold20)
                .foregroundColor(.black1)

            Text("목표한 균형치에 반영돼요")
                .textStyle(.medium14)
                .foregroundColor(.primary1)
                .padding(.bottom, 5)

            VStack(alignment: .leading, spacing: 16) {

                HStack(spacing: 4) {
                    Text("현재 달성률")
                        .textStyle(.medium18)
                        .foregroundColor(.black1)

                    Text(viewModel.growthLabel)
                        .textStyle(.medium14)
                        .foregroundColor(.primary1)
                }

                progressBar

                HStack(spacing: 12) {
                    Button {
                        viewModel.decrementActivityValue()
                    } label: {
                        Image(systemName: "minus")
                            .foregroundColor(.primary1)
                            .frame(width: 45, height: 45)
                            .background(.minus)
                            .cornerRadius(8)
                    }

                    Text("\(viewModel.activityValue)")
                        .textStyle(.semibold20)
                        .frame(minWidth: 50)

                    Button {
                        viewModel.incrementActivityValue()
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .frame(width: 45, height: 45)
                            .background(.primary1)
                            .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(16)
            .background(.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.primary1, lineWidth: 0.5)
            )
        }
        .padding(.vertical, 10)
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            let totalW = geometry.size.width
            let ratio = CGFloat(viewModel.activityValue) / 100
            let filledWidth = totalW * ratio

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 80)
                    .fill(.ccc20)
                    .frame(height: 25)

                RoundedRectangle(cornerRadius: 80)
                    .fill(.primary1)
                    .frame(width: filledWidth, height: 25)
            }
        }
        .frame(height: 25)
    }
}
