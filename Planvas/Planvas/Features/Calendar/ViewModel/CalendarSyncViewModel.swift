//
//  CalendarSyncViewModel.swift
//  Planvas
//
//  Created on 1/22/26.
//

import SwiftUI
import Combine

@MainActor
class CalendarSyncViewModel: ObservableObject {
    var calendarTitle: AttributedString {
        var attributed = AttributedString("캘린더 연동으로")

        if let range = attributed.range(of: "캘린더 연동") {
            attributed[range].foregroundColor = .primary1
            attributed[range].font = TextStyle.bold30.swiftUIFont
        }

        if let range = attributed.range(of: "으로") {
            attributed[range].foregroundColor = .black1
            attributed[range].font = TextStyle.bold30.swiftUIFont
        }

        return attributed
    }
}
