import SwiftUI

struct AppView: View {
    @EnvironmentObject var userData: UserData // Access shared user data
    
    @State private var isLoginPresented: Bool = false // State variable for presenting login/register view
    @State private var isUserDashboardPresented: Bool = false // State variable for dashboard presentation
    
    var body: some View {
        VStack {
            if let user = userData.currentUser {
                // If user is logged in, show the dashboard
                UserDashboardView()
//                AccountView()
            } else {
                // If no user is logged in, show the LoginRegisterView
//                LoginRegisterView()
                LandingPage()
            }
        }
        .fullScreenCover(isPresented: $isLoginPresented) {
            // Show UserLoginView if isLoginPresented is true
            UserLoginView(isPresented: .constant(true), isUserDashboardPresented: $isUserDashboardPresented)
        }
    }
}

//struct AppView: View {
//    @EnvironmentObject var userData: UserData
//
//    var body: some View {
//        if userData.currentUser == nil {
//            UserLoginView(isPresented: .constant(true), isUserDashboardPresented: .constant(false))
//        } else {
//            UserDashboardView()
//        }
//    }
//}
