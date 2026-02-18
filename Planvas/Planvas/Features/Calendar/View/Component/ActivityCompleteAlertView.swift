//
//  ActivityCompleteAlertView.swift
//  Planvas
//
//  Created by 백지은 on 2/12/26.
//

import SwiftUI

struct ActivityCompleteAlertView: View {
    @Bindable var viewModel: ActivityCompleteAlertViewModel
    var onConfirm: () -> Void
    var onDismiss: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button {
                    onDismiss?()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray444)
                        .frame(width: 32, height: 32)
                }
                .padding(.top, 16)
                .padding(.trailing, 16)
            }

            Text("활동 완주,\n정말 고생 많았어요!")
                .textStyle(.bold25)
                .foregroundColor(.black1)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.top, 8)

            Text("목표 달성에 한 걸음 더 가까워졌네요")
                .textStyle(.medium16)
                .foregroundColor(.primary1)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

            progressCard
                .padding(.horizontal, 12)
                .padding(.top, 20)

            PrimaryButton(title: "확인", action: onConfirm)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
        }
        .background(.white)
        .cornerRadius(20)
        .task {
            guard !viewModel.isGoalLoaded else { return }
            do {
                let goal = try await MyPageViewModel.getCurrentGoal()
                viewModel.applyGoal(goal)
            } catch { }
        }
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 8) {
                Text(viewModel.category)
                    .textStyle(.semibold18)
                    .foregroundColor(.primary1)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.primary1.opacity(0.15))
                    .cornerRadius(100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 100)
                            .stroke(Color.primary1, lineWidth: 1)
                    )

                Text("+\(viewModel.growthValue) 을 반영할게요")
                    .textStyle(.semibold18)
                    .foregroundColor(.primary1)
            }

            if viewModel.isGoalLoaded {
                HStack{
                    Spacer()
                    Text("이번 기간 목표 \(viewModel.category) \(viewModel.goalPercent)% 중")
                        .textStyle(.regular14)
                        .foregroundColor(.black1)
                    Spacer()
                }

                HStack {
                    GeometryReader { geo in
                        let fillWidth = geo.size.width * viewModel.progressRatio
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 80)
                                .fill(.ccc20)
                                .frame(height: 25)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 100)
                                        .stroke(Color.primary1, lineWidth: 0.5)
                                )

                            RoundedRectangle(cornerRadius: 80)
                                .fill(
                                    LinearGradient(
                                        colors: [.gradprimary1, .primary1],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: fillWidth, height: 25)

                            Text("\(viewModel.currentPercent)%")
                                .textStyle(.medium14)
                                .foregroundColor(.white)
                                .frame(width: fillWidth, alignment: .center)
                        }
                    }
                    .frame(height: 25)

                    Text("\(viewModel.goalPercent)%")
                        .textStyle(.medium14)
                        .foregroundColor(.gray444)
                }

                Text("\(viewModel.currentPercent)% 달성!")
                    .textStyle(.bold18)
                    .foregroundColor(.black1)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(height: 25)
                .padding(.vertical, 8)
            }
        }
        .padding(20)
        .background(.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.primary1, lineWidth: 1)
        )
    }
}

#Preview {
    let vm = ActivityEventSampleData.sampleCompleteAlertViewModel()
    vm.applyGoal(GoalSuccessResponse.preview)
    return ZStack {
        Color.black.opacity(0.4).ignoresSafeArea()
        ActivityCompleteAlertView(
            viewModel: vm,
            onConfirm: {},
            onDismiss: {}
        )
        .padding(.horizontal, 24)
    }
}
