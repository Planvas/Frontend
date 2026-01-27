import SwiftUI

enum CardType {
    case growth
    case rest
    
    var title: String { self == .growth ? "성장" : "휴식" }
    var defaultMainColor: Color { self == .growth ? .green2 : .blue1 }
}

struct MiniCard: View {
    let type: CardType
    let iconName: String
    let actual: Int
    let target: Int
    
    // MARK: - 계산 프로퍼티
    private var isAchieved: Bool { actual >= target }
    
    private var mainColor: Color { type.defaultMainColor }
    
    private var progress: CGFloat {
        guard target > 0 else { return 0 }
        return CGFloat((Double(actual) / Double(target)))
    }
    
    var body: some View {
        VStack(spacing: 15) {
            headerView
            
            progressBar
            
            statusInfoView
            
            Text(isAchieved ? "달성" : "미달성")
                .textStyle(.semibold20)
        }
        .padding()
        .frame(width: 175, height: 190)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(mainColor, lineWidth: 1)
        )
    }
}

// MARK: - SubViews
private extension MiniCard {
    var headerView: some View {
        HStack(spacing: 10) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .padding(.vertical, 4)
                .padding(.horizontal, 5)
                .background(
                    Capsule()
                        .fill(type == .growth ? Color.white : Color.black1)
                        .strokeBorder(mainColor)
                )
            
            Text(type.title)
                .textStyle(.bold20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var progressBar: some View {
        Capsule()
            .fill(Color.bar2)
            .overlay(alignment: .leading) {
                GeometryReader { geo in
                    Capsule()
                        .fill(mainColor)
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 10)
    }
    
    var statusInfoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(actual)%/\(target)%")
                .textStyle(.medium16)
                .foregroundStyle(mainColor)
                .padding(.horizontal, 3)
            
            Divider()
                .background(Color.gray444)
        }
    }
}

#Preview {
    HStack {
        MiniCard(type: .growth, iconName: "growth", actual: 70, target: 70)
        MiniCard(type: .rest, iconName: "rest", actual: 30, target: 50)
    }
}
