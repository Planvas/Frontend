//
//  ActivityComponent.swift
//  Planvas
//
//  Created by 황민지 on 1/25/26.
//

import SwiftUI

struct ActivityComponent: View {
    let emoji: String
    let title: String
    
    let ringColor: Color
    let labelColor: Color

    var body: some View {
        ZStack(alignment: .center) {

            Text(emoji)
                .textStyle(.medium58)
                .offset(y: -2)
                .allowsHitTesting(false)

            Circle()
                .fill(.fff50)
                .overlay(
                    Circle().stroke(ringColor, lineWidth: 1.5)
                )
                .frame(width: 99, height: 99)
        }
        .frame(width: 99, height: 99)
        .overlay(alignment: .top) {
            
            Text(title)
                .textStyle(.medium18)
                .foregroundStyle(.fff)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, 10)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 100)
                        .fill(labelColor)
                )
                .offset(y: 49.89)
                .zIndex(10)
                .allowsHitTesting(false)
        }
    }
}

#Preview {
    HStack(spacing: 23) {
        ActivityComponent(emoji: "📚", title: "장기프로젝트", ringColor: .green60, labelColor: .green1)
        ActivityComponent(emoji: "👥", title: "학회/동아리", ringColor: .green60, labelColor: .green1)
        ActivityComponent(emoji: "👥", title: "학회/동아리", ringColor: .green60, labelColor: .green1)
    }
    .padding()
}


