import Foundation
import Combine
import Moya
import CombineMoya

class PastReportViewModel:ObservableObject {
    @Published var reportsByYear: [Int: [PastReportSuccessResponse]] = [:]
    @Published var sortedYears: [Int] = []
    
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let provider = APIManager.shared.createProvider(for: PastReportRouter.self)
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - 지난 시즌 리포트 조회
    func fetchPastReport(year: Int? = nil) {
        provider.requestPublisher(.getPastReport(year:year))
            .map(PastReportResponse.self)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveSubscription: { [weak self] _ in self?.isLoading = true },
                receiveCompletion: { [weak self] _ in self?.isLoading = false },
                receiveCancel: { [weak self] in self?.isLoading = false }
            )
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print("Network error:", error)
                }
            }, receiveValue: { [weak self] (response: PastReportResponse) in
                self?.errorMessage = nil
                if response.resultType == "SUCCESS" {
                    let seasons = response.success.compactMap{ $0 }
                    self?.groupReportsByYear(seasons: seasons)
                } else {
                    self?.errorMessage = response.error?.reason ?? "알 수 없는 오류 발생"
                }
            })
            .store(in: &cancellable)
    }
    
    // MARK: - 시즌별 리포트를 오름차순으로 저장(연도별로)
    private func groupReportsByYear(seasons: [PastReportSuccessResponse]) {
        // [연도: [해당 연도 리포트]]
        let group = Dictionary(grouping: seasons) { $0.year }
        self.reportsByYear = group
        self.sortedYears = group.keys.sorted(by: <)
    }
}
