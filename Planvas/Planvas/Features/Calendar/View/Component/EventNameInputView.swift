//
//  EventNameInputView.swift
//  Planvas
//
//  Created on 1/24/26.
//

import SwiftUI

/// 이벤트 이름 입력 컴포넌트 (컬러 바 + 텍스트 필드)
struct EventNameInputView: View {
    @Binding var eventName: String
    let barColor: Color
    
    var body: some View {
        HStack(spacing: 0) {
            // 앞에 있는 컬러 바
            Rectangle()
                .fill(barColor)
                .frame(width: 4, height: 28)
                .cornerRadius(5)
            
            TextField("이름", text: $eventName)
                .textStyle(.bold30)
                .foregroundColor(.black1)
                .padding(.leading, 12)
        }
    }
}

#Preview {
    EventNameInputView(
        eventName: .constant("이벤트 이름"),
        barColor: .primary1
    )
    .padding()
}
