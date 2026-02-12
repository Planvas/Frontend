import Moya
import Combine
import CombineMoya
import Foundation
import Observation

@Observable
class CartViewModel {
    var cartSuccessData: CartListSuccess?
    var errorMessage: String?
    var isLoading: Bool = false
    var toastMessage: String?
    var showToast: Bool = false
    
    private let provider = APIManager.shared.testProvider(for: ActivityAPI.self)
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - 장바구니 조회
    func fetchCartList(for tab: TodoCategory) {
        self.isLoading = true
        provider.requestPublisher(.getCartList(tab: tab))
            .map(CartListResponse.self)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveSubscription: { [weak self] _ in self?.isLoading = true },
                receiveCompletion: { [weak self] _ in self?.isLoading = false },
                receiveCancel: { [weak self] in self?.isLoading = false}
            )
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] response in
                self?.cartSuccessData = response.success
            })
            .store(in: &cancellable)
    }
}
