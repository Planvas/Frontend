//
//  CalendarColorPicker.swift
//  Planvas
//
//  Created on 1/24/26.
//

import SwiftUI

/// 캘린더 컬러 선택 컴포넌트
struct CalendarColorPicker: View {
    @Binding var selectedColor: EventColorType
    let availableColors: [EventColorType]
    let firstRowCount: Int
    
    init(
        selectedColor: Binding<EventColorType>,
        availableColors: [EventColorType] = [
            .purple2, .blue1, .red, .yellow, .blue2, .pink, .green,
            .blue3, .ccc, .purple1
        ],
        firstRowCount: Int = 7
    ) {
        self._selectedColor = selectedColor
        self.availableColors = availableColors
        self.firstRowCount = firstRowCount
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("캘린더 컬러")
                .textStyle(.semibold20)
                .foregroundColor(.black1)
            
            VStack(alignment: .leading, spacing: 12) {
                // 첫 번째 줄
                HStack(spacing: 15) {
                    ForEach(0..<min(firstRowCount, availableColors.count), id: \.self) { index in
                        colorSwatch(colorType: availableColors[index])
                    }
                }
                
                // 두 번째 줄
                HStack(spacing: 15) {
                    ForEach(firstRowCount..<availableColors.count, id: \.self) { index in
                        colorSwatch(colorType: availableColors[index])
                    }
                    
                    // 커스텀 색상 추가 버튼
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
        let color = colorType.uiColor
        
        return Button {
            selectedColor = colorType
        } label: {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 30, height: 30)
                
                if selectedColor == colorType {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    CalendarColorPicker(selectedColor: .constant(.red))
        .padding()
}
