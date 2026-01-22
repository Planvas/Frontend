//
//  Event.swift
//  Planvas
//
//  Created by 백지은 on 1/17/26.
//

import Foundation

struct Event: Identifiable, Codable {
    let id: UUID
    let title: String
    let time: String
    var isFixed: Bool
    var isAllDay: Bool
    let color: EventColorType

    init(
        id: UUID = UUID(),
        title: String,
        time: String,
        isFixed: Bool = false,
        isAllDay: Bool = false,
        color: EventColorType
    ) {
        self.id = id
        self.title = title
        self.time = time
        self.isFixed = isFixed
        self.isAllDay = isAllDay
        self.color = color
    }
}
