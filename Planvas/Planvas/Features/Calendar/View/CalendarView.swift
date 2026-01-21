//
//  CalendarView.swift
//  Planvas
//
//  Created by 백지은 on 1/18/26.
//

// TODO: 반복 일정 표시, 2일 이상 일정 표시 해야함

import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var showScheduleSelection = false
    @State private var showAddEvent = false
    
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
                
                // 하단 버튼들
                bottomButtonsView
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
            AddEventView { event in
                // 추가된 이벤트 처리
                viewModel.addEvent(event)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
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
        }
    }
    
    private func dayView(for date: Date) -> some View {
        let dayNumber = viewModel.dayNumber(from: date)
        let isCurrentMonth = viewModel.isDateInCurrentMonth(date)
        let isSelected = viewModel.isDateSelected(date)
        let isToday = viewModel.isDateToday(date)
        let displayEvents = viewModel.getDisplayEvents(for: date, isSelected: isSelected)
        
        let dateTextColor = viewModel.dayTextColor(
            isSelected: isSelected,
            isCurrentMonth: isCurrentMonth
        )
        
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
                // 날짜 (항상 상단 고정)
                Text("\(dayNumber)")
                    .textStyle(.medium16)
                    .foregroundColor(dateTextColor)
                    .frame(height: 20)
                    .padding(.top, 6)
                
                // 이벤트 표시 영역
                VStack(spacing: 2) {
                    if !displayEvents.isEmpty && isCurrentMonth {
                        ForEach(displayEvents) { event in
                            HStack(spacing: 4) {
                                Rectangle()
                                    .foregroundColor(viewModel.eventColor(for: event))
                                    .frame(width: 2.5, height: 9)
                                    .cornerRadius(1.25)
                                
                                Text(event.title)
                                    .textStyle(.medium10)
                                    .foregroundColor(viewModel.eventColor(for: event))
                                    .lineLimit(1)
                                
                                Spacer()
                            }
                            .frame(width: 46)
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
        HStack(alignment: .center, spacing: 12) {
            Rectangle()
                .fill(viewModel.eventColor(for: event))
                .frame(width: 3, height: 33)
                .cornerRadius(1.25)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .textStyle(.regular18)
                    .foregroundColor(.black1)
                
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
                .stroke(event.isFixed == true ? .primary1 : .ccc60, lineWidth: 1)
        )
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
    
    // MARK: - 하단 버튼
    private var bottomButtonsView: some View {
        VStack(spacing: 12) {
            SecondaryButton(title: "일정 가져오기") {
                showScheduleSelection = true
            }
            
            PrimaryButton(title: "완료") {
                // 완료 액션
            }
        }
    }
}

#Preview {
    CalendarView()
}
