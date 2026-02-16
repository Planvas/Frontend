import SwiftUI

struct ActivityDetailView: View {
    /// 활동 상세 조회·내 일정 추가 API에 사용. nil이면 로컬 샘플 데이터만 표시.
    var activityId: Int?

    @Environment(NavigationRouter<ActivityRoute>.self) var router
    @State private var viewModel: ActivityDetailViewModel

    /// 활동 상세 데이터 (옵셔널 바인딩 편의용)
    private var activity: ActivityDetail? { viewModel.activity }

    init(activityId: Int? = nil, viewModel: ActivityDetailViewModel = ActivityDetailViewModel()) {
        self.activityId = activityId
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack {
                HeaderGroup
                Spacer()
                BodyGroup
                BottomGroup
                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .task {
            viewModel.activityId = activityId
            await viewModel.loadDetailIfNeeded()
        }
        .sheet(isPresented: $viewModel.showAddActivity) {
            if let addVM = viewModel.addActivityViewModel {
                AddActivityView(viewModel: addVM, onSubmit: {
                    Task { await viewModel.submitAddToMyActivities() }
                })
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
        .onChange(of: viewModel.showAddActivity) { _, isShowing in
            if !isShowing { viewModel.clearAddActivitySheet() }
        }
        .alert("추가 완료", isPresented: Binding(get: { viewModel.addSuccessMessage != nil }, set: { if !$0 { viewModel.addSuccessMessage = nil } })) {
            Button("확인") { viewModel.addSuccessMessage = nil }
        } message: {
            Text(viewModel.addSuccessMessage ?? "")
        }
        .alert("추가 실패", isPresented: Binding(get: { viewModel.addErrorMessage != nil }, set: { if !$0 { viewModel.addErrorMessage = nil } })) {
            Button("확인") { viewModel.addErrorMessage = nil }
        } message: {
            Text(viewModel.addErrorMessage ?? "")
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.2)
            }
        }
        .alert("로드 실패", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } })) {
            Button("확인") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Header

    private var HeaderGroup: some View {
        ZStack {
            HStack {
                Button {
                    router.pop()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black1)
                        .frame(width: 11, height: 18)
                }
                Spacer()
            }
            HStack {
                Text(activity?.headerTitle ?? "")
                    .foregroundStyle(.black1)
                    .textStyle(.bold20)
            }
        }
        .padding(.vertical)
        .padding(.bottom, 20)
    }

    // MARK: - Body

    private var BodyGroup: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(activity?.title ?? "")
                .textStyle(.semibold22)
                .foregroundStyle(.black1)

            HStack(spacing: 9) {
                Text(activity?.dDayLabel ?? "")
                    .textStyle(.medium14)
                    .foregroundStyle(.fff)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(.primary1)
                    )

                Text(activity?.date ?? "")
                    .textStyle(.semibold18)
                    .foregroundStyle(.primary1)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .aspectRatio(contentMode: .fit)

                Image(.banner1)
                    .resizable()
                    .scaledToFit()
            }
            .overlay(alignment: .topTrailing) {
                Text(activity?.pointBadge ?? "")
                    .textStyle(.semibold16)
                    .foregroundStyle(.fff)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 100)
                            .foregroundStyle(.primary1)
                    )
                    .padding(17)
            }
        }
    }

    // MARK: - Bottom

    private var BottomGroup: some View {
        VStack(alignment: .leading) {
            Text(activity?.title ?? "")
                .textStyle(.semibold18)
                .foregroundStyle(.black1)
                .padding(.top, 26)

            Text(activity?.description ?? "")
                .textStyle(.medium14)
                .foregroundStyle(.black1)
                .padding(.bottom, 26)

            HStack(spacing: 5) {
                Button(action: {
                    Task {
                        await viewModel.addToCart()
                    }
                }, label: {
                    Text("장바구니")
                        .textStyle(.semibold18)
                        .foregroundStyle(.fff)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.primary1)
                        )
                })

                Button {
                    viewModel.openAddActivitySheet()
                } label: {
                    Text("일정 추가")
                        .textStyle(.semibold18)
                        .foregroundStyle(.black1)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.subPurple)
                        )
                }
            }
            .padding(.bottom, 60)
        }
    }
}

#Preview {
    let router = NavigationRouter<ActivityRoute>()

    ActivityDetailView()
        .environment(router)
}
