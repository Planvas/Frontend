//
//  EventDateInfoCard.swift
//  Planvas
//
//  Created by 백지은 on 1/24/26.
//

import SwiftUI

/// 이벤트 날짜 정보 카드 컴포넌트
struct EventDateInfoCard: View {
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("진행기간")
                .textStyle(.semibold20)
                .foregroundColor(.black1)
                .padding(.top, 10)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 20) {
                    // 시작 날짜 (한 줄 유지)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(startDate.yearString())년")
                            .textStyle(.semibold14)
                            .foregroundColor(.gray444)
                            .lineLimit(1)
                        
                        Text(startDate.monthDayString())
                            .textStyle(.semibold20)
                            .foregroundColor(.black1)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    
                    // 화살표
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18))
                        .foregroundColor(.black1)
                    
                    // 종료 날짜 (한 줄 유지)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(endDate.yearString())년")
                            .textStyle(.semibold14)
                            .foregroundColor(.gray444)
                            .lineLimit(1)
                        
                        Text(endDate.monthDayString())
                            .textStyle(.semibold20)
                            .foregroundColor(.black1)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    
                    Spacer()
                    
                    // 하루종일 배지
                    if isAllDay {
                        Text("하루종일")
                            .textStyle(.semibold14)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.primary1)
                            .cornerRadius(100)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(16)
            .padding(.vertical, 10)
            .background(Color.bar)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.ccc, lineWidth: 0.5)
            )
        }
    }
}

#Preview {
    EventDateInfoCard(
        startDate: Date(),
        endDate: Date(),
        isAllDay: true
    )
    .padding()
}
