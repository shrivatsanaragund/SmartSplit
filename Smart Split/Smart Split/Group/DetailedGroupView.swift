//
//  DetailedGroupView.swift
//  Smart Split
//
//  Created by Shrivatsa Naragund on 12/9/24.


import SwiftUI

struct DetailedGroupView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \GroupExpense.date, ascending: false)])
    private var groupExpenses: FetchedResults<GroupExpense>

    var group: Group
    
    @EnvironmentObject var userData: UserData

    @State private var totalAmount: Double = 0.0
    @State private var totalOwedByUser: Double = 0.0
    @State private var totalAmountOwed: Double = 0.0

    var body: some View {
        VStack {
            
            HStack {
                           // Group Image
                           if let groupImage = group.groupImage { // Assuming `Group` has an optional `image` property
                               Image(uiImage: UIImage(data: groupImage) ?? UIImage())
                                   .resizable()
                                   .scaledToFill()
                                   .frame(width: 85, height: 85)
                                   .cornerRadius(30) // Circular image
                                   .padding(.trailing, 10)
                           }
                           
                           // Group Name
                           Text(group.name ?? "Group Name")
                               .font(.title)
                               .fontWeight(.bold)
//                               .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing))
                           
                           Spacer()
                       }
                       .padding([.top, .horizontal])
            
            // Summary Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Group Summary")
                    .font(.title)
                    .bold()
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing))

                HStack {
                    Text("Total Group Expenses:")
                    Spacer()
                    Text("$\(totalAmount, specifier: "%.2f")")
                        .foregroundColor(.blue)
                        .bold()
                }

                HStack {
                    Text("You owe:")
                    Spacer()
                    Text("$\(totalOwedByUser, specifier: "%.2f")")
                        .foregroundColor(.red)
                        .bold()
                }

                HStack {
                    Text("You are owed:")
                    Spacer()
                    Text("$\(totalAmountOwed, specifier: "%.2f")")
                        .foregroundColor(.green)
                        .bold()
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding([.top, .horizontal])

            // Side-by-side buttons
            HStack {
                // Settle Up Button (Left Aligned)
                Button(action: {
                    print("Settle up button pressed")
                }) {
                    Text("Settle Up")
                        .font(.headline)
                        .frame(width: 125, height: 17) // Adjusted width and height for proper size
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 2)
                }

                Spacer() // This will push the next button to the right

                // Balances Button (Right Aligned)
                Button(action: {
                    print("Balances button pressed")
                }) {
                    Text("Balances")
                        .font(.headline)
                        .frame(width: 125, height: 17) // Adjusted width and height for proper size
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.teal, Color.black]), startPoint: .top, endPoint: .bottom)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 2)
                }
            }
            .padding([.top, .horizontal], 20)
            .padding(.bottom, 10)
            
            // List of Group Expenses
            List {
                ForEach(filteredGroupExpenses(), id: \.self) { groupExpense in
                    NavigationLink(destination: DetailedGroupExpense(expense: groupExpense)) {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(formatDate(groupExpense.date))
                                    .font(.subheadline)

                                Spacer()

                                Text(groupExpense.title ?? "No Title")
                                    .font(.headline)

                                Spacer()

                                Text("$\(groupExpense.amount, specifier: "%.2f")")
                                    .font(.body)
                                    .bold()
                                    .foregroundColor(.blue)
                            }

                            Text("Paid by: \(groupExpense.paidBy ?? "Unknown")")
                                .font(.subheadline)
                                .padding(.top, 2)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .onDelete(perform: deleteExpense)
            }
            .onAppear {
                calculateGroupTotals()
            }


        }
        .navigationTitle("Group Details")
        .navigationBarItems(
            trailing: NavigationLink(destination: AddGroupExpensesView(group: group)) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .top, endPoint: .bottom))
            }
        )
    }

    // Other methods remain unchanged...
    // Filter group expenses based on the current user
    private func filteredGroupExpenses() -> [GroupExpense] {
        guard let currentUserName = userData.currentUser?.name else { return [] }

        return groupExpenses.filter { groupExpense in
            guard let sharedBy = groupExpense.sharedBy, let paidBy = groupExpense.paidBy else { return false }
            let participants = sharedBy.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            return participants.contains(currentUserName) || paidBy == currentUserName
        }
    }

    // Format date to a user-friendly format
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d" // e.g., Dec 8
        return formatter.string(from: date)
    }

    private func calculateGroupTotals() {
        guard let currentUserName = userData.currentUser?.name else { return }

        var totalAmount = 0.0
        var totalOwedByUser = 0.0
        var totalAmountOwed = 0.0

        for groupExpense in filteredGroupExpenses() {
            totalAmount += groupExpense.amount

            if let sharedBy = groupExpense.sharedBy, let paidBy = groupExpense.paidBy {
                let participants = sharedBy.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                let shareAmount = groupExpense.amount / Double(participants.count + 1)

                if paidBy == currentUserName {
                    totalAmountOwed += shareAmount * Double(participants.count)
                } else if participants.contains(currentUserName) {
                    totalOwedByUser += shareAmount
                }
            }
        }

        self.totalAmount = totalAmount
        self.totalOwedByUser = totalOwedByUser
        self.totalAmountOwed = totalAmountOwed
    }
    private func deleteExpense(at offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredGroupExpenses()[$0] }.forEach { expense in
                viewContext.delete(expense)
            }
            
            do {
                try viewContext.save()
                // Recalculate totals after deletion
                    calculateGroupTotals()
            } catch {
                // Handle the error appropriately in your app
                print("Error deleting group expense: \(error)")
            }
        }
    }

}




