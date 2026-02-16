import SwiftUI

struct CartItemView: View {
    let category: TodoCategory
    let status: ScheduleStatusCategory
    let dDay: Int
    let point: Int
    let title: String
    let description: String
    let tipMessage: String?
    var onAddClick: () -> Void
    
    // 텍스트 로직(0보다 작으면 마감)
    private var dDayText: String {
            if dDay < 0 {
                return "마감"
            } else if dDay == 0 {
                return "D-Day"
            } else {
                return "D-\(dDay)"
            }
        }
    
    // 포인트 텍스트 로직(카테고리에 따라 글자 변경)
        private var pointText: String {
            let categoryName = (category == .growth) ? "성장" : "휴식"
            return "\(categoryName) +\(point)"
        }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(status.statusTitle)
                    .foregroundStyle(Color.white)
                    .textStyle(.semibold14)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(status.themeColor)
                    )
                
                Spacer()
                
                if status != .unavailable {
                    Button(action:{
                        onAddClick()
                    }) {
                        Text("일정 추가")
                            .foregroundStyle(Color.gray888)
                            .textStyle(.semibold14)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 5)
                            .background(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(Color.gray444, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            HStack {
                Text(dDayText)
                    .textStyle(.medium14)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .foregroundStyle(Color.white)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color.primary1)
                    )
                
                Text(pointText)
                    .textStyle(.medium14)
                    .foregroundStyle(Color.primary1)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 5){
                Text(title)
                Text(description)
            }
            .textStyle(.semibold16)
            
            if let message = tipMessage {
                Text(message)
                    .textStyle(.medium14)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(status.themeColor)
                    )
                    .foregroundStyle(Color.gray444)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(status.themeColor, lineWidth: 1)
        )
        .padding()
    }
}
