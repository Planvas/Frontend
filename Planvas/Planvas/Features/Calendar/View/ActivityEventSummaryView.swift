//
//  ActivityEventSummaryView.swift
//  Planvas
//
//  Created by 백지은 on 2/12/26.
//

import SwiftUI

struct ActivityEventSummaryView: View {
    @Bindable var viewModel: ActivityEventSummaryViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var showEventDetailView = false

    var event: Event?
    var onDelete: (() -> Void)?
    var onEdit: (() -> Void)?
    var onComplete: (() -> Void)?
    var onUpdateEvent: ((Event) -> Void)?
    /// 시트 닫은 뒤 상위에서 완료 API 호출·목표 반영 후 완료 알림 띄울 때 사용 (활동 완료 버튼 탭 시 호출)
    var onCompleteRequested: ((ActivityCompleteAlertViewModel) async -> Void)?

    /// status DONE + type ACTIVITY 인 이미 완료된 활동일 때 true
    private var isActivityCompleted: Bool {
        event?.isCompleted == true
    }

    private var targetPeriod: String? {
        let calendar = Calendar.current
        guard !calendar.isDate(viewModel.startDate, inSameDayAs: viewModel.endDate) else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return "\(formatter.string(from: viewModel.startDate)) ~ \(formatter.string(from: viewModel.endDate))"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                headerView
                    .padding(.top, 45)
                    .padding(.bottom, 15)

                ActivityEventDateCard(
                    startDate: viewModel.startDate,
                    endDate: viewModel.endDate,
                    activityPointLabel: viewModel.activityPointLabel,
                    activityPoints: viewModel.activityPoints
                )
                .padding(.bottom, 10)

                if !isActivityCompleted {
                    Text("완료하면 목표 균형에 반영돼요!")
                        .textStyle(.regular14)
                        .foregroundColor(.gray444)
                        .multilineTextAlignment(.center)
                }

                PrimaryButton(title: viewModel.completeButtonTitle) {
                    let alertVM = ActivityCompleteAlertViewModel(
                        category: viewModel.activityPointLabel ?? "성장",
                        growthValue: viewModel.activityPoints ?? 20,
                        progressMinPercent: 0,
                        goalPercent: 0,
                        currentPercent: 0,
                        myActivityId: event?.myActivityId
                    )
                    Task { await onCompleteRequested?(alertVM) }
                }
                .disabled(isActivityCompleted)
                .opacity(isActivityCompleted ? 0.5 : 1)

                Button {
                    onDelete?()
                } label: {
                    Text(viewModel.deleteButtonTitle)
                        .textStyle(.semibold18)
                        .foregroundColor(.primary1)
                        .underline()
                }
                .padding(.vertical, 10)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(.white)
        .task {
            do {
                let goal = try await MyPageViewModel.getCurrentGoal()
                viewModel.applyCurrentGoal(goal, category: event?.category ?? .none)
            } catch { }
        }
        .sheet(isPresented: $showEventDetailView) {
            if let event = event {
                ActivityEventDetailView(
                    event: event,
                    startDate: viewModel.startDate,
                    endDate: viewModel.endDate,
                    daysUntil: viewModel.daysUntilLabel.flatMap { parseDaysUntil($0) },
                    targetPeriod: targetPeriod,
                    onEdit: nil,
                    onDelete: onDelete,
                    onSave: { showEventDetailView = false },
                    onUpdateEvent: { updatedEvent in
                        onUpdateEvent?(updatedEvent)
                        showEventDetailView = false
                    }
                )
                .presentationDragIndicator(.visible)
            }
        }
    }

    /// "D-day" → 0, "D-N" → N, "D+N" → -N
    private func parseDaysUntil(_ label: String) -> Int? {
        if label == "D-day" { return 0 }
        if label.hasPrefix("D-"), let n = Int(label.dropFirst(2)), n >= 0 { return n }
        if label.hasPrefix("D+"), let n = Int(label.dropFirst(2)), n >= 0 { return -n }
        return nil
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 8) {
                Text(viewModel.title)
                    .textStyle(.semibold22)
                    .foregroundColor(.black1)
                    .lineLimit(2)

                Spacer()

                Button {
                    showEventDetailView = true
                    onEdit?()
                } label: {
                    Text(viewModel.editButtonTitle)
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
            }

            if let label = viewModel.daysUntilLabel {
                Text(label)
                    .textStyle(.semibold14)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.primary1)
                    .cornerRadius(5)
            }
        }
    }
}

// MARK: - 활동일정용 날짜 카드
struct ActivityEventDateCard: View {
    let startDate: Date
    let endDate: Date
    /// 활동 타입 라벨 (예: "성장", "휴식"). 데이터로 전달.
    let activityPointLabel: String?
    let activityPoints: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if let label = activityPointLabel, let points = activityPoints {
                Text("\(label) +\(points)")
                    .textStyle(.semibold18)
                    .foregroundColor(.primary1)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.primary20)
                    .cornerRadius(100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 100)
                            .stroke(.primary1, lineWidth: 1)
                    )
            }

            HStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(startDate.yearString())년")
                        .textStyle(.semibold14)
                        .foregroundColor(.gray444)
                    Text(startDate.monthDayString())
                        .textStyle(.semibold20)
                        .foregroundColor(.black1)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 18))
                    .foregroundColor(.black1)

                VStack(alignment: .leading, spacing: 8) {
                    Text("\(endDate.yearString())년")
                        .textStyle(.semibold14)
                        .foregroundColor(.gray444)
                    Text(endDate.monthDayString())
                        .textStyle(.semibold20)
                        .foregroundColor(.black1)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary1.opacity(1), lineWidth: 1)
        )
    }
}

#Preview {
    let event = ActivityEventSampleData.sampleActivityEvent()
    let vm = ActivityEventSummaryViewModel.from(event: event, daysUntil: 0)
    return ActivityEventSummaryView(viewModel: vm, event: event)
}
