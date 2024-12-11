import SwiftUI
import CoreData

struct AllUsersView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \User.name, ascending: true)])
    private var users: FetchedResults<User>
    
    @State private var searchText = ""
    @State private var userToDelete: User? // To track the user selected for deletion
    @State private var showDeleteConfirmation = false // To show delete confirmation alert
    
    var body: some View {
        VStack {
            // Title and Search Bar
            VStack {
                Text("All Users")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                Text("Manage all users in the system.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            // Search Bar
            SearchBar(text: $searchText)
                .padding(.top, 20)
            
            // Check if there are any users matching the search text
            if filteredUsers.isEmpty {
                Text("User not found")
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .padding(.top, 20)
            } else {
                // Users List
                List {
                    ForEach(filteredUsers, id: \.self) { user in
                        VStack(alignment: .leading) {
                            Text(user.name ?? "Unknown")
                                .fontWeight(.bold)
                            Text(user.email ?? "No Email")
                                .foregroundColor(.gray)
                        }
                    }
                    .onDelete(perform: deleteUser)
                }
                .listStyle(InsetGroupedListStyle()) // Styled list
            }
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Confirm Deletion"),
                message: Text("Are you sure you want to delete this user?"),
                primaryButton: .destructive(Text("Delete")) {
                    confirmDeleteUser()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // Filtered Users based on the search text
    private var filteredUsers: [User] {
        if searchText.isEmpty {
            return Array(users)
        } else {
            return users.filter {
                ($0.name?.lowercased().contains(searchText.lowercased()) ?? false) ||
                ($0.email?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
    }
    
    // Mark a user for deletion and show confirmation dialog
    private func deleteUser(at offsets: IndexSet) {
        if let index = offsets.first {
            userToDelete = filteredUsers[index]
            showDeleteConfirmation = true
        }
    }
    
    // Confirm deletion of the user
    private func confirmDeleteUser() {
        if let userToDelete = userToDelete {
            viewContext.delete(userToDelete)
            do {
                try viewContext.save()
            } catch {
                print("Failed to delete user: \(error.localizedDescription)")
            }
            self.userToDelete = nil
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        TextField("Search by name or email", text: $text)
            .padding(7)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
    }
}
