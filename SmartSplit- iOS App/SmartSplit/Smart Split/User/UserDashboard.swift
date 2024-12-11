//import SwiftUI
//
//struct UserDashboardView: View {
//    @EnvironmentObject var userData: UserData
//    @State private var showLogoutConfirmation = false
//    @State private var showSuccessMessage = true
//
//    var body: some View {
//        NavigationView {
//            TabView {
//                ExpensesView()
//                    .tabItem {
//                        Image(systemName: "creditcard")
//                        Text("Expenses")
//                    }
//                
//                GroupDashboardView()
//                    .tabItem {
//                        Image(systemName: "person.3.fill")
//                        Text("Groups")
//                    }
//
//                AddExpenseView()
//                    .tabItem {
//                        Image(systemName: "plus.circle.fill")
//                        Text("")
//                    }
//
//                AccountView()
//                    .tabItem {
//                        Image(systemName: "person.crop.circle")
//                        Text("Account")
//                    }
//            }
//            .accentColor(.blue)
//            .navigationBarTitle("Welcome \(userData.currentUser?.name ?? "Guest")", displayMode: .inline)
//            .navigationBarItems(trailing: Button(action: {
//                showLogoutConfirmation = true
//            }) {
//                Image(systemName: "power.circle.fill")
//                    .foregroundColor(.red)
//                    .imageScale(.large)
//                    .padding()
//            })
//            .alert("Are you sure you want to log out?", isPresented: $showLogoutConfirmation) {
//                Button("Yes", role: .destructive) { userData.currentUser = nil }
//                Button("No", role: .cancel) {}
//            }
//            .overlay(
//                VStack {
//                    // Add a Spacer to push the message to the top
//                    Spacer().frame(height: 10) // Adjust the height to position the message
//                    if showSuccessMessage {
//                        Text("Logged in Successfully!")
//                            .font(.headline)
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.green.opacity(0.9))
//                            .cornerRadius(10)
//                            .transition(.opacity)
//                            .zIndex(1)
//                    }
//                }
//                .padding(.top, 10) // Add extra padding from the top
//            )
//            .animation(.easeInOut(duration: 1.5), value: showSuccessMessage) // This controls the fade effect
//            .onAppear {
//                // Delay the hiding of the success message after 3 seconds
//                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                    withAnimation {
//                        showSuccessMessage = false
//                    }
//                }
//            }
//        }
//    }
//}


import SwiftUI

struct UserDashboardView: View {
    @EnvironmentObject var userData: UserData
    @State private var showLogoutConfirmation = false
    @State private var showSuccessMessage = true

    var body: some View {
        NavigationView {
            TabView {
                ExpensesView()
                    .tabItem {
                        Image(systemName: "creditcard")
                        Text("Expenses")
                    }
                
                GroupDashboardView()
                    .tabItem {
                        Image(systemName: "person.3.fill")
                        Text("Groups")
                    }

                AddExpenseView()
                    .tabItem {
                        Image(systemName: "plus.circle.fill")
                        Text("")
                    }

                GroupSummaryView()
                    .tabItem {
                        Image(systemName: "chart.bar")
                        Text("Summary")
                    }

                AccountView()
                    .tabItem {
                        Image(systemName: "person.crop.circle")
                        Text("Account")
                    }
            }
            .accentColor(.blue)
            .navigationBarTitle("Welcome \(userData.currentUser?.name ?? "Guest")", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                showLogoutConfirmation = true
            }) {
                Image(systemName: "power.circle.fill")
                    .foregroundColor(.red)
                    .imageScale(.large)
                    .padding()
            })
            .alert("Are you sure you want to log out?", isPresented: $showLogoutConfirmation) {
                Button("Yes", role: .destructive) { userData.currentUser = nil }
                Button("No", role: .cancel) {}
            }
            .overlay(
                VStack {
                    Spacer().frame(height: 10)
                    if showSuccessMessage {
                        Text("Logged in Successfully!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green.opacity(0.9))
                            .cornerRadius(10)
                            .transition(.opacity)
                            .zIndex(1)
                    }
                }
                .padding(.top, 10)
            )
            .animation(.easeInOut(duration: 1.5), value: showSuccessMessage)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showSuccessMessage = false
                    }
                }
            }
        }
    }
}


