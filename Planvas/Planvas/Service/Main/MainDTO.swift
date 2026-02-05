//
//  MainDTO.swift
//  Planvas
//
//  Created by 정서영 on 2/2/26.
//

import Foundation

// MARK: - 홈 대시보드 조회
struct MainDataResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: MainDataSuccess?
}

// MainDataSuccess
// TODO: - 현재 목표가 없는 경우 확인 필요
struct MainDataSuccess: Decodable {
    let currentGoal: CurrentGoal
    let progress: Progress
    let weeklySummary: WeeklySummary
    let todayTodos: [TodayTodo]
    let recommendations: [Recommendation]
}

// CurrentGoal
struct CurrentGoal: Decodable {
    let goalId: Int
    let title: String
    let startDate: String
    let endDate: String
    let dDay: Int
    let growthRatio: Int
    let restRatio: Int
}

// Progress
struct Progress: Decodable {
    let growthAchieved: Int
    let restAchieved: Int
}

// WeeklySummary
struct WeeklySummary: Decodable {
    let weekStartDate: String
    let days: [WeeklyDay]
}

struct WeeklyDay: Decodable {
    let date: String
    let hasItems: Bool
    let todoCount: Int
}

// TodayTodo
struct TodayTodo: Decodable {
    let todoId: Int
    let title: String
    let category: TodoCategory
    let completed: Bool
}

// Recommendation
struct Recommendation: Decodable {
    let activityId: Int
    let title: String
    let category: TodoCategory
    let point: Int
}
