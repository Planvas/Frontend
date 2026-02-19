import SwiftUI

// MARK: - Header
struct HeaderSection: View {
    let title: String
    let dateRange: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .textStyle(.semibold25)
                .foregroundStyle(Color.white)
            
            Text(dateRange)
                .textStyle(.medium16)
                .foregroundStyle(Color.fff.opacity(0.5))
        }
        .padding(.top, 24)
        .padding(.bottom, 32)
    }
}

// MARK: - Main Section
struct MainSection: View {
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
                        .multilineTextAlignment(.center)
                    Text(reportData.summary.subTitle)
                        .textStyle(.medium18)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.primary1)
                        .padding(.horizontal, 20)
                }
                .padding(.vertical, 50)
                
                HStack(alignment: .top) {
                    MiniCard(
                        type: .growth,
                        iconName: "growth",
                        actual: reportData.ratio.actual.growthRatio,
                        target: reportData.ratio.target.growthRatio)
                    
                    MiniCard(
                        type: .rest,
                        iconName: "rest",
                        actual: reportData.ratio.actual.restRatio,
                        target: reportData.ratio.target.restRatio)
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
struct ImageSection: View {
    let data: (name: String, width: CGFloat, height: CGFloat)
    
    var body: some View {
        VStack {
            ZStack {
                if data.name == "success" {
                    Image("success_back")
                        .resizable()
                        .scaledToFit()
                        .offset(y: -20)
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
struct ButtonSection: View {
    let comment: String
    @Environment(NavigationRouter<MyPageRoute>.self) private var myPageRouter: NavigationRouter<MyPageRoute>?
     @Environment(NavigationRouter<MainRoute>.self) private var mainRouter: NavigationRouter<MainRoute>?
    
    var body: some View {
        VStack {
            Text(comment)
                .textStyle(.semibold18)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action:{
<<<<<<< HEAD
                if let myPageRouter {
                    myPageRouter.push(.activityPage)
                } else if let mainRouter {
                    mainRouter.push(.activityPage) 
                }
=======
                UserDefaults.standard.set(2, forKey: "selectedTab")
                myPageRouter.reset()
>>>>>>> 3da7f75d6a6603bf14904d77b40ca39534b42b1f
            }) {
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
                action: {
                    if let myPageRouter {
                        myPageRouter.push(.goalInfoSetup)
                    } else if let mainRouter {
                        mainRouter.push(.onboarding)
                    }
                }
            )
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 14)
        .padding(.bottom, 70)
    }
}
