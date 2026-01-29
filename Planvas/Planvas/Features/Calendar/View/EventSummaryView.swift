//
//  EventSummaryView.swift
//  Planvas
//
//  Created by 백지은 on 1/24/26.
//

import SwiftUI

/// 이벤트 요약 뷰 - 수정하기 버튼 클릭 시 EventDetailView로 이동
struct EventSummaryView: View {
    let event: Event
    let startDate: Date
    let endDate: Date
    let daysUntil: Int?
    
    @Environment(\.dismiss) private var dismiss
    @State private var showEventDetailView = false
    
    var onDelete: (() -> Void)?
    var onEdit: (() -> Void)?
    /// 수정 저장 시 호출 (CalendarViewModel.updateEvent 연결용)
    var onUpdateEvent: ((Event) -> Void)?
    
    /// 목표 기간 계산 (시작일과 종료일이 다른 경우에만 표시)
    /// 파라미터로 전달받은 startDate/endDate 기준으로 계산
    private var targetPeriod: String? {
        let calendar = Calendar.current
        guard !calendar.isDate(startDate, inSameDayAs: endDate) else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return "\(formatter.string(from: startDate)) ~ \(formatter.string(from: endDate))"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 상단 헤더
                HeaderView
                    .padding(.top, 45)
                    .padding(.bottom, 15)
                
                // 날짜 정보 카드
                EventDateCard(
                    startDate: startDate,
                    endDate: endDate,
                    isAllDay: event.isAllDay
                )

                
                // 삭제 버튼
                Button {
                    onDelete?()
                } label: {
                    Text("활동 삭제하기")
                        .textStyle(.semibold18)
                        .foregroundColor(.primary1)
                        .underline()
                }
                .padding(.vertical, 40)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(.white)
        .sheet(isPresented: $showEventDetailView) {
            EventDetailView(
                event: event,
                startDate: startDate,
                endDate: endDate,
                daysUntil: daysUntil,
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
    
    // MARK: - HeaderView
    private var HeaderView: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 8) {
                HStack(spacing: 8) {
                    Text(event.title)
                        .textStyle(.semibold30)
                        .foregroundColor(.black1)
                }
                
                Spacer()
                
                // 수정하기 버튼
                Button {
                    showEventDetailView = true
                    onEdit?()
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
            }
            
            //뱃지
            if let daysUntil = daysUntil {
                Text("D-\(daysUntil)")
                    .textStyle(.semibold14)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.primary1)
                    .cornerRadius(8)
            }
        }
    }
    
    
    // MARK: - EventDateCard View
    struct EventDateCard: View {
        let startDate: Date
        let endDate: Date
        let isAllDay: Bool

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 15) {

                        // 시작 날짜 (한 줄 유지)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(startDate.yearString())년")
                                .textStyle(.semibold14)
                                .foregroundColor(.gray444)
                                .lineLimit(1)

                            Text(startDate.monthDayString())
                                .textStyle(.semibold20)
                                .foregroundColor(.black1)
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                        }

                        Image(systemName: "chevron.right")
                            .font(.system(size: 18))
                            .foregroundColor(.black1)

                        // 종료 날짜 (한 줄 유지)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(endDate.yearString())년")
                                .textStyle(.semibold14)
                                .foregroundColor(.gray444)
                                .lineLimit(1)

                            Text(endDate.monthDayString())
                                .textStyle(.semibold20)
                                .foregroundColor(.black1)
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                        
                        Spacer()
                        
                        if isAllDay {
                            Text("하루종일")
                                .textStyle(.semibold14)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.primary1)
                                .cornerRadius(100)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 45)
                .background(.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.ccc, lineWidth: 1)
                )
            }
        }
    }
}

#Preview {
    EventSummaryView(
        event: Event(
            title: "엄마 생신",
            time: "하루종일",
            isAllDay: true,
            color: .purple2
        ),
        startDate: Date(),
        endDate: Date(),
        daysUntil: 6
    )
}
