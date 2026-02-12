//
//  CommonEnum.swift
//  Planvas
//
//  Created by 정서영 on 2/6/26.
//

// 성장/휴식 카테고리
enum TodoCategory: String, Codable {
    case growth = "GROWTH"
    case rest = "REST"
}

// 활동 일정 가능 여부
enum ScheduleAvailable: String, Codable {
    case available = "AVAILABLE"
    case warning = "WARNING"
    case conflict = "CONFILCT"
}
