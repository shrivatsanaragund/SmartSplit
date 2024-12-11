//import SwiftUI
//
//struct AppView: View {
//    @EnvironmentObject var userData: UserData // Access shared user data
//    
//    @State private var isLoginPresented: Bool = false // State variable for presenting login/register view
//    @State private var isUserDashboardPresented: Bool = false // State variable for dashboard presentation
//    
//    var body: some View {
//        VStack {
//            if let user = userData.currentUser {
//                // If user is logged in, show the dashboard
//                UserDashboardView()
////                AccountView()
//            } else {
//                // If no user is logged in, show the LoginRegisterView
////                LoginRegisterView()
//                LandingPage()
//            }
//        }
//        .fullScreenCover(isPresented: $isLoginPresented) {
//            // Show UserLoginView if isLoginPresented is true
//            UserLoginView(isPresented: .constant(true), isUserDashboardPresented: $isUserDashboardPresented)
//        }
//    }
//}



import SwiftUI

struct AppView: View {
    @EnvironmentObject var userData: UserData // Access shared user data
    @State private var showLoginView = false // State for login view
    
    var body: some View {
        VStack {
            if let user = userData.currentUser {
                // If the user is logged in, show the dashboard
                UserDashboardView()
            } else {
                // If no user is logged in, show the LoginRegisterView or LandingPage
                LandingPage()
            }
        }
        .fullScreenCover(isPresented: $showLoginView) {
            UserLoginView(isPresented: .constant(true), isUserDashboardPresented: .constant(false))
        }
        .onChange(of: userData.currentUser) { newValue in
            // Trigger login view when user data changes (i.e., user logs out)
            if newValue == nil {
                showLoginView = true
            }
        }
    }
}
