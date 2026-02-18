//
//  AddTodoViewModel.swift
//  Planvas
//
//  Created by 정서영 on 2/18/26.
//

import Foundation
import Observation
import Moya

@MainActor
@Observable
final class AddTodoViewModel {
    
    // MARK: - 기본 이벤트 정보
    var eventName: String = ""
    var startDate: Date = Date()
    var endDate: Date = Date()
    var isAllDay: Bool = false
    var selectedColor: EventColorType = .red
    
    // MARK: - 활동치 설정
    var isActivityEnabled: Bool = false
    var selectedActivityType: ActivityType = .growth
    var growthValue: Int = 20
    var restValue: Int = 20
    var currentGrowthAchievement: Int = 0
    var currentRestAchievement: Int = 0
    var targetGrowthAchievement: Int = 40
    var targetRestAchievement: Int = 40
    
    enum ActivityType {
        case growth
        case rest
    }
    
    // MARK: - Color Picker
    let availableColors: [EventColorType] = [ .purple2, .blue1, .red, .yellow, .blue2, .pink, .green, .blue3, .ccc, .purple1 ]
    
    // MARK: - Activity Computed Properties
    
    var currentActivityValue: Int {
        selectedActivityType == .growth ? growthValue : restValue
    }
    
    var currentAchievement: Int {
        selectedActivityType == .growth ? currentGrowthAchievement : currentRestAchievement
    }
    
    var targetAchievement: Int {
        selectedActivityType == .growth ? targetGrowthAchievement : targetRestAchievement
    }
    
    var displayProgress: Int {
        min(currentAchievement + currentActivityValue, targetAchievement)
    }
    
    var progressRatio: CGFloat {
        guard targetAchievement > 0 else { return 0 }
        return min(
            CGFloat(currentAchievement + currentActivityValue) /
            CGFloat(targetAchievement),
            1.0
        )
    }
    
    func isActivityTypeSelected(_ type: ActivityType) -> Bool {
        selectedActivityType == type
    }
    
    // MARK: - 목표 기간 (View에서 사용)
    var targetPeriod: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        
        let calendar = Calendar.current
        if calendar.isDate(startDate, inSameDayAs: endDate) {
            return formatter.string(from: startDate)
        }
        
        return "\(formatter.string(from: startDate)) ~ \(formatter.string(from: endDate))"
    }
    
    // MARK: - Activity Value Control
    
    func incrementActivityValue() {
        if selectedActivityType == .growth {
            if currentGrowthAchievement + growthValue + 10 <= targetGrowthAchievement {
                growthValue += 10
            }
        } else {
            if currentRestAchievement + restValue + 10 <= targetRestAchievement {
                restValue += 10
            }
        }
    }
    
    func decrementActivityValue() {
        if selectedActivityType == .growth {
            growthValue = max(0, growthValue - 10)
        } else {
            restValue = max(0, restValue - 10)
        }
    }
    
    private let provider = APIManager.shared.createProvider(for: SchedulesAPI.self)
    func saveTodo(date: Date) {
        let request = AddTodoRequest(
            title: eventName.isEmpty ? "이름 없음" : eventName,
            category: selectedActivityType == .growth ? "GROWTH" : "REST",
            point: isActivityEnabled ? currentActivityValue : 0,
            eventColor: selectedColor.serverColor,
            startTime: startDate.toTimeString(),
            endTime: endDate.toTimeString()
        )
        
        let dateString = date.toDateString()
        
        provider.request(.postTodo(date: dateString, AddTodoRequest: request)) { result in
            switch result {
            case .success(let response):
                    do {
                        let decodedData = try JSONDecoder().decode(AddToDoResponse.self, from: response.data)
                        DispatchQueue.main.async {
                            if decodedData.success != nil {
                                print("투두 생성 성공")
                            }
                        }
                    } catch {
                        print("todo 생성 디코더 오류: \(error)")
                    }
                case .failure(let error):
                    print("todo 생성 API 오류: \(error)")
                }
            }
    }
}
