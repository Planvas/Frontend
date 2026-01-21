//
//  Event.swift
//  Planvas
//
//  Created by 백지은 on 1/17/26.
//

import SwiftUI

struct Event: Identifiable {
    let id = UUID()
    let title: String
    let time: String
    var isFixed: Bool = false
    var isAllDay: Bool = false
    let color: EventColorType
}

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
}
