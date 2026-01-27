import SwiftUI

struct ReportView: View {
    @StateObject private var viewModel = ReportViewModel()
    
    var body: some View {
        ZStack {
            Color.primary1
                .ignoresSafeArea()
            
            VStack {
                HeaderSection(goal: viewModel.reportData?.goal)
                
                if let reportData = viewModel.reportData {
                    MainSection(
                        reportData: reportData,
                        statusImage: viewModel.statusImage,
                        themeColor: viewModel.themeColor,
                        comment: viewModel.comment
                    )
                } else {
                    ProgressView().tint(.white)
                }
            }
        }
        .task {
            viewModel.fetchReport(goalId: 12)
        }
    }
}

// MARK: - Header
private struct HeaderSection: View {
    let goal: goalResponse?
    
    var body: some View {
        VStack(spacing: 5) {
            if let goal = goal {
                Text("겨울방학 기간 종료")
                    .textStyle(.semibold25)
                    .foregroundStyle(Color.white)
                
                Text("\(goal.startDate)~\(goal.endDate)")
                    .textStyle(.medium16)
                    .foregroundStyle(Color.fff.opacity(0.5))
            }
        }
        .padding(.top, 24)
        .padding(.bottom, 32)
    }
}

// MARK: - Main Section
private struct MainSection: View {
    let reportData: ReportSuccessResponse
    let statusImage: (name: String, width: CGFloat, height: CGFloat)
    let themeColor: Color
    let comment: String
    
    var body: some View {
        ScrollView {
            VStack {
                VStack(spacing: 15) {
                    Text(reportData.summary.title)
                        .textStyle(.semibold22)
                    Text(reportData.summary.description)
                        .textStyle(.medium18)
                        .foregroundStyle(Color.primary1)
                }
                .padding(.vertical, 50)
                
                HStack {
                    MiniCard(
                        type: "growth",
                        iconName: "growth",
                        actual: reportData.ratio.actual.growthRatio,
                        target: reportData.ratio.target.growthRatio)
                    MiniCard(
                        type: "rest",
                        iconName: "rest",
                        actual: reportData.ratio.actual.restRatio,
                        target: reportData.ratio.actual.restRatio)
                }
                
                ImageSection(data: statusImage)
                
                ButtonSection(comment: comment)
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
        )
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Image Section
private struct ImageSection: View {
    let data: (name: String, width: CGFloat, height: CGFloat)
    
    var body: some View {
        VStack {
            ZStack {
                if data.name == "success" {
                    Image("success_back")
                        .resizable()
                        .scaledToFit()
                }
                Image(data.name)
                    .resizable()
                    .frame(width: data.width, height: data.height)
            }
            .offset(y:80)
        }
        .frame(height: 300)
        .background(
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.primary1.opacity(0.9),
                            Color.primary1.opacity(0),
                            Color.primary1.opacity(0),
                            Color.primary1.opacity(0),
                        ]),
                        startPoint: .bottom,
                        endPoint: .top)
                )
                .frame(width: 700, height: 700)
                .offset(y: -250)
        )
        .frame(maxWidth: .infinity)
    }
}
    
// MARK: - Button Section
private struct ButtonSection: View {
    let comment: String
    
    var body: some View {
        VStack {
            Text(comment)
                .textStyle(.semibold18)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action:{}) {
                Text("새로운 활동 탐색하기")
                    .textStyle(.semibold20)
                    .foregroundStyle(Color.blue1)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .background(
                RoundedRectangle(cornerRadius: 27)
                    .fill(.clear)
                    .stroke(Color.blue1 ,lineWidth: 1.5)
            )
            .buttonStyle(.glass)
            
            PlanvasButton(
                title: "다음 목표 기간 설정하러 가기",
                isDisabled: false,
                action: {}
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 14)
        .padding(.bottom, 30)
    }
}

#Preview {
    ReportView()
}
