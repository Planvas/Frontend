//
//  MainRoute.swift
//  Planvas
//
//  Created by 정서영 on 1/22/26.
//

import Foundation

enum MainRoute: Hashable {
    case main
    case activityDetail(activityId: Int)
//    case onboarding
    case finalReport(goalId: Int)
}
