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
    
    var body: some View {
        HStack(alignment: .center, spacing: 8.34) {
            Text("\(emoji)")
                .textStyle(.bold12_5)
            
            Text("\(title)")
                .textStyle(.medium14)
                .lineLimit(1)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .foregroundStyle(.black1)
        .background(.interest)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(.ccc, lineWidth: 0.5))
        .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview {
    struct PreviewWrapper: View {
        var body: some View {
            HStack(spacing: 7) {
                ActivityComponent(
                    emoji: "📚",
                    title: "개발/IT"
                )

                ActivityComponent(
                    emoji: "📊",
                    title: "마케팅"
                )

                ActivityComponent(
                    emoji: "🎨",
                    title: "디자인"
                )
            }
            .padding()
        }
    }

    return PreviewWrapper()
}


