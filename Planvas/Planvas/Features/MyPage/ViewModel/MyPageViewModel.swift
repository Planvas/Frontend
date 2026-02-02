import Foundation
import Combine
import Moya
import Alamofire

class MyPageViewModel: ObservableObject {
    @Published var goalData: GoalSuccessResponse?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    private let provider = TokenProvider<MyPageRouter>(isStub: true)
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - 현재 목표 조회
    func fetchGoal() {
        provider.requestPublisher(.getCurrentGoal)
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
    
    // MARK: - 뷰에서 사용할 가공된 데이터
    /// 시작/종료 날짜를 (년, 월, 일) 튜플로 반환
    var startDate: (year: String, month: String, day: String)? {
        guard let startDateString = goalData?.startDate else { return nil }
        
        let array = startDateString.split(separator: "-").map { String($0) }
        
        if array.count == 3 {
            return (String(Int(array[0])!), String(Int(array[1])!), String(Int(array[2])!))
        }
        return nil
    }
    var endDate: (year: String, month: String, day: String)? {
        guard let endDateString = goalData?.endDate else { return nil }
        
        let array = endDateString.split(separator: "-").map { String($0) }
        
        if array.count == 3 {
            return (String(Int(array[0])!), String(Int(array[1])!), String(Int(array[2])!))
        }
        return nil
    }
}
