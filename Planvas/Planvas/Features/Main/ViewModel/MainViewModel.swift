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
    
    var stateTitle: String {
        switch goalSetting {
        case .ACTIVE:
            return "지수님, \n반가워요!"
        case .ENDED:
            return "지수님, \n활동 기간이 \n종료되었어요"
        case .NONE:
            return "지수님, \n새로운 목표를 \n세워주세요!"
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
        schedules = [
            Schedule(
                startDate: date("2026-02-04"),
                endDate: nil,
                title: "동아리 신청",
                type: .yellow
            ),
            Schedule(
                startDate: date("2026-02-04"),
                endDate: nil,
                title: "과제 제출",
                type: .red
            ),
            Schedule(
                startDate: date("2026-02-06"),
                endDate: date("2026-02-09"),
                title: "베트남 여행",
                type: .blue
            )
        ]
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
    @Published var todayTodos: [ToDo] = [
        ToDo(
            typeColor: .calRed,
            title: "카페 알바",
            isFixed: true,
            todoInfo: "매주 수요일 18:00 - 22:00",
            startTime: "18:00",
            isCompleted: false
        ),
        ToDo(
            typeColor: .calRed,
            title: "방탈출 카페",
            isFixed: false,
            todoInfo: "휴식 +20",
            startTime: "17:00",
            isCompleted: true
        )
    ]
    
    // 체크 토글
    func toggleTodo(_ todo: ToDo) {
        guard let index = todayTodos.firstIndex(where: { $0.id == todo.id }) else { return }
        todayTodos[index].isCompleted.toggle()
    }
    
    // MARK: - 오늘의 인기 성장 활동
    @Published var items: [ActivityItem] = [
        ActivityItem(
            title: "SK 하이닉스 2025 하반기 \n청년 Hy-Five 14기 모집",
            subtitle: "고품질의 반도체 직무 교육 \n& SK 하이닉스 협력사 ",
            imageName: "banner1"
        ),
        ActivityItem(
            title: "SK 하이닉스",
            subtitle: "청년 Hy-Five",
            imageName: "banner2"
        ),
        ActivityItem(
            title: "추천 공고 3",
            subtitle: "설명 3",
            imageName: "banner3"
        ),
        ActivityItem(
            title: "추천 공고 4",
            subtitle: "설명 4",
            imageName: "banner4"
        )
    ]
    
    
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
                            self.goalSetting = success.goalStatus
                            self.goalTitle = success.currentGoal.title
                            self.dDay = success.currentGoal.dDay
                            self.growthRatio = success.currentGoal.growthRatio
                            self.restRatio = success.currentGoal.restRatio
                            self.growthAchieved = success.progress.growthAchieved
                            self.restAchieved = success.progress.restAchieved
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
