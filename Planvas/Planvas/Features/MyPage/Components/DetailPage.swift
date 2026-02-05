import SwiftUI

// MARK: - 결과 버튼 클릭시 상세 페이지 이동을 위한 컴포넌트들
// MARK: - 공용 섹션 틀
struct MenuSection<Content: View>: View {
    let title: String
    let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .textStyle(.semibold16)
                .foregroundStyle(Color.gray444)
                .padding(.leading)
            
            VStack(spacing: 16) {
                content
            }
        }
    }
}

// MARK: - 공용 버튼 틀
struct MenuButton: View {
    let title: String
    let desc: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            DetailPage(title: title, description: desc)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 상세 페이지 컴포넌트
struct DetailPage: View {
    let title: String
    let description: String?
    
    var body: some View {
        HStack {
            if let description {
                VStack(alignment: .leading) {
                    Text(title)
                        .textStyle(.semibold18)
                        .foregroundStyle(Color.black)
                    Text(description)
                        .textStyle(.medium14)
                        .foregroundStyle(Color.gray444)
                }
            } else {
                VStack(alignment: .leading) {
                    Text(title)
                        .textStyle(.semibold18)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
        }
        .padding(24)
        .frame(maxHeight: 80)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .gray888.opacity(0.25), radius: 10, x: 2, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray888, lineWidth: 0.3)
        )
        .frame(width: 350)
    }
}
