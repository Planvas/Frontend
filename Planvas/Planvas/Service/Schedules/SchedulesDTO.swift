//
//  SchedulesDTO.swift
//  Planvas
//
//  Created by 정서영 on 2/2/26.
//

// MARK: - 고정 일정 수동 추가
struct CreateScheduleRequestDTO: Encodable {
    let title: String
    let startDate: String
    let endDate: String
    let daysOfWeek: [DayOfWeek]
    let startTime: String
    let endTime: String
}

enum DayOfWeek: String, Codable {
    case mon = "MON"
    case tue = "TUE"
    case wed = "WED"
    case thu = "THU"
    case fri = "FRI"
    case sat = "SAT"
    case sun = "SUN"
}

struct CreateScheduleResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: CreateScheduleSuccess?
}

struct CreateScheduleSuccess: Decodable {
    let fixedScheduleIds: [Int]
    let title: String
    let startDate: String
    let endDate: String
    let daysOfWeek: [DayOfWeek]
    let startTime: String
    let endTime: String
}

// MARK: - 고정 일정 목록 조회
struct ScheduleListResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: ScheduleListSuccess?
}


struct ScheduleListSuccess: Decodable {
    let fixedSchedules: [FixedSchedule]
}

struct FixedSchedule: Decodable {
    let id: Int
    let title: String
    let date: String
    let startAt: String
    let endAt: String
}

// MARK: - 고정 일정 수정
struct EditScheduleRequestDTO: Encodable {
    let title: String?
    let startDate: String?
    let endDate: String?
    let daysOfWeek: [DayOfWeek]?
    let startTime: String?
    let endTime: String?
}

// 고정 일정, 내 활동 수정 응답 동일
struct EditResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: EditSuccess?
}

struct EditSuccess: Decodable {
    let msg: String
}

// MARK: - 고정 일정 삭제, 내 활동 삭제
struct DeleteResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: DeleteSuccess?
}

struct DeleteSuccess: Decodable {
    let deleted: Bool
    let message: String
}

// MARK: - 할 일 조회
struct ToDoListResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: [ToDoListSuccess]?
}

struct ToDoListSuccess: Decodable {
    let id: Int
    let title: String
    let type: String
    let category: TodoCategory
    let point: Int
    let eventColor: Int
    let startAt: String
    let endAt: String
    let status: String
}

// MARK: - 할 일 완료
struct ToDoCompletedResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: ToDoCompletedSuccess?
}

struct ToDoCompletedSuccess: Decodable {
    let todoId: Int
}

// MARK: - 내 활동 생성
struct CreateMyActivityRequestDTO: Encodable {
    let activityId: Int?
    let title: String
    let category: TodoCategory
    let point: Int
    let startDate: String
    let endDate: String
    let startTime: String
    let endTime: String
}

struct CreateMyActivityResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: CreateMyActivitySuccess?
}

struct CreateMyActivitySuccess: Decodable {
    let myActivityId: Int
}

// MARK: - 내 활동 상세 조회
struct MyActivityDetailResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: MyActivityDetailSuccess?
}

struct MyActivityDetailSuccess: Decodable {
    let myActivityId: Int
    let title: String
    let category: TodoCategory
    let point: Int
    let startAt: String
    let endAt: String
    let completed: Bool
}

// MARK: - 내 활동 수정
struct EditMyActivityRequestDTO: Encodable {
    let title: String?
    let category: TodoCategory?
    let point: Int?
    let startDate: String?
    let endDate: String?
    let startTime: String?
    let endTime: String?
}

// MARK: - 활동 완료 처리
struct CompleteMyActivityResponse: Decodable {
    let resultType: String
    let error: ErrorDTO?
    let success: CompleteMyActivitySuccess?
}

struct CompleteMyActivitySuccess: Decodable {
    let myActivityId: Int
    let beforeProgress: ActivityProgress
    let afterProgress: ActivityProgress
}

struct ActivityProgress: Decodable {
    let growthAchieved: Int
    let restAchieved: Int
}
