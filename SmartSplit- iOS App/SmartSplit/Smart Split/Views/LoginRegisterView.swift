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
            VStack {
                // Logo and Title
                VStack {
                    Image("logo") // Assuming logo.jpeg is in your asset catalog
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding(.top, 10)
                    
                    Text("SmartSplit")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.top, 10)

                    Text("Split Smarter, Settle Faster!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
//                        .padding(.top, 5)
                }
                .frame(maxWidth: .infinity, alignment: .center)

                Spacer()

                // Centered Form for creating account
                Form {
                    // Name Input
                    Section(header: Text("Name").foregroundColor(.blue)) {
                        TextField("Enter your name", text: $name)
                            .textInputAutocapitalization(.words)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }

                    // Email Input
                    Section(header: Text("Email").foregroundColor(.blue)) {
                        TextField("Enter your email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.none)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }

                    // Password Input
                    Section(header: Text("Password").foregroundColor(.blue)) {
                        SecureField("Enter your password", text: $password)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }

                    // Age Input
                    Section(header: Text("Age").foregroundColor(.blue)) {
                        TextField("Enter your age", value: $age, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }

                    // Profile Image Input
                    Section(header: Text("Profile Image").foregroundColor(.blue)) {
                        HStack {
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            } else {
                                Text("No Image Selected")
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button("Choose Image") {
                                isImagePickerPresented = true
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }

                // Create Account Button
                Button(action: {
                    createAccount()
                }) {
                    Text("Create Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(name.isEmpty || email.isEmpty || age <= 0 || profileImage == nil ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
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
                            .foregroundColor(.blue)
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
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
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
