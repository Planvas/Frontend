import SwiftUI

struct CartView: View {
    @State private var selectedBar: TodoCategory = .growth
    @State private var viewModel = CartViewModel()
    
    var body: some View {
        VStack {
            HStack {
                tabButton(title: "성장 활동", category: .growth)
                tabButton(title: "휴식 활동", category: .rest)
            }
            .padding()
            
            CartListView(viewModel: viewModel, selectedTab: selectedBar)
        }
        .task {
            viewModel.fetchCartList(for: selectedBar)
        }
        .onChange(of: selectedBar) { _, newValue in
            viewModel.fetchCartList(for: newValue)
        }
        .sheet(isPresented: $viewModel.showAddActivity) {
            if let addVM = viewModel.addActivityViewModel {
                AddActivityView(viewModel: addVM, onSubmit: {
                    viewModel.submitActivity()
                })
            }
        }
        .alert("알림", isPresented: Binding(
            get: { viewModel.successMessage != nil },
            set: { if !$0 { viewModel.successMessage = nil } }
        )) {
            Button("확인") { viewModel.successMessage = nil }
        } message: {
            Text(viewModel.successMessage ?? "")
        }
        .alert("오류", isPresented: Binding(
            get: { viewModel.alertErrorMessage != nil },
            set: { if !$0 { viewModel.alertErrorMessage = nil } }
        )) {
            Button("확인") { viewModel.alertErrorMessage = nil }
        } message: {
            Text(viewModel.alertErrorMessage ?? "")
        }
        .navigationTitle("장바구니")
    }
    
    // 탭 버튼 컴포넌트
    @ViewBuilder
    func tabButton(title: String, category: TodoCategory) -> some View {
        Button(action: { selectedBar = category }) {
            VStack(spacing: 12) {
                Text(title)
                    .textStyle(.semibold16)
                    .foregroundStyle(selectedBar == category ? Color.primary1 : Color.gray444)
                Rectangle()
                    .fill(selectedBar == category ? Color.primary1 : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}


#Preview {
    CartView()
}
