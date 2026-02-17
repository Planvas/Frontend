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
    var selectedDate: Date = Date() {
        didSet {
            fetchTodoData(for: selectedDate)
        }
    }
    
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
        fetchTodoData(for: selectedDate)
    }
    
    // MARK: - 할 일
    var showAddTodo: Bool = false
    var addTodoViewModel: AddActivityViewModel?
    var todos: [ToDo] = []
    
    func AddTodo() {
        //TODO: - 투두 추가 API 연동
        print("할 일 추가하기")
    }
    
    // 체크 토글
    func toggleTodo(_ todo: ToDo) {
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        
        todos[index].isCompleted.toggle()
        fetchTodoStatus(todoId: todo.id)
    }
    
    // MARK: - 오늘의 인기 성장 활동
    var items: [ActivityItem] = []
    
    // MARK: - 메인 페이지 API 연동 함수
    private let provider = APIManager.shared.createProvider(for: MainAPI.self)
    
    // MARK: - 메인 페이지 데이터 조회
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
                                }
                                // 날짜별로 다시 정리
                                for schedule in groupedSchedules.values {
                                    for date in schedule.dates {
                                        result[date, default: []].append(schedule)
                                    }
                                }
                                self.weeklySchedules = result
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
    
    // MARK: - 투두 조회
    private let todoProvider = APIManager.shared.createProvider(for: SchedulesAPI.self)
    
    func fetchTodoData(for date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        let formattedDate = formatter.string(from: date)
        
        todoProvider.request(.getToDo(date: formattedDate)) { result in
            switch result {
            case .success(let response):
                do {
                    let decodedData = try JSONDecoder().decode(ToDoListResponse.self, from: response.data)
                    DispatchQueue.main.async {
                        if let success = decodedData.success {
                            self.todos = success.map { todo in
                                let startTime = self.formatTime(todo.startAt)
                                let endTime = self.formatTime(todo.endAt)

                                return ToDo(
                                    id: todo.id,
                                    typeColor: ScheduleType(rawValue: todo.eventColor) ?? .one,
                                    title: todo.title,
                                    isFixed: todo.type == "FIXED",
                                    time: (startTime == "00:00" && endTime == "23:59")
                                        ? ""
                                        : "\(startTime) - \(endTime)",
                                    point: todo.point == 0
                                        ? ""
                                        : "\(todo.category.displayText) +\(todo.point)",
                                    isCompleted: todo.status == "DONE"
                                )
                            }
                        }
                    }
                } catch {
                    print("Todo 조회 디코더 오류: \(error)")
                }
            case .failure(let error):
                print("Todo 조회 API 오류: \(error)")
            }
        }
    }
    
    // 날짜 + 시간 -> 시간 (HH:mm) 변환 함수
    func formatTime(_ isoString: String) -> String {
        guard let timePart = isoString.split(separator: "T").last else {
            return ""
        }
        return String(timePart.prefix(5))
    }
    
    // MARK: - 투두 완료 상태 토글
    func fetchTodoStatus(todoId: Int) {
        todoProvider.request(.patchToDo(todoId: todoId)) { result in
            switch result {
            case .success(let response):
                do {
                    let decodedData = try JSONDecoder().decode(ToDoCompletedResponse.self, from: response.data)
                    DispatchQueue.main.async {
                        if decodedData.success != nil {
                            print("투두 토글 성공")
                        }
                    }
                } catch {
                    print("todo 디코더 오류: \(error)")
                }
            case .failure(let error):
                print("todo API 오류: \(error)")
            }
        }
    }
    
}
