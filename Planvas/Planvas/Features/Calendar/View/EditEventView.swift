//
//  EditEventView.swift
//  Planvas
//
//  Created by 백지은 on 1/24/26.
//

import SwiftUI

struct EditEventView: View {
    @State private var viewModel = EditEventViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false
    @State private var showRepeatPicker = false
    @State private var showRepeatEndDatePicker = false
    
    let event: Event
    let startDate: Date
    let endDate: Date
    /// 수정 저장 시 수정된 Event 전달 (낙관적 업데이트용)
    var onSave: ((Event) -> Void)?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 이벤트 이름 입력
                EventNameInputView(
                    eventName: $viewModel.eventName,
                    barColor: viewModel.selectedColor.uiColor
                )
                .padding(.top, 45)
                
                // 나의 목표 기간
                TargetPeriodPill(targetPeriod: viewModel.targetPeriod)
                    .padding(.vertical, 10)
                
                // 진행기간 섹션
                dateTimeSection
                
                // 반복 설정
                repeatSettingView
                
                // 반복 옵션 선택
                if showRepeatPicker {
                    RepeatOptionPickerView<EditEventViewModel>(viewModel: viewModel)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    repeatEndDateView
                }
                
                // 활동치 설정
                activitySettingsSection
                    .padding(.vertical, 30)
                
                // 캘린더 컬러
                CalendarColorPicker(
                    selectedColor: $viewModel.selectedColor,
                    availableColors: viewModel.availableColors
                )
                
                Spacer(minLength: 20)
                
                // 하단 버튼
                skipButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .background(.white)
        .onAppear {
            viewModel.configure(with: event, startDate: startDate, endDate: endDate)
            // 반복 설정 상태 초기화
            showRepeatPicker = event.isRepeating
        }
    }
    
    // MARK: - Date Time Section
    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("진행기간")
                .textStyle(.semibold20)
                .foregroundColor(.black1)
            
            // 날짜/시간 표시 및 선택
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
            if viewModel.isRepeating {
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
            in: viewModel.isRepeating ? (viewModel.startDate...viewModel.endOfStartDate) : (viewModel.startDate...Date.distantFuture),
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
                viewModel.isRepeating = showRepeatPicker
                if showRepeatPicker {
                    if viewModel.repeatEndDate < viewModel.startDate {
                        viewModel.repeatEndDate = Calendar.current.date(byAdding: .month, value: 1, to: viewModel.startDate) ?? viewModel.startDate
                    }
                    viewModel.syncEndDateToStartDay()
                }
            }
        } label: {
            HStack(spacing: 12) {
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

    // MARK: - 반복 종료일 (날짜만 휠 선택, AddEventView와 동일 디자인)
    private var repeatEndDateView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Button {
                withAnimation { showRepeatEndDatePicker.toggle() }
            } label: {
                HStack(spacing: 25) {
                    Text("반복 종료")
                        .textStyle(.semibold14)
                        .foregroundColor(.gray444)
                    
                    HStack(spacing: 5) {
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
    
    // MARK: - Activity Settings Section
    private var activitySettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 헤더 (토글 포함)
            HStack {
                Text("활동치 설정")
                    .textStyle(.semibold20)
                    .foregroundColor(.black1)
                
                Text("목표한 균형치에 반영돼요")
                    .textStyle(.medium14)
                    .foregroundColor(.primary1)
                
                Spacer()
                
                Toggle("", isOn: $viewModel.isActivityEnabled)
                    .labelsHidden()
                    .tint(.primary1)
            }
            
            // 활동치 설정 컨텐츠
            VStack(spacing: 16) {
                // 현재 달성률
                HStack {
                    Text("현재 달성률")
                        .textStyle(.medium18)
                        .foregroundColor(viewModel.isActivityEnabled ? .black1 : .gray444)
                    Spacer()
                }
                
                // 성장/휴식 선택 버튼
                HStack(spacing: 15) {
                    Button {
                        viewModel.selectedActivityType = .growth
                    } label: {
                        Text("성장")
                            .textStyle(.semibold20)
                            .foregroundColor(activityTypeColor(for: .growth))
                    }
                    .disabled(!viewModel.isActivityEnabled)
                    
                    Button {
                        viewModel.selectedActivityType = .rest
                    } label: {
                        Text("휴식")
                            .textStyle(.semibold20)
                            .foregroundColor(activityTypeColor(for: .rest))
                    }
                    .disabled(!viewModel.isActivityEnabled)
                    
                    Spacer()
                }
                
                // 진행 바
                VStack(spacing: 8) {
                    HStack {
                        Text("\(viewModel.displayProgress)%")
                            .textStyle(.semibold14)
                            .foregroundColor(viewModel.isActivityEnabled ? .white : .gray444)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(viewModel.isActivityEnabled ? .primary1 : .ccc)
                            .cornerRadius(8)
                        
                        Spacer()
                        
                        Text("\(viewModel.targetAchievement)%")
                            .textStyle(.regular14)
                            .foregroundColor(.gray444)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // 배경 바
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.ccc60)
                                .frame(height: 8)
                            
                            // 진행 바
                            RoundedRectangle(cornerRadius: 4)
                                .fill(viewModel.isActivityEnabled ? .primary1 : .ccc)
                                .frame(
                                    width: geometry.size.width * viewModel.progressRatio,
                                    height: 8
                                )
                                .animation(.easeInOut(duration: 0.2), value: viewModel.currentActivityValue)
                        }
                    }
                    .frame(height: 8)
                }
                
                // 숫자 조절 버튼
                HStack(alignment: .center, spacing: 12) {
                    Button {
                        viewModel.decrementActivityValue()
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(viewModel.isActivityEnabled ? .primary1 : .gray444)
                            .frame(width: 45, height: 45)
                            .background(viewModel.isActivityEnabled ? .minus : .ccc20)
                            .cornerRadius(8)
                    }
                    .disabled(!viewModel.isActivityEnabled)
                    
                    Text("\(viewModel.currentActivityValue)")
                        .textStyle(.semibold20)
                        .foregroundColor(viewModel.isActivityEnabled ? .black1 : .gray444)
                        .frame(minWidth: 50)
                    
                    Button {
                        viewModel.incrementActivityValue()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 45, height: 45)
                            .background(viewModel.isActivityEnabled ? .primary1 : .ccc)
                            .cornerRadius(8)
                    }
                    .disabled(!viewModel.isActivityEnabled)
                }
            }
            .padding(16)
            .background(.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(viewModel.isActivityEnabled ? .primary1 : .ccc, lineWidth: 1)
            )
            .animation(.easeInOut(duration: 0.2), value: viewModel.isActivityEnabled)
        }
    }
    
    // MARK: - Helper Methods
    
    /// 활동 타입 색상 결정
    private func activityTypeColor(for type: EditEventViewModel.ActivityType) -> Color {
        if !viewModel.isActivityEnabled {
            return .ccc
        }
        return viewModel.isActivityTypeSelected(type) ? .primary1 : .primary20
    }
    
    // MARK: - Save Button
    private var skipButton: some View {
        PrimaryButton(title: "일정 수정하기") {
            let updatedEvent = viewModel.createUpdatedEvent()
            viewModel.saveEvent()
            onSave?(updatedEvent)
            dismiss()
        }
    }
}

#Preview {
    EditEventView(
        event: Event(
            title: "이름",
            time: "하루종일",
            isAllDay: true,
            color: .red
        ),
        startDate: Date(),
        endDate: Date(),
        onSave: nil
    )
}
