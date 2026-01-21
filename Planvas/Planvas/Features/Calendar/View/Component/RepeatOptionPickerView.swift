//
//  RepeatOptionPickerView.swift
//  Planvas
//
//  Created by 백지은 on 1/21/26.
//

import SwiftUI

struct RepeatOptionPickerView: View {
    @ObservedObject var viewModel: AddEventViewModel

    var body: some View {
        VStack(spacing: 0) {
            repeatTypeTabs
            repeatOptionsView
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray444, lineWidth: 1)
        )
    }

    // MARK: - Repeat Type Tabs (Segmented)
    private var repeatTypeTabs: some View {
        let types = AddEventViewModel.RepeatType.allCases

        return ZStack {
            Capsule()
                .fill(.white)
                .overlay(
                    Capsule()
                        .stroke(.ccc, lineWidth: 1)
                )

            GeometryReader { geo in
                Capsule()
                    .fill(.gray444)
                    .frame(width: geo.size.width / CGFloat(types.count))
                    .offset(x: viewModel.indicatorOffset(width: geo.size.width))
                    .animation(.easeInOut(duration: 0.2), value: viewModel.repeatType)
            }

            HStack(spacing: 0) {
                ForEach(types, id: \.self) { type in
                    Button {
                        viewModel.handleRepeatTypeChange(to: type)
                    } label: {
                        Text(type.rawValue)
                            .textStyle(.medium14)
                            .foregroundColor(viewModel.repeatType == type ? .white : .black1)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .frame(height: 27)
        .padding(8)
    }

    // MARK: - Repeat Options
    @ViewBuilder
    private var repeatOptionsView: some View {
        switch viewModel.repeatType {
        case .weekly, .daily:
            weeklyOptionsView
        case .yearly:
            yearlyOptionsView
        case .monthly:
            EmptyView()
        }
    }

    // MARK: - Weekly
    private var weeklyOptionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("반복요일")
                .textStyle(.medium14)
                .foregroundColor(.black1)

            HStack(alignment: .center, spacing: 10) {
                ForEach(0..<7) { index in
                    weekdayButton(index: index)
                }
            }
        }
        .padding(20)
    }

    private func weekdayButton(index: Int) -> some View {
        let isSelected = viewModel.selectedWeekdays.contains(index)

        return Button {
            viewModel.handleWeekdayToggle(index: index, isCurrentlySelected: isSelected)
        } label: {
            Text(viewModel.weekdays[index])
                .textStyle(.medium14)
                .foregroundColor(isSelected ? .white : .black1)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isSelected ? .gray444 : .white)
                )
                .overlay(
                    Circle()
                        .stroke(isSelected ? .clear : .ccc, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Yearly
    private var yearlyOptionsView: some View {
        VStack(spacing: 8) {
            ForEach(viewModel.yearDurations, id: \.self) { duration in
                yearlyRow(duration: duration)
            }
        }
        .padding(16)
    }

    private func yearlyRow(duration: Int) -> some View {
        let isSelected = viewModel.selectedYearDuration == duration

        return Button {
            viewModel.selectedYearDuration = duration
        } label: {
            Text("\(duration)년")
                .textStyle(.semibold16)
                .foregroundColor(isSelected ? .white : .black1)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? .gray444 : .clear)
                )
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    RepeatOptionPickerPreview()
}

struct RepeatOptionPickerPreview: View {
    @StateObject private var viewModel = AddEventViewModel()

    var body: some View {
        RepeatOptionPickerView(viewModel: viewModel)
    }
}
