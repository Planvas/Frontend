//
//  ActivitySettingsSectionView.swift
//  Planvas
//
//  AddActivityView 전용 활동치 설정 섹션.
//

import SwiftUI

struct ActivitySettingsSectionView: View {
    @Bindable var viewModel: AddActivityViewModel
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
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary1)
                            .frame(width: 45, height: 45)
                            .background(.minus)
                            .cornerRadius(8)
                    }

                    Text("\(viewModel.activityValue)")
                        .textStyle(.semibold20)
                        .foregroundColor(.black1)
                        .frame(minWidth: 50)

                    Button {
                        viewModel.incrementActivityValue()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
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

            if showRecommendation {
                HStack {
                    Text("해당 활동은 +\(viewModel.goalPercent)%을 추천해요!")
                        .textStyle(.medium14)
                        .foregroundColor(.gray444)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(.primary20)
                        .cornerRadius(10)
                }
                .padding(.top, 5)
            }
        }
        .padding(.vertical, 10)
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            let totalW = geometry.size.width
            let goal = CGFloat(max(viewModel.goalPercent, 1))
            let achievementRatio = CGFloat(viewModel.currentAchievementPercent) / goal
            let activityRatio = CGFloat(viewModel.activityValue) / goal
            let totalRatio = min(1.0, achievementRatio + activityRatio)
            let filledWidth = totalW * totalRatio
            let w1 = totalW * achievementRatio
            let w2 = filledWidth - w1

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 80)
                    .fill(.ccc20)
                    .frame(height: 25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 80)
                            .stroke(.ccc, lineWidth: 0.5)
                    )

                RoundedRectangle(cornerRadius: 80)
                    .fill(.primary20)
                    .frame(width: filledWidth + 6, height: 25)

                RoundedRectangle(cornerRadius: 80)
                    .fill(
                        LinearGradient(
                            colors: [.gradprimary1, .primary1],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: w1, height: 25)

                HStack(spacing: 0) {
                    Text("\(viewModel.currentAchievementPercent)%")
                        .textStyle(.semibold14)
                        .foregroundColor(.white)
                        .padding(.leading, 10)
                        .frame(width: w1, alignment: .leading)

                    Text(viewModel.addedPercentText)
                        .textStyle(.semibold14)
                        .foregroundColor(.primary1)
                        .frame(width: w2, alignment: .center)
                        .padding(.horizontal, 3)

                    if totalRatio < 1.0 {
                        Text("\(viewModel.goalPercent)%")
                            .textStyle(.regular14)
                            .foregroundColor(.gray444)
                            .padding(.leading, 4)
                            .padding(.trailing, 8)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .frame(height: 25)
            }
        }
        .frame(height: 25)
    }
}
