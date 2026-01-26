//
//  MainViewModel.swift
//  Planvas
//
//  Created by 정서영 on 1/26/26.
//

import SwiftUI
import Combine

class MainViewModel: ObservableObject {
    
    // ing: 진행 중인 목표 존재, end: 활동 기간 종료, none: 목표 없음
    @Published var goalSetting: GoalSetting = .ing
    
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
}
