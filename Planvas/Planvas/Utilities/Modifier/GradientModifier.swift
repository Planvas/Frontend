//
//  GradientModifier.swift
//  Planvas
//
//  Created by 정서영 on 1/26/26.
//

import SwiftUI

// MARK: - 그라데이션 색상
struct GradientModifier: ViewModifier {
    var startColor: Color
    var endColor: Color
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(
                LinearGradient(
                    gradient: Gradient(colors: [startColor, endColor]),
                    startPoint: UnitPoint(x: -0.1, y: 0.2),
                    endPoint: UnitPoint(x: 0.8, y: 0.5)
                )
            )
    }
}
