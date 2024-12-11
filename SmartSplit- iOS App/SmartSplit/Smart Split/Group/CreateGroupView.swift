import SwiftUI
import CoreData

struct CreateGroupView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: User.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \User.name, ascending: true)]
    ) private var users: FetchedResults<User> // Fetch available users from Core Data
    
    @Binding var isPresented: Bool
    
    @State private var name: String = ""
    @State private var groupCode: String = ""
    @State private var selectedCreatedBy: User? // Selected user for createdBy
    @State private var selectedMembers: Set<User> = [] // Selected users for members
    @State private var groupImage: UIImage? // Selected image for the group
    @State private var errorMessage: String = ""
    @State private var successMessage: String = "" // Success message
    
    @State private var showImagePicker: Bool = false // To show ImagePicker
    
    var body: some View {
        NavigationView {
            Form {
                // Group Details Section
                Section(header: Text("Group Details")) {
                    TextField("Group Name", text: $name)
                    TextField("Group Code", text: $groupCode)
                    
                    // Custom Row for Created By
                    VStack(alignment: .leading) {
                        Text("Created By:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        ForEach(users, id: \.self) { user in
                            SingleSelectionRow(user: user, isSelected: selectedCreatedBy == user) {
                                selectedCreatedBy = user
                            }
                        }
                    }
                    
                    // Date Picker (auto-filled, disabled)
                    DatePicker("Created Date", selection: .constant(Date()), displayedComponents: .date)
                        .disabled(true)
                }
                
                // Members Section (Updated for multi-selection)
                Section(header: Text("Members")) {
                    VStack(alignment: .leading) {
                        Text("Select Members:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        // Custom multi-selection Picker
                        ForEach(users, id: \.self) { user in
                            MultipleSelectionRow(user: user, isSelected: selectedMembers.contains(user)) {
                                if selectedMembers.contains(user) {
                                    selectedMembers.remove(user)
                                } else {
                                    selectedMembers.insert(user)
                                }
                            }
                        }
                    }
                }
                
                // Group Image Section
                Section(header: Text("Group Image")) {
                    if let image = groupImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        Text("No Image Selected")
                            .foregroundColor(.gray)
                    }
                    
                    Button("Choose Image") {
                        showImagePicker.toggle() // Show the ImagePicker
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(image: $groupImage) // Pass image binding to ImagePicker
                    }
                }
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Create") {
                    createGroup()
                }
                .disabled(!isFormValid())
            )
            .alert(isPresented: .constant(!errorMessage.isEmpty)) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: .constant(!successMessage.isEmpty)) {
                Alert(title: Text("Success"), message: Text(successMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func createGroup() {
        guard let createdBy = selectedCreatedBy else {
            errorMessage = "Please select a creator."
            return
        }
        
        // Check if the group code already exists
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "groupCode == %@", groupCode)
        
        do {
            let existingGroups = try viewContext.fetch(fetchRequest)
            if !existingGroups.isEmpty {
                // If a group with the same group code exists, show an error
                errorMessage = "A group with this code already exists."
                return
            }
            
            // If the group code is unique, create the new group
            let newGroup = Group(context: viewContext)
            newGroup.name = name
            newGroup.groupCode = groupCode
            newGroup.createdBy = createdBy.name // Save the creator's name
            newGroup.createdDate = Date()
            
            // Save selected members as a list of names (joined by commas)
            newGroup.members = selectedMembers.map { $0.name ?? "" }.joined(separator: ", ")
            
            if let image = groupImage {
                newGroup.groupImage = image.pngData()
            }
            
            try viewContext.save()
            successMessage = "Group created successfully!" // Show success message
            isPresented = false
        } catch {
            errorMessage = "Failed to create group: \(error.localizedDescription)"
        }
    }
    
    private func isFormValid() -> Bool {
        return !name.isEmpty && !groupCode.isEmpty && selectedCreatedBy != nil && !selectedMembers.isEmpty
    }
}

// Custom Row to Handle Single-Selection for Created By
struct SingleSelectionRow: View {
    var user: User
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(user.name ?? "Unknown User")
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Custom Row to Handle Multi-Selection for Members
struct MultipleSelectionRow: View {
    var user: User
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(user.name ?? "Unknown User")
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}


