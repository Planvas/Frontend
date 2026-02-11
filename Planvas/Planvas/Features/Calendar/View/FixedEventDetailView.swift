//
//  FixedEventDetailView.swift
//  Planvas
//
//  고정(일반) 일정 상세 뷰. 활동 모드가 아닐 때 사용.
//

import SwiftUI

struct FixedEventDetailView: View {
    let event: Event
    let startDate: Date
    let endDate: Date
    let daysUntil: Int?
    let targetPeriod: String?

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

                EventDateInfoCard(
                    startDate: startDate,
                    endDate: endDate,
                    isAllDay: event.isAllDay
                )

                infoSection

                saveButton
                    .padding(.vertical, 10)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(.white)
        .background(editEventSheet)
    }

    private var headerView: some View {
        HStack(alignment: .center, spacing: 8) {
            Rectangle()
                .fill(event.color.uiColor)
                .frame(width: 4, height: 28)
                .cornerRadius(2)

            Text(event.title)
                .textStyle(.semibold30)
                .foregroundColor(.black1)

            Spacer()
        }
    }

    private var infoSection: some View {
        VStack(spacing: 12) {
            Text("목표 균형에 영향을 주지 않는 일정이에요")
                .textStyle(.medium18)
                .foregroundColor(.primary1)

            Text("성장/휴식 활동으로\n변경할까요?")
                .textStyle(.medium20)
                .foregroundColor(.black1)
                .multilineTextAlignment(.center)

            Button {
                showEditEventView = true
            } label: {
                Text("활동으로 변경하기")
                    .textStyle(.semibold20)
                    .foregroundColor(.black1)
                    .frame(width: 255)
                    .padding(.vertical, 15)
                    .background(.subPurple)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.primary1, lineWidth: 0.5)
        )
    }

    private var saveButton: some View {
        PrimaryButton(title: "일정 수정하기") {
            showEditEventView = true
        }
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
    FixedEventDetailView(
        event: Event(
            title: "엄마 생신",
            isAllDay: true,
            color: .purple2,
            type: .activity,
            startDate: Date(),
            endDate: Date()
        ),
        startDate: Date(),
        endDate: Date(),
        daysUntil: 6,
        targetPeriod: "11/15 ~ 12/3"
    )
}
