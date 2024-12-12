import SwiftUI
import CoreData

struct AccountView: View {
    @EnvironmentObject var userData: UserData // Access shared user data object
    @Environment(\.managedObjectContext) private var viewContext // Core Data context

    // State variables for editable fields
    @State private var newName: String = ""
    @State private var newEmail: String = ""
    @State private var newAge: String = ""
    @State private var newProfileImage: UIImage? // Store the new profile image
    @State private var isProfileImagePickerPresented = false // For showing image picker
    @State private var alertMessage: AlertMessage? // For displaying alerts
    @State private var errorMessages: [String] = [] // Array to store error messages

    var body: some View {
        ScrollView {
            VStack {
                if let user = userData.currentUser {
                    // Profile Image (Square)
                    if let userImage = user.profileImage, let uiImage = UIImage(data: userImage) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            .shadow(radius: 5)
                            .padding(.top)
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            .shadow(radius: 5)
                            .padding(.top)
                    }

                    // Editable fields for name, email, and age
                    VStack(spacing: 15) {
                        TextField("Update Name", text: $newName)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                            .textInputAutocapitalization(.words)
                            .disableAutocorrection(true)
                            .padding(.horizontal)

                        TextField("Update Email", text: $newEmail)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                            .keyboardType(.emailAddress)
                            .disableAutocorrection(true)
                            .padding(.horizontal)

                        TextField("Update Age", text: $newAge)
                            .keyboardType(.numberPad)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                            .padding(.horizontal)
                    }

                    // Profile Image Update Button
                    Button(action: {
                        isProfileImagePickerPresented = true
                    }) {
                        Text("Change Profile Picture")
                            .fontWeight(.medium)
//                            .foregroundColor(.blue)
                            .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                    .padding(.top, 10)

                    // Save Changes Button
                    Button(action: {
                        validateAndSaveUserProfile()
                    }) {
//                        Text("Save Changes")
//                            .fontWeight(.semibold)
//                            .frame(maxWidth: 150)
//                            .padding()
//                            .background(areFieldsNonEmpty() ? Color.blue : Color.gray)
//                            .foregroundColor(.white)
//                            .cornerRadius(8)
//                            .padding(.top)
                        Text("Save Changes")
                            .fontWeight(.semibold)
                            .frame(maxWidth: 150)
                            .padding()
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .foregroundColor(.white) // For the text color
                            .cornerRadius(8)
                            .padding(.top)
                            .disabled(!areFieldsNonEmpty()) // Disable the button if fields are empty

                    }
                    .disabled(!areFieldsNonEmpty()) // Disable the button if any field is empty
                    .opacity(areFieldsNonEmpty() ? 1.0 : 0.6) // Make button dull when disabled

                    // Display error messages if any
                    if !errorMessages.isEmpty {
                        VStack(alignment: .leading) {
                            ForEach(errorMessages, id: \.self) { message in
                                Text(message)
                                    .foregroundColor(.red)
                                    .font(.footnote)
                            }
                        }
                        .padding(.top)
                        .padding(.horizontal)
                    }

                    Spacer()
                } else {
                    Text("No user found.")
                        .font(.title)
                        .padding(.top)
                }
            }
            .onAppear {
                loadUserProfile()
            }
            .sheet(isPresented: $isProfileImagePickerPresented) {
                ImagePicker(image: $newProfileImage)
            }
            .alert(item: $alertMessage) { alertMessage in
                Alert(title: Text(alertMessage.title), message: Text(alertMessage.message), dismissButton: .default(Text("OK")))
            }
            .padding(.bottom)
            .navigationBarTitle("Account Details", displayMode: .inline)
        }
    }

    private func loadUserProfile() {
        // Pre-fill the form fields with current user data
        if let user = userData.currentUser {
            newName = user.name ?? ""
            newEmail = user.email ?? ""
            newAge = String(user.age)
        }
    }

    private func areFieldsNonEmpty() -> Bool {
        // Check if all fields have non-empty values
        return !newName.isEmpty && !newEmail.isEmpty && !newAge.isEmpty
    }

    private func validateAndSaveUserProfile() {
        guard let user = userData.currentUser else { return }

        errorMessages.removeAll() // Clear any previous error messages

        // Validate name
        if newName.isEmpty {
            errorMessages.append("Name cannot be empty.")
        }

        // Validate email format
        if newEmail.isEmpty {
            errorMessages.append("Email cannot be empty.")
        } else if !isValidEmail(newEmail) {
            errorMessages.append("Please enter a valid email address.")
        }

        // Validate age
        if newAge.isEmpty {
            errorMessages.append("Age cannot be empty.")
        } else if let age = Int(newAge), age < 18 || age > 100 {
            errorMessages.append("Age must be between 18 and 100.")
        } else if Int(newAge) == nil {
            errorMessages.append("Please enter a valid age.")
        }

        // If there are any errors, stop further processing
        if !errorMessages.isEmpty {
            return
        }

        // Check for duplicate email
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@ AND SELF != %@", newEmail, user)

        do {
            let results = try viewContext.fetch(fetchRequest)

            if !results.isEmpty {
                // Email already exists
                alertMessage = AlertMessage(title: "Error", message: "The email ID already exists. Please use a different email.")
                return
            }

            // No duplicates found, proceed with saving
            user.name = newName
            user.email = newEmail
            user.age = Int16(newAge) ?? 0

            if let newProfileImage = newProfileImage,
               let imageData = newProfileImage.jpegData(compressionQuality: 0.8) {
                user.profileImage = imageData
            }

            try viewContext.save()
            userData.currentUser = user
            alertMessage = AlertMessage(title: "Success", message: "Profile updated successfully!")

        } catch {
            print("Failed to validate or save user profile: \(error.localizedDescription)")
            alertMessage = AlertMessage(title: "Error", message: "An error occurred while updating your profile.")
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
}

// Helper struct for alert messages
struct AlertMessage: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
