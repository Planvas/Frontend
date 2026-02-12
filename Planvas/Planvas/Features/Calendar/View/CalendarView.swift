//
//  CalendarView.swift
//  Planvas
//
//  Created by 백지은 on 1/18/26.
//

// TODO: 여러 날에 걸쳐있는 일정 이름 표시가 첫 날 셀을 기준으로 잘림

import SwiftUI
import UIKit

struct CalendarView: View {
    @Environment(CalendarViewModel.self) private var viewModel
    /// 미연동 시 "일정 가져오기" 알림에서 "Google 캘린더 연동" 탭 시 바로 연동 API 호출 + 일정 새로고침 (Sync 뷰 없음)
    var onConnectGoogleCalendar: (() -> Void)?
    var onFinish: (() -> Void)?
    
    @State private var showScheduleSelection = false
    @State private var showImportAlert = false
    @State private var showAddEvent = false
    @State private var selectedEvent: Event?
    @State private var showEventDetail = false
    @State private var showCompleteAlert = false
    @State private var completeAlertViewModel: ActivityCompleteAlertViewModel?
    @State private var slideDirection: SlideDirection = .none
    
    enum SlideDirection {
        case none, left, right
    }
    
    var body: some View {
        ScrollView{
            VStack(spacing: 12) {
                // 상단 날짜 표시
                monthHeaderView
                
                // 달력 그리드
                calendarGridView
                
                // 선택된 날짜 상세 정보
                selectedDateDetailView
                
                Spacer()
                
                schedulegetButtonView
                
                // 하단 완료 버튼 (온보딩 과정에서만 표시, 캘린더 탭에서는 숨김)
                if onFinish != nil {
                    bottomButtonsView
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 34)
        }
        .sheet(isPresented: $showScheduleSelection) {
            ScheduleSelectionView { selectedSchedules in
                // 선택된 일정 처리
                viewModel.importSchedules(selectedSchedules)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAddEvent) {
            AddEventView(initialDate: viewModel.selectedDate) { event in
                viewModel.addEvent(event)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showEventDetail) {
            if let event = selectedEvent {
                Group {
                    if event.category == .growth || event.category == .rest {
                        ActivityEventSummaryView(
                            viewModel: ActivityEventSummaryViewModel.from(event: event, daysUntil: viewModel.getDaysUntil(for: event)),
                            event: event,
                            onDelete: {
                                viewModel.deleteEvent(event)
                                showEventDetail = false
                            },
                            onUpdateEvent: { updatedEvent in
                                viewModel.updateEvent(updatedEvent)
                                showEventDetail = false
                            },
                            onCompleteRequested: { alertVM in
                                showEventDetail = false
                                completeAlertViewModel = alertVM
                                showCompleteAlert = true
                            }
                        )
                    } else {
                        EventSummaryView(
                            event: event,
                            startDate: viewModel.getStartDate(for: event),
                            endDate: viewModel.getEndDate(for: event),
                            daysUntil: viewModel.getDaysUntil(for: event),
                            onDelete: {
                                viewModel.deleteEvent(event)
                                showEventDetail = false
                            },
                            onEdit: nil,
                            onUpdateEvent: { updatedEvent in
                                viewModel.updateEvent(updatedEvent)
                                showEventDetail = false
                            }
                        )
                    }
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
        .overlay {
            if showImportAlert {
                importAlertView
            }
        }
        .overlay {
            if showCompleteAlert, let alertVM = completeAlertViewModel {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { showCompleteAlert = false }
                    ActivityCompleteAlertView(
                        viewModel: alertVM,
                        onConfirm: { showCompleteAlert = false },
                        onDismiss: { showCompleteAlert = false }
                    )
                    .padding(.horizontal, 24)
                }
            }
        }
    }
    
    // MARK: - 일정 가져오기 알림 (연동 여부에 따라 문구 분기)
    private var importAlertView: some View {
        Group {
            if viewModel.isCalendarConnected {
                CustomAlertView(
                    title: "캘린더를 동기화하고\n새 일정을 불러올까요?",
                    message: "현재 캘린더가 연동되어 있어요",
                    messageColor: .gray44450,
                    primaryButtonTitle: "Google 캘린더 동기화",
                    secondaryButtonTitle: "취소",
                    primaryButtonAction: {
                        showImportAlert = false
                        showScheduleSelection = true
                    },
                    secondaryButtonAction: {
                        showImportAlert = false
                    }
                )
            } else {
                CustomAlertView(
                    title: "캘린더를 연동할까요?",
                    message: "현재 캘린더가 연동되어 있지 않아요",
                    messageColor: .primary1,
                    primaryButtonTitle: "Google 캘린더 연동",
                    secondaryButtonTitle: "취소",
                    primaryButtonAction: {
                        showImportAlert = false
                        onConnectGoogleCalendar?()
                    },
                    secondaryButtonAction: {
                        showImportAlert = false
                    }
                )
            }
        }
    }
    
    // MARK: - 상단 헤더 표시
    private var monthHeaderView: some View {
        HStack(alignment: .bottom) {
            Text(viewModel.monthString)
                .textStyle(.bold30)
            
            Text(viewModel.yearString)
                .textStyle(.semibold14)
                .padding(.bottom, 3)
            
            Spacer()
        }
    }
    
    // MARK: - 캘린더 그리드
    private var calendarGridView: some View {
        VStack(spacing: 3) {
            // 요일 헤더
            HStack(spacing: 0) {
                ForEach(viewModel.weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .textStyle(.semibold14)
                        .foregroundColor(.calTypo)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // 달력 날짜들
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 12) {
                ForEach(viewModel.daysInMonth, id: \.self) { date in
                    dayView(for: date)
                }
            }
            .id(viewModel.currentMonth)
            .transition(slideTransition)
        }
        .clipped()
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    let horizontalDistance = value.translation.width
                    
                    // 좌우 스와이프 감지 (수평 이동이 수직 이동보다 클 때만)
                    if abs(horizontalDistance) > abs(value.translation.height) {
                        if horizontalDistance > 0 {
                            // 오른쪽으로 스와이프 → 이전 달
                            slideDirection = .right
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.goToPreviousMonth()
                            }
                        } else {
                            // 왼쪽으로 스와이프 → 다음 달
                            slideDirection = .left
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.goToNextMonth()
                            }
                        }
                    }
                }
        )
    }
    
    // 슬라이드 방향에 따른 트랜지션
    private var slideTransition: AnyTransition {
        switch slideDirection {
        case .left:
            return .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            )
        case .right:
            return .asymmetric(
                insertion: .move(edge: .leading),
                removal: .move(edge: .trailing)
            )
        case .none:
            return .opacity
        }
    }
    
    // MARK: - Helper Methods
    
    /// 날짜 텍스트 색상 결정
    private func dayTextColor(isSelected: Bool, isCurrentMonth: Bool) -> Color {
        if isSelected {
            return .white
        } else if isCurrentMonth {
            return Color(.black1)
        } else {
            return Color(.calTypo80)
        }
    }
    
    /// 여러 날에 걸친 이벤트 막대 한 구간 (시작/중간/끝에 따라 모서리만 둥글게) + 이벤트 표시
    private func multiDayBarSegment(event: Event, isStart: Bool, isEnd: Bool, isSelected: Bool) -> some View {
        let barHeight: CGFloat = 11
        let cornerRadius: CGFloat = 2
        
        return ZStack(alignment: .leading) {
            // 막대 배경: 이벤트 색 투명도 0.3
            Rectangle()
                .fill(event.color.uiColor.opacity(0.3))
                .frame(height: barHeight)
                .clipShape(
                    RoundedCorner(
                        radius: cornerRadius,
                        corners: barSegmentCorners(isStart: isStart, isEnd: isEnd)
                    )
                )
            
            // 이벤트 표시는 시작 구간(첫날)에만, 셀 하나 크기로 표시
            if isStart {
                HStack(spacing: 3) {
                    Rectangle()
                        .foregroundColor(event.color.uiColor)
                        .frame(width: 2.5, height: 9)
                        .cornerRadius(1.25)
                    Text(event.title)
                        .textStyle(.medium10)
                        .foregroundColor(isSelected ? .white : .black1)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer(minLength: 0)
                }
                .frame(width: 46)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: barHeight)
    }
    
    private func barSegmentCorners(isStart: Bool, isEnd: Bool) -> UIRectCorner {
        switch (isStart, isEnd) {
        case (true, true): return .allCorners
        case (true, false): return [.topLeft, .bottomLeft]
        case (false, true): return [.topRight, .bottomRight]
        case (false, false): return []
        }
    }
    
    private func dayView(for date: Date) -> some View {
        let dayNumber = viewModel.dayNumber(from: date)
        let isCurrentMonth = viewModel.isDateInCurrentMonth(date)
        let isSelected = viewModel.isDateSelected(date)
        let isToday = viewModel.isDateToday(date)
        let displayEvents = viewModel.getDisplayEvents(for: date, isSelected: isSelected)
        let repeatingEvents = viewModel.getRepeatingEvents(for: date)
        let multiDaySegments = viewModel.getMultiDayEventSegments(for: date)
        
        let dateTextColor = dayTextColor(isSelected: isSelected, isCurrentMonth: isCurrentMonth)
        
        return ZStack(alignment: .top) {
            // 배경
            if isSelected {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray444)
            } else if isToday && isCurrentMonth {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ccc60)
            }
            
            // 내용
            VStack(spacing: 0) {
                // 날짜 + 반복 일정 표시 원
                ZStack{
                    HStack(spacing: 2) {
                        Text("\(dayNumber)")
                            .textStyle(.medium16)
                            .foregroundColor(dateTextColor)
                    }
                    .frame(height: 20)
                    .padding(.top, 6)
                    
                    if isCurrentMonth && !repeatingEvents.isEmpty {
                        ForEach(Array(repeatingEvents.prefix(3))) { event in
                            Circle()
                                .fill(.primary1)
                                .frame(width: 5, height: 5)
                                .offset(x:13)
                        }
                    }
                }
                
                // 여러 날에 걸친 이벤트 막대 (날짜 바로 아래)
                if isCurrentMonth && !multiDaySegments.isEmpty {
                    VStack(spacing: 2) {
                        ForEach(Array(multiDaySegments.prefix(2).enumerated()), id: \.element.event.id) { _, segment in
                            multiDayBarSegment(
                                event: segment.event,
                                isStart: segment.isStart,
                                isEnd: segment.isEnd,
                                isSelected: isSelected
                            )
                        }
                    }
                    .padding(.top, 2)
                }
                
                // 이벤트 표시 영역 (하루 단위만)
                VStack(spacing: 2) {
                    if !displayEvents.isEmpty && isCurrentMonth {
                        ForEach(displayEvents) { event in
                            HStack(spacing: 3) {
                                Rectangle()
                                    .foregroundColor(event.color.uiColor)
                                    .frame(width: 2.5, height: 9)
                                    .cornerRadius(1.25)
                                
                                Text(event.title)
                                    .textStyle(.medium10)
                                    .foregroundColor(isSelected ? .white : .black1)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Spacer(minLength: 0)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.top, 4)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(height: 79)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.selectDate(date)
        }
    }
    
    // MARK: - 오늘 일정
    private var selectedDateDetailView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 선택된 날짜 헤더
            Text(viewModel.selectedDateFullString)
                .textStyle(.bold20)
                .foregroundColor(.black1)
                .padding(.top, 12)
                .padding(.bottom, 20)
            
            // 이벤트 카드들
            VStack(spacing: 12) {
                let events = viewModel.getEvents(for: viewModel.selectedDate)
                
                ForEach(events) { event in
                    eventCardView(event: event)
                }
                
                // 직접 추가하기 카드
                addEventCardView
            }
        }
    }
    
    private func eventCardView(event: Event) -> some View {
        Button {
            selectedEvent = event
            showEventDetail = true
        } label: {
            HStack(alignment: .center, spacing: 12) {
                Rectangle()
                    .fill(event.color.uiColor)
                    .frame(width: 3, height: 33)
                    .cornerRadius(1.25)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .textStyle(.regular18)
                        .foregroundColor(.black1)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(event.time)
                        .textStyle(.regular14)
                        .foregroundColor(.gray888)
                }
                
                Spacer()
                
                if event.isFixed {
                    Text("고정")
                        .textStyle(.semibold14spacing)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: [.gradprimary1, .primary1],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.ccc60, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var addEventCardView: some View {
        Button {
            showAddEvent = true
        } label: {
            HStack {
                Image(systemName: "plus")
                    .textStyle(.bold20)
                    .foregroundColor(.gray444)

                Text("직접 추가하기")
                    .textStyle(.regular18)
                    .foregroundColor(.gray444)

                Spacer()
            }
            .padding(16)
            .frame(height: 64)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.ccc60, lineWidth: 1)
            )
        }
    }
    
    // MARK: - 일정 가져오기 버튼
    private var schedulegetButtonView: some View {
        VStack(spacing: 12) {
            SecondaryButton(title: "일정 가져오기") {
                showImportAlert = true
            }
        }
    }
    
    // MARK: - 완료 버튼
    private var bottomButtonsView: some View {
        VStack(spacing: 12) {
            PrimaryButton(title: "완료") {
                // 완료 액션 - 완료 누르면 온보딩의 관심 분야 선택 뷰로 넘어가도록
                onFinish?()
            }
        }
    }
}

#Preview("캘린더 (활동/고정 샘플)") {
    struct PreviewWrapper: View {
        @State private var viewModel = CalendarViewModel(repository: CalendarRepository())
        var body: some View {
            CalendarView(onFinish: {})
                .environment(viewModel)
                .task {
                    await viewModel.prepareForPreview(year: 2026, month: 1, day: 13)
                }
        }
    }
    return PreviewWrapper()
}
