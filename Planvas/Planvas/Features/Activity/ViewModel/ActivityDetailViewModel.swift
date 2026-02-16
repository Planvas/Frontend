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
@MainActor
class ActivityDetailViewModel {
    // MARK: - 도메인 모델
    var activityId: Int?
    var goalId: Int?
    private(set) var activity: ActivityDetail?

    init(
        activity: ActivityDetail? = nil,
        repository: ActivityRepositoryProtocol = ActivityAPIRepository()
    ) {
        self.activity = activity
        self.repository = repository
    }
    
    var title: String {
        activity?.title ?? ""
    }

    var dDayText: String {
        guard let dDay = activity?.dDay else { return "" }
        return "D-\(dDay)"
    }

    var date: String {
        guard let activity,
              let start = activity.startDate,
              let end = activity.endDate
        else { return activity?.date ?? "" }

        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"

        let startString = formatter.string(from: start)
        let endString = formatter.string(from: end)

        return "\(startString) ~ \(endString)"
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

    var thumbnailURL: URL? {
        guard let urlString = activity?.thumbnailUrl else { return nil }
        return URL(string: urlString)
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
    
    // 활동 -> 일정
    // MARK: - UI 상태
    var isLoading = false
    var errorMessage: String?
    var showAddActivity = false
    var addActivityViewModel: AddActivityViewModel?
    var addSuccessMessage: String?
    var addErrorMessage: String?

    private let repository: ActivityRepositoryProtocol
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    nonisolated init(repository: ActivityRepositoryProtocol = ActivityAPIRepository()) {
        self.repository = repository
    }

    // MARK: - 활동 상세 로드 + 현재 goalId 조회
    func loadDetailIfNeeded() async {
        guard let id = activityId else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            async let detailTask = repository.getActivityDetail(activityId: id)
            async let goalTask = repository.getCurrentGoalId()
            activity = try await detailTask
            goalId = try await goalTask
        } catch {
            errorMessage = (error as? ActivityAPIError)?.reason ?? error.localizedDescription
        }
    }

    // MARK: - 일정 추가 시트 열기
    func openAddActivitySheet() {
        guard let activity else { return }
        let vm = AddActivityViewModel()
        vm.title = activity.title
        vm.activityValue = activity.defaultPoint
        vm.recommendedPoint = activity.defaultPoint
        vm.growthLabel = activity.growthLabel
        vm.startDate = activity.startDate ?? Date()
        vm.endDate = activity.endDate ?? Date()
        vm.updateTargetPeriodFromDates()
        addActivityViewModel = vm
        showAddActivity = true
    }

    /// 시트 닫힐 때 호출
    func clearAddActivitySheet() {
        addActivityViewModel = nil
    }

    // MARK: - 내 일정에 추가 (POST /api/activities/{activityId}/my-activities)
    func submitAddToMyActivities() async {
        guard let vm = addActivityViewModel else { return }
        guard let id = activityId, let goalId else {
            showAddActivity = false
            addErrorMessage = "목표 정보가 없습니다."
            return
        }
        let startStr = dateFormatter.string(from: vm.startDate)
        let endStr = dateFormatter.string(from: vm.endDate)
        do {
            _ = try await repository.addToMyActivities(activityId: id, goalId: goalId, startDate: startStr, endDate: endStr, point: vm.activityValue)
            showAddActivity = false
            addSuccessMessage = "일정에 추가되었어요"
        } catch {
            addErrorMessage = (error as? ActivityAPIError)?.reason ?? error.localizedDescription
        }
    }
    
    // MARK: - 장바구니 담기 (POST /api/cart)
    func addToCart() async {
        guard let id = activityId else { return }
        isLoading = true
        addErrorMessage = nil
        addSuccessMessage = nil
        defer { isLoading = false }
        
        do {
            _ = try await repository.postCart(activityId: id)
            addSuccessMessage = "장바구니에 담겼습니다!"
        } catch {
            if let apiError = error as? ActivityAPIError {
                switch apiError {
                case .serverFail(let reason):
                    addErrorMessage = reason
                case .invalidResponse:
                    addErrorMessage = "응답 형식 오류"
                }
            } else {
                addErrorMessage = "서버 연결에 실패했습니다"
            }
        }
        
        isLoading = false
    }
}

extension ActivityAPIError {
    var reason: String? {
        switch self {
        case .serverFail(let reason): return reason
        case .invalidResponse: return "응답 형식 오류"
        case .scheduleConflict(let r): return r ?? "일정이 충돌해 추가할 수 없어요"
        case .activityNotFound(let r): return r ?? "해당 활동을 찾을 수 없어요"
        case .badRequest(let r): return r ?? "요청 값이 올바르지 않아요"
        }
    }
}
