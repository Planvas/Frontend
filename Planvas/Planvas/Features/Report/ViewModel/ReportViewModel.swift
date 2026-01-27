import Foundation
import Moya
import Combine

class RouterViewModel:ObservableObject {
    @Published var reportData: ReportSuccessResponse?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    private let provider = TokenProvider<ReportRouter>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 최종 리포트 가져오기
    func fetchReport(goalId: String) {
        self.isLoading = true
        self.errorMessage = nil
        
        provider.requestPublisher(.getReport(goalId: goalId))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { (response: ReportResponse) in
                if response.resultType == "SUCCESS", let successData = response.success {
                    self.reportData = successData
                } else {
                    self.errorMessage = response.error?.reason ?? "알 수 없는 오류가 발생했습니다."
                }
            })
            .store(in: &cancellables)
    }
}
