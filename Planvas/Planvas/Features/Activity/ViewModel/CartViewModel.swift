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
    // 메시지 변수
    var successMessage: String?
    var alertErrorMessage: String?
    // 시트 제어를 위한 상태
    var showAddActivity = false
    var addActivityViewModel: AddActivityViewModel?
    var selectedItemForAdd: CartItem?
    // 서버에서 받아온 goalId
    var currentGoalId: Int?
    
    private let repository: ActivityRepositoryProtocol = ActivityAPIRepository()
    private let provider = APIManager.shared.createProvider(for: ActivityAPI.self)
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - 데이터 형식 바꾸기
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
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
                    self?.alertErrorMessage = "장바구니를 불러오지 못했어요"
                }
            }, receiveValue: { [weak self] response in
                self?.cartSuccessData = response.success
            })
            .store(in: &cancellable)
    }
    
    // MARK: - 장바구니 삭제
    func deleteCartItem(id: Int, isAfterAdding: Bool = false) {
        provider.requestPublisher(.deleteCart(cartItemId: id))
            .map(DeleteCartItemResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    if isAfterAdding { return } // 활동 추가 후의 삭제면 에러 무시
                    
                    self?.errorMessage = "삭제 실패: \(error.localizedDescription)"
                    self?.alertErrorMessage = "삭제를 실패했어요"
                }
            }, receiveValue: { [weak self] response in
                if response.success?.deleted == true {
                    withAnimation {
                        self?.cartSuccessData?.items.removeAll { $0.cartItemId == id }
                    }
                    
                    if isAfterAdding {
                        self?.successMessage = "일정에서 추가되어 장바구니에서 삭제되었습니다."
                    } else {
                        self?.successMessage = "장바구니에서 삭제되었습니다."
                    }
                }
            })
            .store(in: &cancellable)
    }
    
    // MARK: - 일정 추가 시트 (장바구니 조회 API + 현재 목표 조회 API)
    func prepareAddActivitySheet(for item: CartItem) {
        // 일단 장바구니에 있는 데이터로 뷰모델 초기화
        let vm = AddActivityViewModel()
        vm.title = item.title
        vm.activityValue = item.point
        vm.growthLabel = (item.category == .growth) ? "성장" : "휴식"
        
        // 옵셔널 값이기 때문에
        if let startStr = item.startDate {
            vm.startDate = dateFormatter.date(from: startStr) ?? Date()
        } else {
            vm.startDate = Date()
        }
        
        if let endStr = item.endDate {
            vm.endDate = dateFormatter.date(from: endStr) ?? Date()
        } else {
            vm.endDate = Date()
        }
        vm.updateTargetPeriodFromDates()
        
        self.selectedItemForAdd = item
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
                    self.currentGoalId = 1
                    self.showAddActivity = true
                }
            }
        }
    }
    
    // MARK: - 내 일정에 추가 (POST)
    func submitActivity() {
        guard let vm = addActivityViewModel else { print("에러: addActivityViewModel이 nil입니다."); return }
        guard let goalId = self.currentGoalId else { print("에러: currentGoalId가 nil입니다. (현재 목표 조회 실패했을 수도 있음)"); return }
        guard let item = selectedItemForAdd else { print("에러: selectedItemForAdd가 nil입니다."); return }
        
        let requestBody = AddMyActivityRequestDTO(
            goalId: goalId,
            startDate: dateFormatter.string(from: vm.startDate),
            endDate: dateFormatter.string(from: vm.endDate),
            point: vm.activityValue
        )
        
        provider.requestPublisher(.postAddToMyActivities(activityId: item.activityId, body: requestBody))
            .map(AddMyActivityResponse.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.errorMessage = "일정 추가 실패 \(error.localizedDescription)"
                    self?.alertErrorMessage = "기존에 존재하는 일정과 겹칩니다."
                }
            }, receiveValue: { [weak self] response in
                if response.resultType == "SUCCESS" {
                    self?.showAddActivity = false
                    self?.successMessage = "일정에 성공적으로 반영되었습니다!"
                    self?.deleteCartItem(id: item.cartItemId, isAfterAdding: true)
                }
            })
            .store(in: &cancellable)
    }
}
