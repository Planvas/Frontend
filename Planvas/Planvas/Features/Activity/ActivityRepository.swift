//
//  ActivityRepository.swift
//  Planvas
//
//  Created by 최우진 on 1/28/26.
//

import Foundation

protocol ActivityRepositoryProtocol {
    func fetchActivities() -> [Activity]
}

struct ActivityRepository: ActivityRepositoryProtocol {
    func fetchActivities() -> [Activity] {
        [
            Activity(
                title: "패스트캠퍼스\n2025 AI 대전환\n오픈 세미나",
                growth: 10,
                dday: "9",
                badgeText: "일정 가능",
                badgeType: .available,
                imageName: "성장활동사진1"
            ),
            Activity(
                title: "SK 하이닉스\n2025 하반기 청년\nHy-Five 14기 모집",
                growth: 30,
                dday: "16",
                badgeText: "일정 주의",
                badgeType: .caution,
                tipTag: "Tip",
                tipT: "[카페 알바]",
                tipText: "일정이 있어요! 시간을 쪼개서 계획해 보세요"
            ),
            Activity(
                title: "드림 온 아카데미\n마스터 스킬 - 엑셀 활용법 단기 특강",
                growth: 10,
                dday: "15",
                badgeText: "일정 겹침",
                badgeType: .conflict,
                tipTag: "주의",
                tipT: "[카페 알바]",
                tipText: "일정과 겹쳐요!"
            ),
            Activity(
                title: "SK 하이닉스\n2025 하반기 청년\nHy-Five 14기 모집",
                growth: 30,
                dday: "16",
                badgeText: "일정 겹침",
                badgeType: .conflict,
                tipTag: "Tip",
                tipT: "[카페 알바]",
                tipText: "일정이 있어요! 시간을 쪼개서 계획해 보세요"
            )

        ]
    }
}
