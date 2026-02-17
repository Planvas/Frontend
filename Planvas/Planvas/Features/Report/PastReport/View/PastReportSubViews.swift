import SwiftUI

// MARK: - 현재연도에 완료된 목표가 없을 때 비어있는 뷰
struct EmptyReportView: View {
    var body: some View {
        VStack {
            Text("아직 완료된 기간이 없습니다")
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .foregroundStyle(Color.primary1)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.primary1 ,lineWidth: 1)
                )
                .padding(.horizontal, 10)
        }
    }
}

// MARK: - 연도별 완료된 목표 뷰
struct ReportSectionView: View {
    let reports: [PastReportSuccessResponse]
    let onTap: (Int) -> Void
    
    // MARK: - 데이터 형식 바꾸기
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM/dd"
        return f
    }()
    
    var body: some View {
        ForEach(reports) { report in
            let des = {
                if let s = report.startDateObject, let e = report.endDateObject {
                    return "\(dateFormatter.string(from: s)) ~ \(dateFormatter.string(from: e))"
                } else {
                    return "날짜 정보 없음"}
            }()
            MenuButton(
                title: report.title,
                desc: des,
            ) {
                onTap(report.id)
            }
        }
    }
}
