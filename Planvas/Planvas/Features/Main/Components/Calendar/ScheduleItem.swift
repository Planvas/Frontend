//
//  ScheduleItem.swift
//  Planvas
//
//  Created by 정서영 on 2/5/26.
//
import SwiftUI

// MARK: - 위클리 캘린더 하루 일정 아이템
struct ScheduleItem: View {
    let schedule: Schedule
    let date: Date
    // 일정 시작, 중간, 끝 구분
    private var position: SchedulePosition {
        schedule.position(on: date)
    }
    // 일정 제목 보여주기 구분
    private var showTitle: Bool {
        schedule.shouldShowTitle(on: date)
    }

    var body: some View {
        HStack(spacing: 1) {
            leadingBar

            if showTitle {
                titleText
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 2)
        .frame(height: 11)
        .background(
            scheduleBackground
        )
    }
}

// MARK: - 일정 extension view
private extension ScheduleItem {

    @ViewBuilder
    var leadingBar: some View {
        if position == .start || position == .single {
            RoundedRectangle(cornerRadius: 5)
                .fill(schedule.type.color)
                .frame(width: 3)
        }
    }

    var titleText: some View {
        Text(schedule.title)
            .textStyle(.medium10)
            .foregroundColor(.black1)
            .lineLimit(1)
            .clipped()
    }

    @ViewBuilder
    // 일정 시작, 중간, 끝에 따른 백그라운드 색상 도형
    var scheduleBackground: some View {
        let color = schedule.type.color.opacity(0.3)

        switch position {
        case .single:
            RoundedRectangle(cornerRadius: 2)
                .fill(color)

        case .start:
            RoundedCorner(radius: 2, corners: [.topLeft, .bottomLeft])
                .fill(color)

        case .middle:
            Rectangle()
                .fill(color)

        case .end:
            RoundedCorner(radius: 2, corners: [.topRight, .bottomRight])
                .fill(color)
        }
    }
}

#Preview {
    TabBar()
}
