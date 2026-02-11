import Foundation
import Combine
import Moya
import Alamofire
import Observation
import CombineMoya

@Observable
class MyPageViewModel {
    var goalData: GoalSuccessResponse?
    var userData: UserSuccessResponse?
    var isCalendarConnected: Bool = false
    var errorMessage: String?
    var isLoading: Bool = false
    
    private let calendarRepository: CalendarRepositoryProtocol = CalendarAPIRepository()
    private let provider = APIManager.shared.createProvider(for: MyPageRouter.self)
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - 마이페이지 데이터 초기화
    func fetchMyPageData() async{
        await checkCalendarStatus() // 캘린더 상태 확인
        fetchGoal() // 기존 목표 조회
        fetchUser() // 유저 데이터 조회
    }
    
    // MARK: - 캘린더 연동 상태 조회
    private func checkCalendarStatus() async {
        do {
            let status = try await calendarRepository.getGoogleCalendarStatus()
            self.isCalendarConnected = status.connected
        } catch {
            self.isCalendarConnected = false
            print("캘린더 상태 조회 실패: \(error)")
        }
    }
    
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
    
    // MARK: - 내 정보 조회
    func fetchUser() {
        provider.requestPublisher(.getUserInfo)
            .map(UserResponse.self)
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
                receiveValue: { [weak self] (response: UserResponse) in
                    if response.resultType == "SUCCESS" {
                        self?.userData = response.success?.user
                        self?.errorMessage = nil
                    } else {
                        self?.errorMessage = response.error?.reason ?? "알 수 없는 오류가 발생했습니다."
                    }
                })
            .store(in: &cancellable)
    }
}
