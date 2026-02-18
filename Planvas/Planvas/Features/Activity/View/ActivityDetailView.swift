import SwiftUI
import Kingfisher

struct ActivityDetailView: View {
    @State private var viewModel: ActivityDetailViewModel
    //    @Environment(NavigationRouter<ActivityRoute>.self) var router
    @Environment(\.dismiss) private var dismiss
    
    let activityId: Int
    
    /// 옵셔널 바인딩 편의용
    private var activity: ActivityDetail? {
        viewModel.activity
    }
    
    init(activityId: Int) {
        self.activityId = activityId
        _viewModel = State(
            initialValue: ActivityDetailViewModel()
        )
    }
    
    var body: some View {
        VStack {
            HeaderGroup
            Spacer()
            ScrollView {
                BodyGroup
                BottomGroup
                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .task {
            viewModel.fetchActivityDetail(activityId: activityId)
            viewModel.activityId = activityId
            await viewModel.loadDetailIfNeeded()
        }
        .sheet(isPresented: $viewModel.showAddActivity) {
            if let addVM = viewModel.addActivityViewModel {
                AddActivityView(
                    viewModel: addVM,
                    onSubmit: {
                        Task { await viewModel.submitAddToMyActivities() }
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
        .onChange(of: viewModel.showAddActivity) { _, isShowing in
            if !isShowing {
                viewModel.clearAddActivitySheet()
            }
        }
        .alert(
            "추가 완료",
            isPresented: Binding(
                get: { viewModel.addSuccessMessage != nil },
                set: { if !$0 { viewModel.addSuccessMessage = nil } }
            )
        ) {
            Button("확인") { viewModel.addSuccessMessage = nil }
        } message: {
            Text(viewModel.addSuccessMessage ?? "")
        }
        .alert(
            "추가 실패",
            isPresented: Binding(
                get: { viewModel.addErrorMessage != nil },
                set: { if !$0 { viewModel.addErrorMessage = nil } }
            )
        ) {
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
        .alert(
            "로드 실패",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
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
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black1)
                        .frame(width: 11, height: 18)
                }
                Spacer()
            }
            
            HStack {
                Text(activity?.category == .growth ? "성장 활동" : "휴식 활동")
                    .foregroundStyle(.black1)
                    .textStyle(.bold20)
            }
        }
        .padding()
    }
    
    // MARK: - Body
    
    private var BodyGroup: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(viewModel.title)
                .textStyle(.semibold22)
                .foregroundStyle(.black1)
            
            HStack(spacing: 9) {
                Text(viewModel.dDayText)
                    .textStyle(.medium14)
                    .foregroundStyle(.fff)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(.primary1)
                    )
                
                Text(viewModel.date)
                    .textStyle(.semibold18)
                    .foregroundStyle(.primary1)
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .aspectRatio(contentMode: .fit)
                
                if let url = viewModel.thumbnailURL {
                    KFImage(url)
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 15))
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
            Text(viewModel.title)
                .textStyle(.semibold18)
                .foregroundStyle(.black1)
                .padding(.top, 26)
            
            Text(viewModel.description)
                .textStyle(.medium14)
                .foregroundStyle(.gray444)
                .padding(.vertical, 12)
                .padding(.horizontal, 13.5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.ccc, lineWidth: 1)
                )
                .padding(.bottom, 26)
            
            HStack(spacing: 5) {
                Button {
                  Task {
                        await viewModel.addToCart()
                    }
                } label: {
                    Text("장바구니")
                        .textStyle(.semibold18)
                        .foregroundStyle(.fff)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.primary1)
                        )
                }
                
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
        }
    }
}
