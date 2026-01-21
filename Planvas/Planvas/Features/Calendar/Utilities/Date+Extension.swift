//
//  Date+Extension.swift
//  Planvas
//
//  Created on 1/22/26.
//

import Foundation

extension Date {
    /// 날짜를 "M월" 형식으로 포맷팅
    func monthString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월"
        return formatter.string(from: self)
    }
    
    /// 날짜를 "yyyy" 형식으로 포맷팅
    func yearString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }
    
    /// 날짜를 "yyyy년 M월 d일 EEEE" 형식으로 포맷팅
    func fullDateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 EEEE"
        return formatter.string(from: self)
    }
    
    /// 날짜를 "M/d, EEEE" 형식으로 포맷팅
    func dateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M/d, EEEE"
        return formatter.string(from: self)
    }
    
    /// 시간을 "h:mm a" 형식으로 포맷팅
    func timeString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: self)
    }
}
