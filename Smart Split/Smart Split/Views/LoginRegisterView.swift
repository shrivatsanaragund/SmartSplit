import SwiftUI
import CoreData

struct LoginRegisterView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // State variables to store user inputs
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var age: Int16 = 0
    @State private var profileImage: UIImage? = nil
    @State private var isImagePickerPresented = false

    // State for showing validation errors
    @State private var validationErrorMessage: String = ""
    @State private var showSuccessAlert: Bool = false
    @State private var isAccountCreated: Bool = false

    // State to manage AdminLogin navigation
    @State private var isAdminLoginPresented = false

    // State to manage UserLogin navigation
    @State private var isLoginPresented: Bool = false
    @State private var isUserDashboardPresented: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                // Gradient Background from the LandingPage theme
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.teal]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Logo and Title
                    VStack {
                        Image("logo") // Assuming logo.jpeg is in your asset catalog
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .cornerRadius(15)
                            .shadow(color: .black, radius: 10, x: 5, y: 5)
                            .padding(.top, 10)
                        
                        Text("Create Account")
                            .font(.custom("Georgia", size: 36, relativeTo: .title)) // Custom font for a cool look
                            .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing)) // Gradient color
                            .padding(.top, 10)
//
//                        Text("Split Smarter, Settle Faster!")
//                            .font(.subheadline)
//                            .foregroundColor(.white)
//                            .padding(.top, 5)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                    Spacer()

                    // Form for account creation
                    Form {
                        Section(header: Text("Name").foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing))) {
                            TextField("Enter your name", text: $name)
                                .textInputAutocapitalization(.words)
                                .padding(.vertical, 12)
//                                .background(Color.white.opacity(0.7))
                                .cornerRadius(8)
                                .shadow(radius: 5)
                        }

                        Section(header: Text("Email").foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing))) {
                            TextField("Enter your email", text: $email)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.none)
                                .padding(.vertical, 12)
//                                .background(Color.white.opacity(0.7))
                                .cornerRadius(8)
                                .shadow(radius: 5)
                        }

                        Section(header: Text("Password").foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing))) {
                            SecureField("Enter your password", text: $password)
                                .padding(.vertical, 12)
//                                .background(Color.white.opacity(0.7))
                                .cornerRadius(8)
                                .shadow(radius: 5)
                        }

                        Section(header: Text("Age").foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing))) {
                            TextField("Enter your age", value: $age, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .padding(.vertical, 12)
//                                .background(Color.white.opacity(0.7))
                                .cornerRadius(8)
                                .shadow(radius: 5)
                        }

                        Section(header: Text("Profile Image").foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing))) {
                            HStack {
                                if let image = profileImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                        .shadow(radius: 5)
                                } else {
                                    Text("No Image Selected")
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Button("Choose Image") {
                                    isImagePickerPresented = true
                                }
                                .foregroundColor(.blue)
                                .padding(8)
//                                .background(Color.white.opacity(0.8))
                                .cornerRadius(8)
                                .shadow(radius: 5)
                            }
                        }
                    }

                    // Create Account Button
//                    Button(action: {
//                        createAccount()
//                    }) {
//                        Text("Create Account")
//                            .font(.headline)
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(name.isEmpty || email.isEmpty || age <= 0 || profileImage == nil ? Color.gray : Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(8)
//                            .shadow(radius: 5)
//                    }
//                    .disabled(name.isEmpty || email.isEmpty || age <= 0 || profileImage == nil)
//                    .padding(.horizontal)
//                    .padding(.top, 20)
                    Button(action: {
                        createAccount()
                    }) {
                        Text("Create Account")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                name.isEmpty || email.isEmpty || age <= 0 || profileImage == nil
                                    ? AnyView(Color.gray)
                                    : AnyView(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            )
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                    }
                    .disabled(name.isEmpty || email.isEmpty || age <= 0 || profileImage == nil)
                    .padding(.horizontal)
                    .padding(.top, 20)


                    // Validation Error Message
                    if !validationErrorMessage.isEmpty {
                        Text(validationErrorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }

                    Spacer()

                    // Login and Admin Login Buttons
                    HStack {
                        // Login Button
                        Button(action: {
                            isLoginPresented = true
                        }) {
                            Text("Login")
                                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .padding()
                        }
                        .fullScreenCover(isPresented: $isLoginPresented) {
                            UserLoginView(isPresented: $isLoginPresented, isUserDashboardPresented: $isUserDashboardPresented)
                        }

                        Spacer()

                        // Admin Login Navigation
                        NavigationLink(
                            destination: AdminLoginView(),
                            isActive: $isAdminLoginPresented
                        ) {
                            Text("Admin Login")
                                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .background(Color.white.opacity(0.95)) // Semi-transparent background for the form
                .cornerRadius(20)
                .padding()
                .shadow(radius: 10)
            }
            .sheet(isPresented: $isImagePickerPresented) {
                // Image Picker view
                ImagePicker(image: $profileImage)
            }
            .alert(isPresented: $showSuccessAlert) {
                Alert(
                    title: Text(isAccountCreated ? "Account Created Successfully" : "Error"),
                    message: Text(validationErrorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            // Full-screen cover for the dashboard
            .fullScreenCover(isPresented: $isUserDashboardPresented) {
                UserDashboardView()
            }
        }
        .background(Color.white)
    }

    private func createAccount() {
        // Reset state before validation
        validationErrorMessage = ""
        showSuccessAlert = false

        // Validate input fields
        if name.isEmpty {
            validationErrorMessage = "Please enter your name."
        } else if email.isEmpty {
            validationErrorMessage = "Please enter your email address."
        } else if password.isEmpty {
            validationErrorMessage = "Please enter a password."
        } else if password.count < 8 {
            validationErrorMessage = "Password must be at least 6 characters long."
        } else if age <= 0 {
            validationErrorMessage = "Please enter a valid age."
        }
        else if age > 100 {
            validationErrorMessage = "Please enter a valid age."
        }else if profileImage == nil {
            validationErrorMessage = "Please select a profile image."
        } else if !checkIfValidEmail(email) {
            validationErrorMessage = "Please enter a valid email address."
        }

        // If validation fails, show an alert
        if !validationErrorMessage.isEmpty {
            showSuccessAlert = true
            return
        }

        // Save user to Core Data if validation passes
        do {
            let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "email == %@", email)

            let existingUsers = try viewContext.fetch(fetchRequest)

            if !existingUsers.isEmpty {
                validationErrorMessage = "The email address is already in use."
                showSuccessAlert = true
                return
            }

            let newUser = User(context: viewContext)
            newUser.name = name
            newUser.email = email
            newUser.password = password
            newUser.age = age
            if let image = profileImage {
                newUser.profileImage = image.pngData()
            }

            try viewContext.save()

            // Clear fields and display success message
            name = ""
            email = ""
            password = ""
            age = 0
            profileImage = nil
            isAccountCreated = true
            showSuccessAlert = true
        } catch {
            validationErrorMessage = "Failed to save the account. Please try again."
            showSuccessAlert = true
        }
    }

    private func checkIfValidEmail(_ email: String) -> Bool {
        let emailPattern = #"^\S+@\S+\.\S+$"#
        return email.range(of: emailPattern, options: .regularExpression) != nil
    }
}

//struct LoginRegisterView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginRegisterView()
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
