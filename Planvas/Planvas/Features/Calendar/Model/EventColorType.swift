//
//  EventColorType.swift
//  Planvas
//
//  Created by 백지은 on 1/22/26.
//

import Foundation

enum EventColorType: String, Codable {
    case red
    case yellow
    case pink
    case purple1
    case purple2
    case blue1
    case blue2
    case blue3
    case green
    case ccc

    /// 백엔드 월간/일간 API 색상 값 (1~10) → EventColorType
    static func from(serverColor: Int) -> EventColorType {
        let palette: [EventColorType] = [.red, .yellow, .pink, .purple1, .purple2, .blue1, .blue2, .blue3, .green, .ccc]
        let index = max(1, min(10, serverColor)) - 1
        return palette[index]
    }

    /// EventColorType → 백엔드에 보낼/맞춰볼 색상 값 (1~10)
    var serverColor: Int {
        let palette: [EventColorType] = [.red, .yellow, .pink, .purple1, .purple2, .blue1, .blue2, .blue3, .green, .ccc]
        return (palette.firstIndex(of: self) ?? 0) + 1
    }
}
