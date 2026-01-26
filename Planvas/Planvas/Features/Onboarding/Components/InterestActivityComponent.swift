//
//  InterestActivityComponent.swift
//  Planvas
//
//  Created by 황민지 on 1/26/26.
//

import SwiftUI

struct InterestActivityComponent: View {
    let emoji: String
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 8.34) {
                
                Text("\(emoji)")
                    .textStyle(.bold12_5)
                
                Text("\(title)")
                    .textStyle(.medium14)
                    .lineLimit(1)   
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16.67)
            .foregroundStyle(isSelected ? .white : .black1)
            .background(isSelected ? .primary1 : .interest)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(.ccc, lineWidth: 0.5))
            .shadow(
                color: isSelected ? .primary20 : .clear,
                radius: isSelected ? 4 : 0,
                x: 0, y: 2
            )
            .fixedSize(horizontal: true, vertical: false)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var s1 = false
        @State private var s2 = true
        @State private var s3 = false

        var body: some View {
            HStack(spacing: 7) {
                InterestActivityComponent(
                    emoji: "📚",
                    title: "개발/IT",
                    isSelected: s1,
                    onTap: { s1.toggle() }
                )

                InterestActivityComponent(
                    emoji: "📊",
                    title: "마케팅",
                    isSelected: s2,
                    onTap: { s2.toggle() }
                )

                InterestActivityComponent(
                    emoji: "🎨",
                    title: "디자인",
                    isSelected: s3,
                    onTap: { s3.toggle() }
                )
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
