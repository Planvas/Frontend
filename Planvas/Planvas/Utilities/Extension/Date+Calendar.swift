//
//  Date+Calendar.swift
//  Planvas
//
//  Created by 정서영 on 1/27/26.
//

import SwiftUI

// MARK: - 캘린더 공용 로직
extension Date {
    
    var day: Int {
        Calendar.current.component(.day, from: self)
    }
    
    var weekday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E"
        return formatter.string(from: self)
    }
    
    var isSaturday: Bool {
        Calendar.current.component(.weekday, from: self) == 7
    }
    
    var isSunday: Bool {
        Calendar.current.component(.weekday, from: self) == 1
    }
    
    func isToday() -> Bool {
        Calendar.current.isDateInToday(self)
    }
}
