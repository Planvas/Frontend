//
//  MainModel.swift
//  Planvas
//
//  Created by 정서영 on 1/26/26.
//

import SwiftUI

// MARK: - 목표 설정 상태
enum GoalSetting {
    case ing
    case end
    case none
}

// MARK: - 할 일
struct ToDo: Identifiable {
    let id = UUID()
    let typeColor: ToDoTypeColor
    let title: String
    let isFixed: Bool
    let todoInfo: String
    let startTime: String
    var isCompleted: Bool
}
// 할 일 타입별 색상 정리
enum ToDoTypeColor: String, Codable {
    case calRed
    case calPurple
    case calBlue
    case calGreen
    
    var color: Color {
        switch self {
        case .calRed:
            return Color("calRed")
        case .calPurple:
            return Color("calPurple")
        case .calBlue:
            return Color("calBlue")
        case .calGreen:
            return Color("calGreen")
        }
    }
}

// MARK: - 오늘의 인기 성장 활동
struct ActivityItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
}
