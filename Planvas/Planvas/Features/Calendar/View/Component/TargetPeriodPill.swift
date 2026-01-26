//
//  TargetPeriodPill.swift
//  Planvas
//
//  Created on 1/24/26.
//

import SwiftUI

/// 나의 목표 기간 표시 컴포넌트
struct TargetPeriodPill: View {
    let targetPeriod: String
    
    var body: some View {
        HStack {
            Text("나의 목표 기간")
                .textStyle(.medium15)
                .foregroundColor(.black1)
            
            Spacer()
            
            Text(targetPeriod)
                .textStyle(.medium15)
                .foregroundColor(.black1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.primary20)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.primary1, lineWidth: 1)
        )
    }
}

#Preview {
    TargetPeriodPill(targetPeriod: "11/15 ~ 12/3")
        .padding()
}
