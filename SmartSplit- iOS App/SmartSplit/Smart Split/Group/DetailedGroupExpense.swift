//
//  DetailedGroupExpense.swift
//  Smart Split
//
//  Created by Shrivatsa Naragund on 12/10/24.
//


import SwiftUI
import CoreData

struct DetailedGroupExpense: View {
    var expense: GroupExpense
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userData: UserData
    
    @State private var isEditing = false
    @State private var title: String = ""
    @State private var amount: Double = 0.0
    @State private var selectedUsers: Set<String> = []
    @State private var availableUsers: [String] = []
    @State private var category: String = ""
    @State private var availableCategories: [String] = ["Entertainment", "Food and Drink", "Household", "Healthcare", "Transportation", "Utilities", "Other"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Title Section
                HStack {
                    if isEditing {
                        TextField("Title", text: $title)
                            .font(.title)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    } else {
                        Text(expense.title ?? "No Title")
                            .font(.title)
                            .bold()
                    }
                    Spacer()
                }
                .padding(.bottom, 10)

                // Amount Section
                if isEditing {
                    TextField("Amount", value: $amount, formatter: NumberFormatter())
                        .font(.largeTitle)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .keyboardType(.decimalPad)
                } else {
                    Text("$\(expense.amount, specifier: "%.2f")")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.blue)
                }

                Divider()

                // Category Section
                VStack(alignment: .leading) {
                    Text("Category")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    if isEditing {
                        // Editable category picker
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(availableCategories, id: \.self) { categoryName in
                                    Text(categoryName)
                                        .padding()
                                        .background(self.category == categoryName ? Color.blue.opacity(0.8) : Color.gray.opacity(0.2))
                                        .foregroundColor(self.category == categoryName ? .white : .black)
                                        .cornerRadius(10)
                                        .onTapGesture {
                                            self.category = categoryName
                                        }
                                }
                            }
                        }
                        .padding(.vertical)
                    } else {
                        // Static category text
                        Text(category.isEmpty ? "No category selected" : category)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                Divider()

                // Shared By Section
                VStack(alignment: .leading) {
                    Text("Shared By")
                        .font(.headline)
                    
                    if isEditing {
                        // Editable shared by users
                        ForEach(availableUsers, id: \.self) { user in
                            HStack {
                                Text(user)
                                Spacer()
                                
                                // Checkmark icon if the user is selected
                                if selectedUsers.contains(user) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .onTapGesture {
                                // Toggle selection
                                if selectedUsers.contains(user) {
                                    selectedUsers.remove(user)
                                } else {
                                    selectedUsers.insert(user)
                                }
                            }
                        }
                    } else {
                        // Static shared by users text
                        Text(expense.sharedBy ?? "No participants")
                            .font(.subheadline)
                    }
                }

                Divider()

                // Additional Information
                if let date = expense.date {
                    Text("Added by \(expense.paidBy ?? "Unknown") on \(formatDate(date))")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }

                Divider()

                // Owed Messages Section
                if let currentUserName = userData.currentUser?.name {
                    let owedMessages = getOwedMessages(for: expense, currentUserName: currentUserName)
                    ForEach(owedMessages, id: \.self) { message in
                        HStack {
                            Text(message)
                                .font(.subheadline)
                                .foregroundColor(message.contains("owes") ? .green : .red)
                            Spacer()
                        }
                    }
                }

                Spacer()

                // Save Changes Button
                if isEditing {
                    Button(action: saveChanges) {
                        Text("Save Changes")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle("Expense Details", displayMode: .inline)
        .navigationBarItems(
            trailing: Button(action: { toggleEditing() }) {
                Image(systemName: isEditing ? "checkmark" : "pencil.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(.blue)
            }
        )
        .onAppear {
            populateFields()
        }
    }

    private func toggleEditing() {
        isEditing.toggle()
    }

    private func populateFields() {
        title = expense.title ?? ""
        amount = expense.amount
        category = expense.category ?? ""
        selectedUsers = Set(expense.sharedBy?.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } ?? [])
        availableUsers = fetchAvailableUsers()
    }

    private func saveChanges() {
        expense.title = title
        expense.amount = amount
        expense.category = category
        expense.sharedBy = selectedUsers.joined(separator: ", ")

        do {
            try viewContext.save()
            toggleEditing()
        } catch {
            print("Failed to save changes: \(error.localizedDescription)")
        }
    }

    private func fetchAvailableUsers() -> [String] {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let users = try viewContext.fetch(fetchRequest)
            return users.compactMap { $0.name }
        } catch {
            print("Failed to fetch users: \(error.localizedDescription)")
            return []
        }
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter.string(from: date)
    }

    private func getOwedMessages(for expense: GroupExpense, currentUserName: String) -> [String] {
        guard let paidBy = expense.paidBy, let sharedBy = expense.sharedBy else {
            return []
        }

        let participants = sharedBy.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let shareAmount = expense.amount / Double(participants.count + 1)

        var messages = [String]()

        if paidBy == currentUserName {
            for participant in participants where participant != currentUserName {
                let formattedShare = String(format: "%.2f", shareAmount)
                messages.append("\(participant) owes you: $\(formattedShare)")
            }
        } else if participants.contains(currentUserName) {
            let formattedShare = String(format: "%.2f", shareAmount)
            messages.append("You owe \(paidBy): $\(formattedShare)")
        }

        return messages
    }
}
