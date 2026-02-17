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
struct MainDataSuccess: Decodable {
    let userName: String
    let goalStatus: GoalSetting
    let currentGoal: CurrentGoal?
    let progress: Progress?
    let weeklySummary: WeeklySummary?
    let todayTodos: [TodayTodo]?
    let recommendations: [Recommendation]?
}

// CurrentGoal
struct CurrentGoal: Decodable {
    let goalId: Int
    let title: String
    let startDate: String
    let endDate: String
    let dDay: String
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
    let schedules: [ScheduleDTO]
}

struct ScheduleDTO: Decodable {
    let id: Int
    let title: String
    let type: String
    let category: TodoCategory
    let point: Int
    let color: Int
    let startTime: String
    let endTime: String
    let completed: Bool
    let recurrenceRule: String?
}

// TodayTodo
struct TodayTodo: Decodable {
    let todoId: Int
    let title: String
    let type: String
    let category: TodoCategory
    let point: Int
    let color: Int
    let startTime: String
    let endTime: String
    let completed: Bool
    let recurrenceRule: String?
}

// Recommendation
struct Recommendation: Decodable {
    let activityId: Int
    let title: String
    let subTitle: String?
    let dDay: Int?
    let imageUrl: String
    let tags: [String]?
}

// TODO: - 오늘의 할 일 (스케줄 투두) 완료 상태 토글
struct ScheduleTodoResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: ScheduleTodoSuccess?
}

struct ScheduleTodoSuccess: Decodable {
    let id: Int
    let status: String
}
