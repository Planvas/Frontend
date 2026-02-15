//
//  MainViewModel.swift
//  Planvas
//
//  Created by 정서영 on 1/26/26.
//

import SwiftUI
import Observation
import Moya

@Observable
class MainViewModel {
    // MARK: - 메인 페이지 목표 세팅 상태별 메세지
    // ACTIVE: 진행 중인 목표 존재, ENDED: 활동 기간 종료, NONE: 목표 없음
    var goalSetting: GoalSetting = .ACTIVE
    var username: String = ""
    var stateTitle: String {
        switch goalSetting {
        case .ACTIVE:
            return "\(username)님, \n반가워요!"
        case .ENDED:
            return "\(username)님, \n활동 기간이 \n종료되었어요"
        case .NONE:
            return "\(username)님, \n새로운 목표를 \n세워주세요!"
        }
    }
    
    // MARK: - 현재 목표 정보
    var goalTitle: String = ""
    var dDay: String = ""
    var growthRatio: Int = 0
    var restRatio: Int = 0
    var growthAchieved: Int = 0
    var restAchieved: Int = 0
    
    // MARK: - 위클리 캘린더
    var centerDate: Date = Date()
    var selectedDate: Date = Date()
    
    // 오늘 기준 7일 만들기
    var weekDates: [Date] {
        let calendar = Calendar.current
        return (-3...3).compactMap {
            calendar.date(byAdding: .day, value: $0, to: centerDate)
        }
    }
    // 오늘에 해당하는 월 한글 표시
    var monthText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월"
        return formatter.string(from: centerDate)
    }
    // 오늘에 해당하는 연도 숫자 표시
    var yearText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy"
        return formatter.string(from: centerDate)
    }
    // 날짜 변환 함수
    private func date(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.date(from: string)!
    }
    
    // 일정 데이터
    var weeklySchedules: [Date: [Schedule]] = [:]
    
    func schedules(for date: Date) -> [Schedule] {
        let key = Calendar.current.startOfDay(for: date)
        return weeklySchedules[key] ?? []
    }
    
    init() {
        weeklySchedules = [:]
        weeklyTodo = [:]
    }
    
    // MARK: - 할 일
    var showAddTodo: Bool = false
    var addTodoViewModel: AddActivityViewModel?
    var weeklyTodo: [Date: [ToDo]] = [:]
    
    func AddTodo() {
        //TODO: - 투두 추가 API 연동
        print("할 일 추가하기")
    }
    
    var selectedTodos: [ToDo] {
        let key = Calendar.current.startOfDay(for: selectedDate)
        return weeklyTodo[key] ?? []
    }
    
    // 체크 토글
    func toggleTodo(_ todo: ToDo) {
        let key = Calendar.current.startOfDay(for: selectedDate)
        
        guard var todos = weeklyTodo[key],
              let index = todos.firstIndex(where: { $0.id == todo.id })
        else { return }

        todos[index].isCompleted.toggle()
        weeklyTodo[key] = todos
        fetchScheduleTodo(activityId: todo.id)
    }
    
    // MARK: - 오늘의 인기 성장 활동
    var items: [ActivityItem] = []
    
    // MARK: - 메인 페이지 API 연동 함수
    private let provider = APIManager.shared.createProvider(for: MainAPI.self)
    
    func fetchMainData() {
        provider.request(.getMainData) { result in
            switch result {
            case .success(let response):
                do {
                    let decodedData = try JSONDecoder().decode(MainDataResponse.self, from: response.data)
                    DispatchQueue.main.async {
                        if let success = decodedData.success {
                            // 헤더 데이터
                            self.username = success.userName
                            self.goalSetting = success.goalStatus
                            if let goal = success.currentGoal {
                                self.goalTitle = goal.title
                                self.dDay = goal.dDay
                                self.growthRatio = goal.growthRatio
                                self.restRatio = goal.restRatio
                            }
                            if let achieved = success.progress {
                                self.growthAchieved = achieved.growthAchieved
                                self.restAchieved = achieved.restAchieved
                            }
                            
                            // 캘린더 데이터
                            if let weekly = success.weeklySummary {
                                var result: [Date: [Schedule]] = [:]
                                var todoResult: [Date: [ToDo]] = [:]
                                var groupedSchedules: [Int: Schedule] = [:]
                                
                                for day in weekly.days {
                                    let date = self.date(day.date)
                                    
                                    for schedule in day.schedules {
                                        if var existing = groupedSchedules[schedule.id] {
                                            existing.dates.append(date)
                                            groupedSchedules[schedule.id] = existing
                                        } else {
                                            groupedSchedules[schedule.id] = Schedule(
                                                id: schedule.id,
                                                title: schedule.title,
                                                color: schedule.color,
                                                dates: [date]
                                            )
                                        }
                                    }
                                    
                                    // 스케줄 투두 데이터
                                    let todos = day.schedules.map {
                                        ToDo(
                                            id: $0.id,
                                            typeColor: ScheduleType(rawValue: $0.color) ?? .one,
                                            title: $0.title,
                                            isFixed: $0.type == "FIXED",
                                            todoInfo: "\($0.category.displayText) +\($0.point)",
                                            startTime: "\($0.startTime)",
                                            isCompleted: $0.completed
                                        )
                                    }
                                    
                                    if !todos.isEmpty {
                                        todoResult[date] = todos
                                    }
                                    
                                }
                                // 날짜별로 다시 정리
                                for schedule in groupedSchedules.values {
                                    for date in schedule.dates {
                                        result[date, default: []].append(schedule)
                                    }
                                }
                                
                                self.weeklySchedules = result
                                self.weeklyTodo = todoResult
                            }
                            
                            // 인기 활동 데이터
                            if let recs = success.recommendations {
                                self.items = recs.map {
                                    ActivityItem(
                                        activityId: $0.activityId,
                                        title: $0.title,
                                        subtitle: $0.subTitle ?? "",
                                        imageName: $0.imageUrl
                                    )
                                }
                            } else {
                                self.items = []
                            }
                        }
                    }
                } catch {
                    print("Main 디코더 오류: \(error)")
                }
            case .failure(let error):
                print("Main API 오류: \(error)")
            }
        }
    }
    
    // MARK: - 스케줄 투두 완료 상태 토글
    func fetchScheduleTodo(activityId: Int) {
        provider.request(.patchScheduleTodo(activityId: activityId)) { result in
            switch result {
            case .success(let response):
                do {
                    let decodedData = try JSONDecoder().decode(ScheduleTodoResponse.self, from: response.data)
                    DispatchQueue.main.async {
                        if decodedData.success != nil {
                            print("스케줄 투두 토글 성공")
                        }
                    }
                } catch {
                    print("ScheduleTodo 디코더 오류: \(error)")
                }
            case .failure(let error):
                print("ScheduleTodo API 오류: \(error)")
            }
        }
    }
    // TODO: - 페이지에서만 보이는 투두 api 추가 연동
}
