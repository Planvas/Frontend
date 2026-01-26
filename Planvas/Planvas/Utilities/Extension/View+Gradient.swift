//
//  View.swift
//  Planvas
//
//  Created by 정서영 on 1/14/26.
//

import SwiftUI

extension View {
    // bottomTrailing 방향 그라데이션 색상
    // ex) .modifier(GradientModifier(startColor: .grad1, endColor: .purple1))
    func linearGradient(startColor: Color, endColor: Color) -> some View {
        modifier(GradientModifier(startColor: startColor, endColor: endColor))
    }
}
