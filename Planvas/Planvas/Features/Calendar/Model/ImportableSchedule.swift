//
//  ImportableSchedule.swift
//  Planvas
//
//  Created by 백지은 on 1/21/26.
//

import Foundation

struct ImportableSchedule: Identifiable {
    /// Google Calendar 이벤트는 UUID가 아닌 문자열 ID(ex: "abc123def456")를 쓰므로 String으로 보존
    let id: String
    let title: String
    let timeDescription: String
    let startDate: Date
    let endDate: Date
    var isSelected: Bool

    init(id: String, title: String, timeDescription: String, startDate: Date, endDate: Date, isSelected: Bool = false) {
        self.id = id
        self.title = title
        self.timeDescription = timeDescription
        self.startDate = startDate
        self.endDate = endDate
        self.isSelected = isSelected
    }
}
