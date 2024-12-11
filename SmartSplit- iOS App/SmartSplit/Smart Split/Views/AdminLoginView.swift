import SwiftUI

struct AdminLoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoginSuccess: Bool = false
    @State private var loginMessage: String = ""
    @State private var navigateToAdminControl: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            // White background
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Logo
                Image("adminLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.top, 40)
                
                // Title and Subtitle
                Text("Admin Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text("Secure access to the admin portal")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
                
                Spacer()
                
                // Form for credentials
                VStack(spacing: 20) {
                    // Username Field
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .autocapitalization(.none)
                        .padding(.horizontal, 40)
                    
                    // Password Field
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .padding(.horizontal, 40)
                }
                
                // Submit Button
                Button(action: submitLogin) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(username.isEmpty || password.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 40)
                        .shadow(color: username.isEmpty || password.isEmpty ? .clear : Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
                }
                .disabled(username.isEmpty || password.isEmpty)
                .padding(.top, 20)
                
                // Login Message
                if !loginMessage.isEmpty {
                    Text(loginMessage)
                        .font(.callout)
                        .foregroundColor(isLoginSuccess ? .green : .red)
                        .padding(.top, 10)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Navigation Link (Hidden)
                NavigationLink(destination: AdminAccessControl(), isActive: $navigateToAdminControl) {
                    EmptyView()
                }
            }
            
            // Loading Overlay
            if isLoading {
                ZStack {
                    Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                    ProgressView("Logging in...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private func submitLogin() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            if username == "Admin" && password == "Admin" {
                isLoginSuccess = true
                loginMessage = ""
                username = ""
                password = ""
                navigateToAdminControl = true
            } else {
                isLoginSuccess = false
                loginMessage = "Incorrect username or password!"
            }
        }
    }
}

struct AdminLoginView_Previews: PreviewProvider {
    static var previews: some View {
        AdminLoginView()
    }
}
