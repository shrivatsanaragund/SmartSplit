import SwiftUI

struct UserDashboardView: View {
    @EnvironmentObject var userData: UserData
    @State private var showLogoutConfirmation = false
    @State private var showSuccessMessage = true
    @State private var showLoginView = false // New state for showing the login view
    
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
                Button("Yes", role: .destructive) {
                    // Clear the current user data and navigate to login view
                    userData.currentUser = nil
                }
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
        .onChange(of: userData.currentUser) { newValue in
            // If the user logs out, trigger the login view
            if newValue == nil {
                showLoginView = true
            }
        }
        .fullScreenCover(isPresented: $showLoginView) {
            UserLoginView(isPresented: .constant(true), isUserDashboardPresented: .constant(false))
        }
    }
}
