//
//  MainViewModel.swift
//  Planvas
//
//  Created by 정서영 on 1/26/26.
//

import SwiftUI
import Combine
import Moya

class MainViewModel: ObservableObject {
    // MARK: - 메인 페이지 목표 세팅 상태별 메세지
    // ACTIVE: 진행 중인 목표 존재, ENDED: 활동 기간 종료, NONE: 목표 없음
    @Published var goalSetting: GoalSetting = .ACTIVE
    @Published var username: String = ""
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
    @Published var goalTitle: String = ""
    @Published var dDay: Int = 0
    @Published var growthRatio: Int = 0
    @Published var restRatio: Int = 0
    @Published var growthAchieved: Int = 0
    @Published var restAchieved: Int = 0
    
    // MARK: - 위클리 캘린더
    @Published var centerDate: Date = Date()
    @Published var selectedDate: Date = Date()
    
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
    
    // 일정 더미 데이터
    @Published var schedules: [Schedule] = []
    
    init() {
        schedules = []
    }
    
    func schedules(for date: Date) -> [Schedule] {
        schedules.filter { schedule in
            if let endDate = schedule.endDate {
                return date >= schedule.startDate && date <= endDate
            } else {
                return Calendar.current.isDate(date, inSameDayAs: schedule.startDate)
            }
        }
    }

    // MARK: - 오늘의 할 일
    @Published var todayTodos: [ToDo] = []
    
    // 체크 토글
    func toggleTodo(_ todo: ToDo) {
        guard let index = todayTodos.firstIndex(where: { $0.id == todo.id }) else { return }
        todayTodos[index].isCompleted.toggle()
    }
    
    // MARK: - 오늘의 인기 성장 활동
    @Published var items: [ActivityItem] = []
    
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
                            
                            // TODO: - 캘린더 UI 백엔드 데이터에 맞게 수정한 후 데이터 가져오기
                            // 캘린더 데이터
                            
                            // 투두 데이터
                            if let todos = success.todayTodos {
                                self.todayTodos = todos.map {
                                    ToDo(
                                        typeColor: .calRed,
                                        title: $0.title,
                                        isFixed: false,
                                        todoInfo: "",
                                        startTime: "",
                                        isCompleted: $0.completed
                                    )
                                }
                            } else {
                                self.todayTodos = []
                            }
                            
                            // 인기 활동 데이터
                            if let recs = success.recommendations {
                                self.items = recs.map {
                                    ActivityItem(
                                        title: $0.title,
                                        subtitle: $0.subTitle,
                                        imageName: ""
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
}
