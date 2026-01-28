//
//  MainModel.swift
//  Planvas
//
//  Created by 정서영 on 1/26/26.
//

import SwiftUI

enum GoalSetting {
    case ing
    case end
    case none
}

struct ToDo: Identifiable {
    let id = UUID()
    let typeColor: ToDoTypeColor
    let title: String
    let isFixed: Bool
    let todoInfo: String
    let startTime: String
    var isCompleted: Bool
}

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
