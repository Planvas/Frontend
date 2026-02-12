import SwiftUI

struct CartListView: View {
    var viewModel: CartViewModel
    let selectedTab: TodoCategory
    
    var body: some View {
        if viewModel.isLoading {
            ProgressView()
        } else {
            List {
                // 전체 아이템 중 현재 탭과 카테고리가 일치하는 것만 필터링!
                if let allItems = viewModel.cartSuccessData?.items {
                    let filteredItems = allItems.filter { $0.category == selectedTab}
                            
                if filteredItems.isEmpty {
                    emptyView
                } else {
                    ForEach(filteredItems, id: \.cartItemId) { item in
                        CartItemView(
                            // 상태 판별 로직 (D-Day나 메세지 유무로 임시 설정)
                            status: item.subMessage == nil ? .available : (item.dDay < 10 ? .warning : .conflict),
                            dDay: item.dDay,
                            point: item.point,
                            title: item.title,
                            subTitle: item.subTitle,
                            subMessage: item.subMessage
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    // TODO: 삭제 API 호출 연동
                                } label: {
                                    Label("삭제", systemImage: "trash")
                                }
                                .tint(.primary1)
                            }
                        }
                    }
                } else {
                    emptyView
                }
            }
            .listStyle(.plain)
        }
    }
    
    private var emptyView: some View {
            VStack {
                Spacer()
                Text("\(selectedTab == .growth ? "성장" : "휴식") 활동이 비어있어요.")
                    .foregroundStyle(Color.gray888)
                    .textStyle(.medium14)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
        }
}

