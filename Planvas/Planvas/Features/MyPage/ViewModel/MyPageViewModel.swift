import Foundation
import Combine
import Moya
import Alamofire
import Observation
import CombineMoya

@Observable
class MyPageViewModel {
    var goalData: GoalSuccessResponse?
    var errorMessage: String?
    var isLoading: Bool = false
    
    private let provider = APIManager.shared.createProvider(for: MyPageRouter.self)
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - 현재 목표 조회
    func fetchGoal() {
        provider.requestPublisher(.getCurrentGoal)
            .map(GoalResponse.self)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveSubscription: { [weak self] _ in self?.isLoading = true },
                receiveCompletion: { [weak self] _ in self?.isLoading = false },
                receiveCancel: { [weak self] in self?.isLoading = false}
            )
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] (response: GoalResponse) in
                    if response.resultType == "SUCCESS" {
                        self?.goalData = response.success
                        self?.errorMessage = nil
                    } else {
                        self?.errorMessage = response.error?.reason ?? "알 수 없는 오류가 발생했습니다."
                    }
                })
            .store(in: &cancellable)
    }
}
