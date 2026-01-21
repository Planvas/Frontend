//
//  ImportableSchedule.swift
//  Planvas
//
//  Created by 백지은 on 1/21/26.
//

import Foundation

struct ImportableSchedule: Identifiable {
    let id: UUID
    let title: String
    let timeDescription: String
    var isSelected: Bool
    
    init(id: UUID = UUID(), title: String, timeDescription: String, isSelected: Bool = false) {
        self.id = id
        self.title = title
        self.timeDescription = timeDescription
        self.isSelected = isSelected
    }
}
