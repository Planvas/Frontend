//
//  ActivityEventDetailView.swift
//  Planvas
//
//  활동 일정 수정 뷰. 수정 가능한 항목은 날짜(진행기간)와 활동치뿐.
//  고정 일정 수정은 EditEventView로, 활동 일정 수정은 이 뷰로 연결됩니다.
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
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false

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

                PrimaryButton(title: "저장") {
                    if let updated = viewModel.buildUpdatedEvent() {
                        onUpdateEvent?(updated)
                        onSave?()
                    }
                }
                .padding(.vertical, 10)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(.white)
        .onAppear {
            viewModel.configure(
                event: event,
                startDate: startDate,
                endDate: endDate,
                daysUntil: daysUntil,
                targetPeriod: targetPeriod
            )
        }
        .onChange(of: viewModel.startDate) { viewModel.updateTargetPeriodFromDates() }
        .onChange(of: viewModel.endDate) { viewModel.updateTargetPeriodFromDates() }
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

    // MARK: - 진행기간 (AddActivityView와 동일: 수정하기 탭 시 휠 픽커 표시)
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
                        .foregroundColor(showStartDatePicker ? .primary1 : .black1)
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showEndDatePicker = false
                            showStartDatePicker.toggle()
                        }
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
                        .foregroundColor(showEndDatePicker ? .primary1 : .black1)
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showStartDatePicker = false
                            showEndDatePicker.toggle()
                        }
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

            if showStartDatePicker {
                startDatePicker
            }

            if showEndDatePicker {
                endDatePicker
            }
        }
    }

    private var startDatePicker: some View {
        DatePicker(
            "",
            selection: Binding(
                get: { viewModel.startDate },
                set: { viewModel.startDate = $0 }
            ),
            in: Date()...viewModel.endDate,
            displayedComponents: .date
        )
        .datePickerStyle(.wheel)
        .labelsHidden()
        .environment(\.locale, Locale(identifier: "ko_KR"))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private var endDatePicker: some View {
        DatePicker(
            "",
            selection: Binding(
                get: { viewModel.endDate },
                set: { viewModel.endDate = $0 }
            ),
            in: viewModel.startDate...Date.distantFuture,
            displayedComponents: .date
        )
        .datePickerStyle(.wheel)
        .labelsHidden()
        .environment(\.locale, Locale(identifier: "ko_KR"))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    // MARK: - 활동치 설정 (ActivitySettingsSectionView 공통 사용)
    private var activitySettingsSection: some View {
        ActivitySettingsSectionView(viewModel: viewModel, showRecommendation: false)
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
