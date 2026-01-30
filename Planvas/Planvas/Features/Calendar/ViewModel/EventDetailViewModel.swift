//
//  EventDetailViewModel.swift
//  Planvas
//
//  Created by 백지은 on 1/26/26.
//

import Foundation
import Combine

@MainActor
class EventDetailViewModel: ObservableObject {
    // MARK: - Event Data
    @Published var event: Event?
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    @Published var daysUntil: Int?
    @Published var targetPeriod: String?
    
    // MARK: - Activity Settings State
    @Published var showActivitySettings = false
    @Published var selectedActivityType: ActivityType = .growth
    
    // 성장/휴식 각각의 활동치
    @Published var growthValue: Int = 20
    @Published var restValue: Int = 20
    
    // 성장/휴식 각각의 현재 달성률
    @Published var currentGrowthAchievement: Int = 0
    @Published var currentRestAchievement: Int = 0
    
    // 성장/휴식 각각의 목표 달성률
    @Published var targetGrowthAchievement: Int = 60
    @Published var targetRestAchievement: Int = 50
    
    enum ActivityType {
        case growth
        case rest
    }
    
    // MARK: - Computed Properties
    
    /// 현재 선택된 타입의 활동치
    var currentActivityValue: Int {
        selectedActivityType == .growth ? growthValue : restValue
    }
    
    /// 현재 선택된 타입의 현재 달성률
    var currentAchievement: Int {
        selectedActivityType == .growth ? currentGrowthAchievement : currentRestAchievement
    }
    
    /// 현재 선택된 타입의 목표 달성률
    var targetAchievement: Int {
        selectedActivityType == .growth ? targetGrowthAchievement : targetRestAchievement
    }
    
    /// 진행바에 표시할 퍼센트 값
    var displayProgress: Int {
        min(currentAchievement + currentActivityValue, targetAchievement)
    }
    
    /// 진행바 너비 비율 (0.0 ~ 1.0)
    var progressRatio: CGFloat {
        guard targetAchievement > 0 else { return 0 }
        return min(CGFloat(currentAchievement + currentActivityValue) / CGFloat(targetAchievement), 1.0)
    }
    
    // MARK: - Initialization
    
    func configure(
        event: Event,
        startDate: Date,
        endDate: Date,
        daysUntil: Int?,
        targetPeriod: String?
    ) {
        self.event = event
        self.startDate = startDate
        self.endDate = endDate
        self.daysUntil = daysUntil
        self.targetPeriod = targetPeriod
        
        // 이벤트 카테고리에 따라 초기 상태 설정
        switch event.category {
        case .growth:
            self.selectedActivityType = .growth
            self.showActivitySettings = true
        case .rest:
            self.selectedActivityType = .rest
            self.showActivitySettings = true
        case .none:
            self.selectedActivityType = .growth
            self.showActivitySettings = false
        }
    }
    
    // MARK: - Activity Value Methods
    
    func incrementActivityValue() {
        if selectedActivityType == .growth {
            // 목표 달성률을 초과하지 않도록 제한
            if currentGrowthAchievement + growthValue + 10 <= targetGrowthAchievement {
                growthValue += 10
            }
        } else {
            // 목표 달성률을 초과하지 않도록 제한
            if currentRestAchievement + restValue + 10 <= targetRestAchievement {
                restValue += 10
            }
        }
    }
    
    func decrementActivityValue() {
        if selectedActivityType == .growth {
            if growthValue > 0 { growthValue -= 10 }
        } else {
            if restValue > 0 { restValue -= 10 }
        }
    }
    
    /// 특정 활동 타입이 선택되었는지 확인
    func isActivityTypeSelected(_ type: ActivityType) -> Bool {
        selectedActivityType == type
    }
    
    // MARK: - Actions
    
    func toggleActivitySettings() {
        showActivitySettings = true
    }
    
    func selectActivityType(_ type: ActivityType) {
        selectedActivityType = type
    }
}
