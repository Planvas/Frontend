//
//  RepeatOptionConfigurable.swift
//  Planvas
//
//  Created by 백지은 on 1/24/26.
//

import Foundation

/// 반복 옵션 설정을 위한 프로토콜 (@Observable)
protocol RepeatOptionConfigurable {
    var repeatType: RepeatType { get set }
    var selectedWeekdays: Set<Int> { get set }
    var weekdays: [String] { get }
    
    func handleRepeatTypeChange(to newType: RepeatType)
    func handleWeekdayToggle(index: Int, isCurrentlySelected: Bool)
    func indicatorOffset(width: CGFloat) -> CGFloat
}

/// 반복 타입 enum (공통 사용)
enum RepeatType: String, CaseIterable, Codable {
    case daily = "매일"
    case weekly = "매주"
    case biweekly = "격주"
    case monthly = "매달"
    case yearly = "매년"
}
