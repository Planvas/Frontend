import Moya
import Combine
import CombineMoya
import Foundation
import Observation
import SwiftUI

@Observable
class CartViewModel {
    var cartSuccessData: CartListSuccess?
    var errorMessage: String?
    var isLoading: Bool = false
    var toastMessage: String?
    var showToast: Bool = false
    // 시트 제어를 위한 상태
    var showAddActivity = false
    var addActivityViewModel: AddActivityViewModel?
    var selectedItemForAdd: CartItem?
    var currentGoalId: Int?
    
    private let repository: ActivityRepositoryProtocol = ActivityAPIRepository()
        
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
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
    
    // MARK: - 장바구니 삭제
    func deleteCartItem(id: Int) {
        provider.requestPublisher(.deleteCart(cartItemId: id))
            .map(DeleteCartItemResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = "삭제 실패: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] response in
                if response.success?.deleted == true {
                    withAnimation {
                        self?.cartSuccessData?.items.removeAll { $0.cartItemId == id }
                    }
                    self?.toastMessage = "장바구니에서 삭제되었습니다."
                    self?.showToast = true
                }
            })
            .store(in: &cancellable)
    }
    
    // MARK: - 일정 추가 시트 데이터 로드 (조회)
    func prepareAddActivitySheet(for item: CartItem) {
        // 일단 장바구니에 있는 데이터로 뷰모델 초기화
        let vm = AddActivityViewModel()
        vm.title = item.title
        vm.activityValue = item.point
        vm.startDate = dateFormatter.date(from: item.startDate) ?? Date()
        vm.endDate = dateFormatter.date(from: item.endDate) ?? Date()
        vm.updateTargetPeriodFromDates()
        
        self.addActivityViewModel = vm
        
        // 부족한 정보(goalId)는 서버에서 한 번 더 조회 (Lookup)
        _Concurrency.Task {
            do {
                let goalId = try await repository.getCurrentGoalId()
                            
                await MainActor.run {
                    self.currentGoalId = goalId
                    self.showAddActivity = true
                }
            } catch {
                await MainActor.run {
                    self.showAddActivity = true
                }
            }
        }
    }
}
