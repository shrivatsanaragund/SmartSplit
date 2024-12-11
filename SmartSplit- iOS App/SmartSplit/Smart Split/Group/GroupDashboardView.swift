import SwiftUI
import CoreData

struct GroupDashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userData: UserData // Access the userData
    @FetchRequest(
        entity: Group.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Group.createdDate, ascending: true)]
    ) private var groups: FetchedResults<Group>
    
    @State private var isCreateGroupPresented = false // State for presenting CreateGroupView
    @State private var showAlert = false              // State for showing the alert
    @State private var groupToDelete: Group? = nil    // Group to be deleted after confirmation
    
    var body: some View {
        NavigationView {
            VStack {
                // Accessing the logged-in user's name
                let user = userData.currentUser?.name ?? ""
                
                // Filter groups based on the current user's membership (by name)
                let userGroups = groups.filter { group in
                    guard let members = group.members else { return false }
                    let memberList = members.components(separatedBy: ", ").map { $0.trimmingCharacters(in: .whitespaces) }
                    return memberList.contains(user)
                }
                
                if userGroups.isEmpty {
                    Text("No Groups Available")
                        .foregroundColor(.gray)
                        .italic()
                        .padding()
                } else {
                    List {
                        ForEach(userGroups, id: \.self) { group in
                            NavigationLink(destination: DetailedGroupView(group: group)) {
                                HStack {
                                    if let imageData = group.groupImage, let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .clipShape(Circle())
                                            .padding(.trailing, 10)
                                    } else {
                                        Circle()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.gray.opacity(0.5))
                                            .padding(.trailing, 10)
                                    }
                                    VStack(alignment: .leading) {
                                        Text(group.name ?? "Unnamed Group")
                                            .font(.headline)
                                        Text("Members: \(group.members?.components(separatedBy: ", ").count ?? 0)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: confirmDelete) // Trigger the confirmation alert
                    }
                }
                
                Spacer()
            }
            .navigationBarTitle("Groups", displayMode: .inline)
            .navigationBarItems(
                trailing: Button(action: {
                    isCreateGroupPresented = true
                }) {
                    Image(systemName: "plus")
                        .imageScale(.large)
                }
            )
            .fullScreenCover(isPresented: $isCreateGroupPresented) {
                NavigationView {
                    CreateGroupView(isPresented: $isCreateGroupPresented)
                        .navigationBarTitle("Create Group", displayMode: .inline)
                        .navigationBarItems(leading: Button(action: {
                            isCreateGroupPresented = false
                        }) {})
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Delete Group"),
                    message: Text("Are you sure you want to delete this group? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let group = groupToDelete {
                            deleteGroup(group)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    // Function to handle confirmation before deletion
    private func confirmDelete(at offsets: IndexSet) {
        if let index = offsets.first {
            groupToDelete = groups[index] // Set the group to delete
            showAlert = true             // Trigger the alert
        }
    }
    
    // Function to handle the actual delete action
    private func deleteGroup(_ group: Group) {
        viewContext.delete(group)
        do {
            try viewContext.save()
        } catch {
            print("Error deleting group: \(error.localizedDescription)")
        }
    }
}
