//
//  ActivityDetailViewModel.swift
//  Planvas
//
//  Created by 정서영 on 2/12/26.
//

import Foundation
import Observation

@Observable
class ActivityDetailViewModel {

    private let activity: ActivityDetail

    init(activity: ActivityDetail) {
        self.activity = activity
    }
    
    var title: String {
        activity.title
    }
    
    var dDayText: String {
        "D-\(activity.dDay)"
    }
    
    var date: String {
        activity.date
    }
    
    var categoryText: String {
        activity.category == .growth
        ? "성장 +\(activity.point)"
        : "휴식 +\(activity.point)"
    }
    
    var description: String {
        activity.description
    }
    
    var thumbnailUrl: String {
        activity.thumbnailUrl
    }
}
