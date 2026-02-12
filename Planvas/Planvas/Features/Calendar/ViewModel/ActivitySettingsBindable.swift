//
//  ActivitySettingsBindable.swift
//  Planvas
//
//  활동치 설정 섹션(ActivitySettingsSectionView)에서 사용하는 공통 인터페이스.
//  EventDetailViewModel, AddActivityViewModel 등이 준수합니다.
//

import Foundation

protocol ActivitySettingsBindable: AnyObject {
    /// 현재 달성률 라벨 (예: "성장", "휴식")
    var growthLabel: String { get }
    /// 현재 달성률 퍼센트
    var currentAchievementPercent: Int { get }
    /// 목표 퍼센트
    var goalPercent: Int { get }
    /// 추천 활동치 (API defaultPoint)
    var recommendedPoint: Int { get }
    /// 활동치 값 (10 단위 조절)
    var activityValue: Int { get set }
    /// 추가 활동치 문구 (예: "+20%")
    var addedPercentText: String { get }
    func incrementActivityValue()
    func decrementActivityValue()
}
