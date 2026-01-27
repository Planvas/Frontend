//
//  RepeatOptionPickerView.swift
//  Planvas
//
//  Created by 백지은 on 1/21/26.
//

import SwiftUI

struct RepeatOptionPickerView<ViewModel: RepeatOptionConfigurable>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        repeatTypeTabs
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
    }

    // MARK: - Repeat Type Tabs (Segmented)
    private var repeatTypeTabs: some View {
        let types = RepeatType.allCases

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
        .frame(height: 35)
        .padding(8)
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
