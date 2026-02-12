//
//  ActivityCompleteAlertViewModel.swift
//  Planvas
//
//  Created by 백지은 on 2/12/26.
//

import Foundation

@MainActor
@Observable
final class ActivityCompleteAlertViewModel {
    var title: String
    var subtitle: String
    var category: String
    var growthValue: Int
    var progressMinPercent: Int
    var goalPercent: Int
    var currentPercent: Int
    var confirmButtonTitle: String

    init(
        title: String = "활동 완주, 정말 고생 많았어요!",
        subtitle: String = "목표 달성에 한 걸음 더 가까워졌네요",
        category: String = "성장",
        growthValue: Int = 30,
        progressMinPercent: Int = 10,
        goalPercent: Int = 70,
        currentPercent: Int = 40,
        confirmButtonTitle: String = "확인"
    ) {
        self.title = title
        self.subtitle = subtitle
        self.category = category
        self.growthValue = growthValue
        self.progressMinPercent = progressMinPercent
        self.goalPercent = goalPercent
        self.currentPercent = currentPercent
        self.confirmButtonTitle = confirmButtonTitle
    }

    var progressRatio: CGFloat {
        guard goalPercent > progressMinPercent else { return 0 }
        return CGFloat(currentPercent) / CGFloat(goalPercent)
    }
}
