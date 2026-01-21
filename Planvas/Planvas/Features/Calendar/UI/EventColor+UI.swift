//
//  EventColor+UI.swift
//  Planvas
//
//  Created by 백지은 on 1/22/26.
//

import SwiftUI

extension EventColorType {
    @MainActor
    var uiColor: Color {
        switch self {
        case .red: return .calRed
        case .yellow: return .calYellow
        case .pink: return .calPink
        case .purple1: return .calPurple1
        case .purple2: return .calPurple2
        case .blue1: return .calBlue1
        case .blue2: return .calBlue2
        case .blue3: return .calBlue3
        case .green: return .calGreen
        case .ccc: return .ccc
        }
    }
}
