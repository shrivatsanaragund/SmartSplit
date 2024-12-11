//import SwiftUI
//import Foundation
//import CoreData
//
//struct UserLoginView: View {
//    @EnvironmentObject var userData: UserData
//    @Environment(\.managedObjectContext) private var viewContext
//    
//    @Binding var isPresented: Bool
//    @Binding var isUserDashboardPresented: Bool
//    
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var loginErrorMessage: String = ""
//    @State private var showLoading = false
//    @State private var navigateToUserDashboard = false
//    @State private var showAlert = false // State to control showing the success alert
//
//    var body: some View {
//        ZStack {
//            VStack {
//                Spacer()
//
//                Image("logo1")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 200, height: 200)
//                    .padding(.bottom, 15)
//
//                Text("Welcome Back!")
//                    .font(.title)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.primary)
//                    .padding(.bottom, 5)
//
//                Text("Please log in to continue.")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//
//                Spacer()
//
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("Email Address")
//                        .font(.caption)
//                        .fontWeight(.medium)
//                        .foregroundColor(.secondary)
//                    TextField("Enter your email", text: $email)
//                        .keyboardType(.emailAddress)
//                        .textInputAutocapitalization(.none)
//                        .padding()
//                        .background(Color(UIColor.secondarySystemBackground))
//                        .cornerRadius(10)
//                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
//                }
//                .padding(.horizontal)
//
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("Password")
//                        .font(.caption)
//                        .fontWeight(.medium)
//                        .foregroundColor(.secondary)
//                    SecureField("Enter your password", text: $password)
//                        .padding()
//                        .background(Color(UIColor.secondarySystemBackground))
//                        .cornerRadius(10)
//                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
//                }
//                .padding(.horizontal)
//                .padding(.top, 16)
//
//                Button(action: loginUser) {
//                    Text("Login")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                        .shadow(color: Color.blue.opacity(0.4), radius: 5, x: 0, y: 2)
//                }
//                .padding(.horizontal)
//                .padding(.top, 20)
//
//                if !loginErrorMessage.isEmpty {
//                    Text(loginErrorMessage)
//                        .foregroundColor(.red)
//                        .multilineTextAlignment(.center)
//                        .padding(.top, 10)
//                }
//
//                Spacer()
//
//                Button(action: { isPresented = false }) {
//                    HStack {
//                        Image(systemName: "xmark.circle.fill")
//                            .foregroundColor(.red)
//                        Text("Cancel")
//                            .foregroundColor(.red)
//                    }
//                }
//                .padding(.bottom, 20)
//            }
//            .alert(isPresented: $showAlert) {
//                Alert(title: Text("Login Successful"), message: Text("You are now logged in!"), dismissButton: .default(Text("OK"), action: {
//                    // Navigate to the user dashboard after dismissing the alert
//                    navigateToUserDashboard = true
//                }))
//            }
//
//            // NavigationLink to UserDashboardView
//            NavigationLink(destination: UserDashboardView(), isActive: $navigateToUserDashboard) {
//                EmptyView()
//            }
//        }
//        .navigationBarHidden(true)
//    }
//
//    private func loginUser() {
//        loginErrorMessage = ""
//
//        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "email == %@ AND password == %@", email, password)
//
//        do {
//            let users = try viewContext.fetch(fetchRequest)
//            if users.isEmpty {
//                loginErrorMessage = "Invalid email or password."
//            } else {
//                userData.currentUser = users.first
//                UserDefaults.standard.set(users.first?.email, forKey: "currentUserEmail")
//
//                // Show the success alert
//                showAlert = true
//            }
//        } catch {
//            loginErrorMessage = "An error occurred. Please try again."
//        }
//    }
//}


import SwiftUI
import Foundation
import CoreData

struct UserLoginView: View {
    @EnvironmentObject var userData: UserData
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var isPresented: Bool
    @Binding var isUserDashboardPresented: Bool
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var loginErrorMessage: String = ""
    @State private var showLoading = false
    @State private var navigateToUserDashboard = false
    @State private var showAlert = false // State to control showing the success alert

    var body: some View {
        ZStack {
            VStack {
                Spacer()

                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 15)

                Text("Welcome Back!")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.bottom, 5)

                Text("Please log in to continue.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Email Address")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    TextField("Enter your email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.none)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Password")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    SecureField("Enter your password", text: $password)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal)
                .padding(.top, 16)

                Button(action: loginUser) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: Color.blue.opacity(0.4), radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal)
                .padding(.top, 20)

                if !loginErrorMessage.isEmpty {
                    Text(loginErrorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                }

                Spacer()

                Button(action: { isPresented = false }) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text("Cancel")
                            .foregroundColor(.red)
                    }
                }
                .padding(.bottom, 20)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Login Successful"), message: Text("You are now logged in!"), dismissButton: .default(Text("OK"), action: {
                    // Navigate to the user dashboard after dismissing the alert
                    navigateToUserDashboard = true
                }))
            }

            // NavigationLink to UserDashboardView
            NavigationLink(destination: UserDashboardView(), isActive: $navigateToUserDashboard) {
                EmptyView()
            }

            // Show loading spinner when login is in progress
            if showLoading {
                ProgressView("Logging in...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
                    .padding(40)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .shadow(radius: 20)
            }
        }
        .navigationBarHidden(true)
    }

    private func loginUser() {
        // Reset any previous error message
        loginErrorMessage = ""
        
        // Show loading indicator
        showLoading = true

        // Perform the login operation asynchronously
        Task {
            let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "email == %@ AND password == %@", email, password)

            do {
                let users = try await viewContext.fetch(fetchRequest)
                if users.isEmpty {
                    loginErrorMessage = "Invalid email or password."
                } else {
                    userData.currentUser = users.first
                    UserDefaults.standard.set(users.first?.email, forKey: "currentUserEmail")

                    // Show the success alert
                    showAlert = true
                }
            } catch {
                loginErrorMessage = "An error occurred. Please try again."
            }

            // Add a delay before hiding the loading spinner (e.g., 2 seconds)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                // Hide the loading indicator
                showLoading = false
            }
        }
    }

}
