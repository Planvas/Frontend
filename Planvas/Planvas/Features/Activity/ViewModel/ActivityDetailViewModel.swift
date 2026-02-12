//
//  ActivityDetailViewModel.swift
//  Planvas
//
//  Created by 정서영 on 2/12/26.
//

import Foundation
import Combine

@Observable
class ActivityDetailViewModel {
    var title: String = "SK 하이닉스 2025 하반기 청년 Hy-Five 14기 모집"
    var dDay: Int = 16
    var date: String = "11/15 ~ 12/3"
    var category: TodoCategory = .growth
    var point: Int = 30
    var description: String = "SK 하이닉스 2025 하반기 청년 Hy-Five 14기 모집합니다. 본문 들어갈 자리"
    var thumbnailUrl: String = ""
}
