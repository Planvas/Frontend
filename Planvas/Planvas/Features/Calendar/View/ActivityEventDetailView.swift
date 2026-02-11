//
//  ActivityEventDetailView.swift
//  Planvas
//
//  활동 일정 상세 뷰. AddActivityView와 동일한 구조(헤더 → 목표기간 → 진행기간 → 활동치 설정 → 버튼).
//

import SwiftUI

struct ActivityEventDetailView: View {
    let event: Event
    let startDate: Date
    let endDate: Date
    let daysUntil: Int?
    let targetPeriod: String?

    @State private var viewModel = EventDetailViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showEditEventView = false

    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    var onSave: (() -> Void)?
    var onUpdateEvent: ((Event) -> Void)?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                    .padding(.top, 45)

                if let targetPeriod = viewModel.targetPeriod, !targetPeriod.isEmpty {
                    TargetPeriodPill(targetPeriod: targetPeriod)
                        .padding(.vertical, 10)
                }

                periodSection

                activitySettingsSection

                PrimaryButton(title: "일정 수정하기") {
                    showEditEventView = true
                }
                .padding(.vertical, 10)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(.white)
        .background(editEventSheet)
        .onAppear {
            viewModel.configure(
                event: event,
                startDate: startDate,
                endDate: endDate,
                daysUntil: daysUntil,
                targetPeriod: targetPeriod
            )
        }
    }

    // MARK: - Header (AddActivityView와 동일: 보라 세로바 + 제목)
    private var headerView: some View {
        HStack(alignment: .top, spacing: 8) {
            Rectangle()
                .fill(event.color.uiColor)
                .frame(width: 4, height: 28)
                .cornerRadius(2)
                .padding(.vertical, 5)

            Text(event.title)
                .textStyle(.semibold30)
                .foregroundColor(.black1)

            Spacer()
        }
    }

    // MARK: - 진행기간 (AddActivityView와 동일 구조, 수정하기 → EditEvent 시트)
    private var periodSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("진행기간")
                .textStyle(.semibold20)
                .foregroundColor(.black1)

            HStack(spacing: 30) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(viewModel.startDate.yearString())년")
                        .textStyle(.semibold14)
                        .foregroundColor(.gray444)
                    Text(viewModel.startDate.monthDayString())
                        .textStyle(.semibold20)
                        .foregroundColor(.black1)
                    Button {
                        showEditEventView = true
                    } label: {
                        Text("수정하기")
                            .textStyle(.semibold14)
                            .foregroundColor(.gray44450)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .cornerRadius(100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 100)
                                    .stroke(.ccc, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 18))
                    .foregroundColor(.black1)
                    .padding(.horizontal, 10)

                VStack(alignment: .leading, spacing: 8) {
                    Text("\(viewModel.endDate.yearString())년")
                        .textStyle(.semibold14)
                        .foregroundColor(.gray444)
                    Text(viewModel.endDate.monthDayString())
                        .textStyle(.semibold20)
                        .foregroundColor(.black1)
                    Button {
                        showEditEventView = true
                    } label: {
                        Text("수정하기")
                            .textStyle(.semibold14)
                            .foregroundColor(.gray44450)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white)
                            .cornerRadius(100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 100)
                                    .stroke(.ccc, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color.bar)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.ccc, lineWidth: 0.5)
            )
        }
    }

    // MARK: - 활동치 설정 (AddActivityView와 동일 구조, EventDetailViewModel 사용)
    private var activitySettingsSection: some View {
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

    private var editEventSheet: some View {
        EmptyView()
            .sheet(isPresented: $showEditEventView) {
                EditEventView(
                    event: event,
                    startDate: startDate,
                    endDate: endDate,
                    onSave: { updatedEvent in
                        onUpdateEvent?(updatedEvent)
                    }
                )
                .presentationDragIndicator(.visible)
            }
    }
}

#Preview {
    ActivityEventDetailView(
        event: Event(
            title: "패스트 캠퍼스 2026 AI 대전환 오픈 세미나",
            isAllDay: false,
            color: .purple2,
            type: .activity,
            startDate: Date(),
            endDate: Date(),
            startTime: Time(hour: 14, minute: 0),
            endTime: Time(hour: 15, minute: 0),
            category: .growth
        ),
        startDate: Date(),
        endDate: Date(),
        daysUntil: 6,
        targetPeriod: "12/15 ~ 2/28"
    )
}
