//
//  AddEventView.swift
//  Planvas
//
//  Created by 백지은 on 1/21/26.
//

import SwiftUI

struct AddEventView: View {
    /// 캘린더에서 선택된 날짜 (있으면 해당 날짜 + 현재 시간으로 시작/종료일 설정)
    var initialDate: Date?
    var onAdd: ((Event) -> Void)?

    @State private var viewModel: AddEventViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showRepeatPicker = false
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false
    @State private var showRepeatEndDatePicker = false

    init(initialDate: Date? = nil, onAdd: ((Event) -> Void)? = nil) {
        self.initialDate = initialDate
        self.onAdd = onAdd
        _viewModel = State(initialValue: AddEventViewModel(initialDate: initialDate))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // 이벤트 이름 입력
                eventNameInputView
                    .padding(.top, 45)
                
                // 날짜/시간 선택
                dateTimeSelectionView
                
                // 반복 설정
                repeatSettingView
                
                // 반복 옵션 선택
                if showRepeatPicker {
                    RepeatOptionPickerView<AddEventViewModel>(viewModel: viewModel)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    repeatEndDateView
                }
                
                // 캘린더 컬러 선택
                calendarColorView
                
                Spacer(minLength: 20)
                
                // 하단 버튼
                addButtonView
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .background(.white)
    }
        
    // MARK: - Event Name Input
    private var eventNameInputView: some View {
        HStack(spacing: 0) {
            // 앞에 있는 컬러 바
            Rectangle()
                .fill(viewModel.selectedColor.uiColor)
                .frame(width: 4, height: 28)
                .cornerRadius(5)
            
            TextField("이름", text: $viewModel.eventName)
                .textStyle(.bold30)
                .foregroundColor(.black1)
                .padding(.leading, 12)
        }
    }
    
    // MARK: - Date Time Selection
    private var dateTimeSelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                // 캘린더 아이콘
                Image(systemName: "calendar")
                    .font(.system(size: 20))
                    .foregroundColor(.gray444)
                
                // 시작 날짜/시간
                Button {
                    withAnimation {
                        showEndDatePicker = false
                        showStartDatePicker.toggle()
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        if viewModel.isAllDay {
                            Text(viewModel.startDate.yearStringWithSuffix())
                                .textStyle(.semibold14)
                                .foregroundColor(.gray444)
                            
                            Text(viewModel.startDate.monthDayString())
                                .textStyle(.semibold20)
                                .foregroundColor(showStartDatePicker ? .primary1 : .black1)
                        } else {
                            Text(viewModel.startDate.shortDateWithWeekday())
                                .textStyle(.semibold14)
                                .foregroundColor(.gray444)
                            
                            Text(viewModel.startDate.timeString())
                                .textStyle(.semibold20)
                                .foregroundColor(showStartDatePicker ? .primary1 : .black1)
                        }
                    }
                }
                .buttonStyle(.plain)
                
                // 화살표
                Image(systemName: "chevron.right")
                    .foregroundColor(.black1)
                
                // 종료 날짜/시간
                Button {
                    withAnimation {
                        showStartDatePicker = false
                        showEndDatePicker.toggle()
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        if viewModel.isAllDay {
                            Text(viewModel.endDate.yearStringWithSuffix())
                                .textStyle(.semibold14)
                                .foregroundColor(.gray444)
                            
                            Text(viewModel.endDate.monthDayString())
                                .textStyle(.semibold20)
                                .foregroundColor(showEndDatePicker ? .primary1 : .black1)
                        } else {
                            Text(viewModel.endDate.shortDateWithWeekday())
                                .textStyle(.semibold14)
                                .foregroundColor(.gray444)
                            
                            Text(viewModel.endDate.timeString())
                                .textStyle(.semibold20)
                                .foregroundColor(showEndDatePicker ? .primary1 : .black1)
                        }
                    }
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // 하루종일 버튼
                Button {
                    viewModel.isAllDay.toggle()
                } label: {
                    Text("하루종일")
                        .textStyle(.semibold14)
                        .foregroundColor(viewModel.isAllDay ? .white : .ccc)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(viewModel.isAllDay ? .primary1 : .white)
                                .stroke(viewModel.isAllDay ? .primary1 : .ccc, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            
            // Wheel 스타일 DatePicker - 시작일
            if showStartDatePicker {
                startDatePicker
            }
            
            // Wheel 스타일 DatePicker - 종료일
            if showEndDatePicker {
                endDatePicker
            }
        }
        .onChange(of: viewModel.startDate) {
            if viewModel.isRepeatEnabled {
                viewModel.syncEndDateToStartDay()
            }
        }
    }
    
    // MARK: - Start Date Picker
    private var startDatePicker: some View {
        DatePicker(
            "",
            selection: $viewModel.startDate,
            displayedComponents: viewModel.isAllDay ? [.date] : [.date, .hourAndMinute]
        )
        .datePickerStyle(.wheel)
        .labelsHidden()
        .environment(\.locale, Locale(identifier: "ko_KR"))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
    
    // MARK: - End Date Picker (반복 일정일 때는 시작일 == 종료일만 가능)
    private var endDatePicker: some View {
        DatePicker(
            "",
            selection: $viewModel.endDate,
            in: viewModel.isRepeatEnabled ? (viewModel.startDate...viewModel.endOfStartDate) : (viewModel.startDate...Date.distantFuture),
            displayedComponents: viewModel.isAllDay ? [.date] : [.date, .hourAndMinute]
        )
        .datePickerStyle(.wheel)
        .labelsHidden()
        .environment(\.locale, Locale(identifier: "ko_KR"))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
    
    // MARK: - Repeat Setting
    private var repeatSettingView: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                showRepeatPicker.toggle()
                viewModel.isRepeatEnabled = showRepeatPicker
                if showRepeatPicker {
                    if viewModel.repeatEndDate < viewModel.startDate {
                        viewModel.repeatEndDate = Calendar.current.date(byAdding: .month, value: 1, to: viewModel.startDate) ?? viewModel.startDate
                    }
                    viewModel.syncEndDateToStartDay()
                }
            }
        } label: {
            HStack(spacing: 12) {
                // 반복 아이콘
                Image(systemName: "repeat")
                    .font(.system(size: 20))
                    .foregroundColor(.gray444)
                
                if showRepeatPicker {
                    Text(viewModel.repeatOptionDisplay)
                        .textStyle(.medium16)
                        .foregroundColor(.gray444)
                        .padding(.horizontal, 10)
                        .background(
                            Capsule()
                                .fill(.subPurple)
                                .stroke(.gray444, lineWidth: 1)
                                .frame(height: 30)
                        )
                } else {
                    Text("반복하지 않음")
                        .textStyle(.semibold20)
                        .foregroundColor(.gray88850)
                }
                
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - 반복 종료일 (날짜만 휠 선택)
    private var repeatEndDateView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Button {
                withAnimation { showRepeatEndDatePicker.toggle() }
            } label: {
                HStack(spacing: 25) {
                    Text("반복 종료")
                        .textStyle(.semibold14)
                        .foregroundColor(.gray444)
                    
                    HStack(spacing:5){
                        Text(viewModel.repeatEndDate.yearStringWithSuffix())
                            .textStyle(.semibold14)
                            .foregroundColor(showRepeatEndDatePicker ? .primary1 : .gray444)
                        Text(viewModel.repeatEndDate.monthDayString())
                            .textStyle(.semibold14)
                            .foregroundColor(showRepeatEndDatePicker ? .primary1 : .gray444)
                    }
                    .background(
                        Rectangle()
                            .fill(.subPurple)
                            .frame(width: 130, height: 30)
                            .cornerRadius(5)
                    )
                    
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            if showRepeatEndDatePicker {
                DatePicker(
                    "",
                    selection: $viewModel.repeatEndDate,
                    in: viewModel.startDate...,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "ko_KR"))
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    // MARK: - Calendar Color
    private var calendarColorView: some View {
        CalendarColorPicker(
            selectedColor: $viewModel.selectedColor,
            availableColors: viewModel.availableColors
        )
    }
    
    // MARK: - Add Button
    private var addButtonView: some View {
        PrimaryButton(title: "추가하기") {
            let event = viewModel.createEvent()
            onAdd?(event)
            dismiss()
        }
    }
}

#Preview {
    AddEventView()
}
