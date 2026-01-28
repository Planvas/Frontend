//
//  MainViewModel.swift
//  Planvas
//
//  Created by 정서영 on 1/26/26.
//

import SwiftUI
import Combine

class MainViewModel: ObservableObject {
    // MARK: - 메인 페이지 목표 세팅 상태별 메세지
    // ing: 진행 중인 목표 존재, end: 활동 기간 종료, none: 목표 없음
    @Published var goalSetting: GoalSetting = .end
    
    var StateTitle: String {
        switch goalSetting {
        case .ing:
            return "지수님, 반가워요!"
        case .end:
            return "활동 기간이 \n종료되었어요"
        case .none:
            return "새로운 목표를 \n세워주세요!"
        }
    }
    
    var StateDescription: String {
        switch goalSetting {
        case .ing:
            return "바라는 모습대로 만든 균형에 맞춰 일상을 채워보세요\n그 시도만으로도 확실한 성취입니다"
        case .end:
            return "목표한 균형을 잘 지켰는지 확인해보세요"
        case .none:
            return "이번 시즌,\n지수님이 바라는 모습은 무엇인가요?"
        }
    }
    
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
}
