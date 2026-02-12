//
//  InterestEditSheetView.swift
//  Planvas
//
//  Created by 황민지 on 2/12/26.
//

import SwiftUI

struct InterestEditSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(GoalSetupViewModel.self) private var goalVM

    @State private var tempSelectedIds: Set<UUID> = []

    var body: some View {
        VStack(spacing: 0) {

            Capsule()
                .fill(.black1.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 12)

            Spacer().frame(height: 16)

            HStack {
                VStack(alignment: .leading) {
                    Text("관심 분야")
                        .textStyle(.semibold20)

                    Text("최대 3개 선택 가능")
                        .textStyle(.medium14)
                        .foregroundStyle(.gray444)
                }

                Spacer()

                Button {
                    tempSelectedIds.removeAll()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                        Text("초기화")
                    }
                    .textStyle(.semibold14)
                    .foregroundStyle(.primary1)
                }
            }
            .padding(.horizontal, 20)

            Spacer().frame(height: 20)

            // 칩들
            let items = goalVM.interestActivityTypes

            VStack(alignment: .leading, spacing: 10) {
                rowView(Array(items.prefix(3)))
                rowView(Array(items.dropFirst(3).prefix(3)))
                rowView(Array(items.dropFirst(6)))
            }
            .padding(.horizontal, 20)

            Spacer()

            PrimaryButton(title: "적용하기") {
                let items = goalVM.interestActivityTypes
                let selectedNumbers = items.enumerated().compactMap { index, item in
                    tempSelectedIds.contains(item.id) ? (index + 1) : nil
                }
                let text = selectedNumbers.map(String.init).joined(separator: ",")
                print("재설정된 관심 분야 : \(text)")
                
                goalVM.selectedInterestIds = tempSelectedIds
                
                dismiss()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 75)
        }
        .task {
            tempSelectedIds = goalVM.selectedInterestIds
        }
    }
    
    // MARK: - 한 줄씩 배치
    private func rowView(_ rowItems: [InterestActivityType]) -> some View {
        HStack(spacing: 7) {
            ForEach(rowItems) { item in
                InterestActivityComponent(
                    emoji: item.emoji,
                    title: item.title,
                    isSelected: tempSelectedIds.contains(item.id),
                    onTap: {
                        if tempSelectedIds.contains(item.id) {
                            tempSelectedIds.remove(item.id)
                        } else if tempSelectedIds.count < 3 {
                            tempSelectedIds.insert(item.id)
                        }
                    }
                )
            }
            Spacer()
        }
    }
}
