//
//  AddEventView.swift
//  Planvas
//
//  Created by 백지은 on 1/21/26.
//

// TODO: 반복 요일에 뱃지 추가하고 추후 디자인 수정된다고 하니까 그거 반영해서 수정 필요

import SwiftUI

struct AddEventView: View {
    @StateObject private var viewModel = AddEventViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showRepeatPicker = false
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false
    
    var onAdd: ((Event) -> Void)?
    
    var body: some View {
        ZStack {
            // 메인 콘텐츠
            VStack(spacing: 20) {
                // 이벤트 이름 입력
                eventNameInputView
                    .padding(.vertical, 45)
                
                // 날짜/시간 선택
                dateTimeSelectionView
                
                // 반복 설정
                repeatSettingView
                
                // 반복 옵션 선택 또는 캘린더 컬러 선택
                if showRepeatPicker {
                    repeatOptionPickerView
                        .padding(.bottom, 37)
                } else {
                    calendarColorView
                        .padding(.vertical, 37)
                }
                
                Spacer()
                
                // 하단 버튼
                addButtonView
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 40)
            
            // 날짜 선택 오버레이
            if showStartDatePicker || showEndDatePicker {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showStartDatePicker = false
                            showEndDatePicker = false
                        }
                    }
                
                VStack {
                    Spacer()
                    
                    datePickerCard
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
        .animation(.spring(response: 0.3), value: showStartDatePicker)
        .animation(.spring(response: 0.3), value: showEndDatePicker)
    }
    
    // MARK: - Date Picker Card
    private var datePickerCard: some View {
        VStack(spacing: 0) {
            // 헤더
            HStack {
                Button("취소") {
                    withAnimation {
                        showStartDatePicker = false
                        showEndDatePicker = false
                    }
                }
                .foregroundColor(.ccc)
                
                Spacer()
                
                Text(showStartDatePicker ? "시작 일시" : "종료 일시")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black1)
                
                Spacer()
                
                Button("완료") {
                    withAnimation {
                        showStartDatePicker = false
                        showEndDatePicker = false
                    }
                }
                .foregroundColor(.primary1)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
            
            // DatePicker
            if showStartDatePicker {
                DatePicker(
                    "",
                    selection: $viewModel.startDate,
                    displayedComponents: viewModel.isAllDay ? [.date] : [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .environment(\.locale, Locale(identifier: "ko_KR"))
                .labelsHidden()
                .padding()
                .tint(.primary1)
                
            } else if showEndDatePicker {
                DatePicker(
                    "",
                    selection: $viewModel.endDate,
                    displayedComponents: viewModel.isAllDay ? [.date] : [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .environment(\.locale, Locale(identifier: "ko_KR"))
                .labelsHidden()
                .padding()
                .tint(.primary1)
            }
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
        
    // MARK: - Event Name Input
    private var eventNameInputView: some View {
        HStack(spacing: 0) {
            // 네모? 저거 이름이 뭐지 아무튼 앞에 있는 바
            Rectangle()
                .fill(.calRed)
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
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                // 캘린더 아이콘
                Image(systemName: "calendar")
                    .font(.system(size: 20))
                    .foregroundColor(.gray444)
                
                // 시작 날짜/시간 - 탭 가능
                Button {
                    withAnimation {
                        showEndDatePicker = false
                        showStartDatePicker.toggle()
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.formatDate(viewModel.startDate))
                            .textStyle(.semibold14)
                            .foregroundColor(.gray444)
                        
                        Text(viewModel.formatTime(viewModel.startDate))
                            .textStyle(.semibold20)
                            .foregroundColor(.gray444)
                    }
                }
                .buttonStyle(.plain)
                
                // 화살표
                Image(systemName: "chevron.right")
                    .foregroundColor(.black1)
                
                // 종료 날짜/시간 - 탭 가능
                Button {
                    withAnimation {
                        showStartDatePicker = false
                        showEndDatePicker.toggle()
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.formatDate(viewModel.endDate))
                            .textStyle(.semibold14)
                            .foregroundColor(.gray444)
                        
                        Text(viewModel.formatTime(viewModel.endDate))
                            .textStyle(.semibold20)
                            .foregroundColor(.gray444)
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
        }
    }
    
    // MARK: - Repeat Setting
    private var repeatSettingView: some View {
        Button {
            showRepeatPicker.toggle()
        } label: {
            HStack(spacing: 12) {
                // 반복 아이콘
                Image(systemName: "repeat")
                    .font(.system(size: 20))
                    .foregroundColor(.gray444)
                
                Text(viewModel.repeatOptionDisplay)
                    .textStyle(.medium16)
                    .foregroundColor(.gray444)
                
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Repeat Option Picker View
    private var repeatOptionPickerView: some View {
        RepeatOptionPickerView(viewModel: viewModel)
    }
    
    // MARK: - Calendar Color
    private var calendarColorView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("캘린더 컬러")
                .textStyle(.semibold20)
                .foregroundColor(.black1)
            
            VStack(alignment: .leading, spacing: 12) {
                // 첫 번째 줄
                HStack(spacing: 15) {
                    ForEach(viewModel.firstRowColorIndices, id: \.self) { index in
                        colorSwatch(colorType: viewModel.availableColors[index])
                    }
                }

                HStack(spacing: 15) {
                    ForEach(viewModel.secondRowColorIndices, id: \.self) { index in
                        colorSwatch(colorType: viewModel.availableColors[index])
                    }
                    
                    Button {
                        // 커스텀 색상 추가
                    } label: {
                        Circle()
                            .fill(.ccc20)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 20))
                                    .foregroundColor(.gray888)
                            )
                            .overlay(
                                Circle()
                                    .stroke(.ccc, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ccc20)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.ccc, lineWidth: 1)
            )
        }
    }

    
    private func colorSwatch(colorType: EventColorType) -> some View {
        let color = viewModel.eventColor(for: colorType)

        return Button {
            viewModel.selectedColor = colorType
        } label: {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 30, height: 30)

                if viewModel.selectedColor == colorType {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
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
