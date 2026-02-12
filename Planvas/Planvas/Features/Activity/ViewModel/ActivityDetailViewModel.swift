//
//  ActivityDetailViewModel.swift
//  Planvas
//
//  Created by 정서영 on 2/12/26.
//

import Foundation
import Observation
import Moya

@Observable
class ActivityDetailViewModel {

    var activity: ActivityDetail?

    init(activity: ActivityDetail? = nil) {
        self.activity = activity
    }
    
    var title: String {
        activity?.title ?? ""
    }

    var dDayText: String {
        guard let dDay = activity?.dDay else { return "" }
        return "D-\(dDay)"
    }

    var date: String {
        activity?.date ?? ""
    }

    var categoryText: String {
        guard let activity else { return "" }
        return activity.category == .growth
            ? "성장 +\(activity.point)"
            : "휴식 +\(activity.point)"
    }

    var description: String {
        activity?.description ?? ""
    }

    var thumbnailUrl: String {
        activity?.thumbnailUrl ?? ""
    }
    
    private let provider = APIManager.shared.createProvider(for: ActivityAPI.self)
    
    func fetchActivityDetail(activityId: Int) {
        provider.request(.getActivityDetail(activityId: activityId)) { result in
            switch result {
            case .success(let response):
                do {
                    let decodedData = try JSONDecoder().decode(ActivityDetailResponse.self, from: response.data)
                    DispatchQueue.main.async {
                        if let success = decodedData.success {
                            self.activity = success.toDomain()
                        }
                    }
                } catch {
                    print("Main 디코더 오류: \(error)")
                }
            case .failure(let error):
                print("Main API 오류: \(error)")
            }
        }
    }
}
