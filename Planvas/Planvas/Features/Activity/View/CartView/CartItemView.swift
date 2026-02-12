import SwiftUI

struct CartItemView: View {
    let status: ScheduleStatus
    let dDay: Int
    let point: Int
    let title: String
    let subTitle: String
    let subMessage: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(status.status)
                    .foregroundStyle(Color.white)
                    .textStyle(.semibold14)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(status.themeColor)
                    )
                
                Spacer()
                
                Button(action:{}) {
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
            }
            
            HStack {
                Text("D-\(dDay)")
                    .textStyle(.medium14)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 8)
                    .foregroundStyle(Color.white)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color.primary1)
                    )
                
                Text("성장 +\(point)")
                    .textStyle(.medium14)
                    .foregroundStyle(Color.primary1)
                
                Spacer()
            }
            
            VStack(alignment: .leading){
                Text(title)
                Text(subTitle)
            }
            .textStyle(.semibold16)
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(status.themeColor, lineWidth: 1)
        )
        .padding()
    }
}
