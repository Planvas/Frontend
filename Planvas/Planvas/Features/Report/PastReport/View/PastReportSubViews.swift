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
    let reports: [PastReportSuccessResponse.Seasons]
    let onTap: (Int) -> Void
    
    var body: some View {
        ForEach(reports, id: \.goalId) { report in
            let des = {
                if let s = report.startDateTuple, let e = report.endDateTuple {
                    return "\(s.month)/\(s.day) ~ \(e.month)/\(e.day)"
                } else {
                    return "날짜 정보 없음"}
            }()
            MenuButton(
                title: report.title,
                desc: des,
            ) {
                onTap(report.goalId)
            }
        }
    }
}
