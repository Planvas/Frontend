//
//  InterestActivityTypeModel.swift
//  Planvas
//
//  Created by 황민지 on 1/26/26.
//

import Foundation

struct InterestActivityType: Identifiable, Hashable {
    let id: UUID
    let emoji: String
    let title: String

    init(id: UUID = UUID(), emoji: String, title: String) {
        self.id = id
        self.emoji = emoji
        self.title = title
    }
}
