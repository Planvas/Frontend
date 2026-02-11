//
//  AddActivityView.swift
//  Planvas
//
//  Created by 백지은 on 2/12/26.
//

import SwiftUI

struct AddActivityView: View {
    @Bindable var viewModel: AddActivityViewModel
    var onSubmit: (() -> Void)?

    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                    .padding(.top, 45)

                TargetPeriodPill(targetPeriod: viewModel.targetPeriod)
                    .padding(.vertical, 10)

                periodSection

                ActivitySettingsSectionView(viewModel: viewModel)

                PrimaryButton(title: "일정 추가하기") {
                    onSubmit?()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .background(.white)
        .onChange(of: viewModel.startDate) { viewModel.updateTargetPeriodFromDates() }
        .onChange(of: viewModel.endDate) { viewModel.updateTargetPeriodFromDates() }
    }

    // MARK: - Header (보라 세로바 + 부제 + 제목)
    private var headerView: some View {
        HStack(alignment: .top, spacing: 8) {
            // 보라색 세로 바
            Rectangle()
                .fill(.primary1)
                .frame(width: 4, height: 28)
                .cornerRadius(2)
                .padding(.vertical, 5)
            
            Text(viewModel.title)
                .textStyle(.semibold30)
                .foregroundColor(.black1)
            
            Spacer()
        }
    }

    // MARK: - 진행기간 (날짜 + 수정하기 → 섹션 늘어나며 휠 픽커 표시)
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
            selection: $viewModel.startDate,
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
            selection: $viewModel.endDate,
            in: viewModel.startDate...Date.distantFuture,
            displayedComponents: .date
        )
        .datePickerStyle(.wheel)
        .labelsHidden()
        .environment(\.locale, Locale(identifier: "ko_KR"))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

}

#Preview {
    AddActivityView(viewModel: ActivitySampleData.sampleAddActivityViewModel())
}
