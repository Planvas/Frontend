//
//  PlanvasButton.swift
//  Planvas
//
//  Created by 송민교 on 1/20/26.
//
import SwiftUI

struct PlanvasButton: View {
    let title: String
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .textStyle(.semibold20)
                .foregroundStyle(Color.white)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .glassEffect(.regular.interactive())
        .tint(Color.purple1)
        .overlay{
            if isDisabled {
                Capsule()
                    .fill(Color.black.opacity(0.3))
            }
        }
        .disabled(isDisabled)
    }
}
