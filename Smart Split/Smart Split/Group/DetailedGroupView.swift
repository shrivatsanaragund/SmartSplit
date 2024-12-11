//
//  DetailedGroupView.swift
//  Smart Split
//
//  Created by Shrivatsa Naragund on 12/9/24.
//

//import SwiftUI
//import CoreData

//struct DetailedGroupView: View {
//    var group: Group
//    @Environment(\.managedObjectContext) private var viewContext
//    @State private var isNavigating = false
//    @State private var expenseToDelete: GroupExpense? = nil
//    @State private var showingDeleteConfirmation = false
//    @State private var groupExpenses: [GroupExpense] = [] // Store expenses here
//
//    // Fetch group expenses
//    private func fetchGroupExpenses() {
//        let request: NSFetchRequest<GroupExpense> = GroupExpense.fetchRequest()
//        request.predicate = NSPredicate(format: "group == %@", group)
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \GroupExpense.date, ascending: false)]
//        
//        do {
//            let expenses = try viewContext.fetch(request)
//            groupExpenses = expenses
//        } catch {
//            print("Failed to fetch group expenses: \(error)")
//        }
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            HStack {
//                // Display group image or placeholder
//                if let imageData = group.groupImage, let uiImage = UIImage(data: imageData) {
//                    Image(uiImage: uiImage)
//                        .resizable()
//                        .frame(width: 100, height: 100)
//                        .clipShape(Circle())
//                } else {
//                    // Simple circle with no background
//                    Circle()
//                        .frame(width: 100, height: 100)
//                        .foregroundColor(.clear)
//                }
//                
//                Text(group.name ?? "Unnamed Group")
//                    .font(.title)
//                    .bold()
//                    .padding(.leading, 10)
//            }
//            .padding(.bottom, 20)
//
//            // Expenses list
//            if !groupExpenses.isEmpty {
//                List {
//                    ForEach(groupExpenses) { expense in
//                        VStack(alignment: .leading, spacing: 5) {
//                            NavigationLink(destination: DetailedGroupExpense(expense: expense), isActive: $isNavigating) {
//                                EmptyView()
//                            }
//
//                            HStack {
//                                Text(formatDate(expense.date))
//                                    .font(.subheadline)
//
//                                Spacer()
//
//                                Text(expense.title ?? "No Title")
//                                    .font(.headline)
//
//                                Spacer()
//
//                                Text("$\(expense.amount, specifier: "%.2f")")
//                                    .font(.body)
//                                    .bold()
//                                    .foregroundColor(.blue)
//                            }
//
//                            Text("Paid by: \(expense.paidBy ?? "Unknown")")
//                                .font(.subheadline)
//                                .padding(.top, 2)
//                        }
//                        .padding(.vertical, 8)
//                        .swipeActions(edge: .leading) {
//                            Button(action: {
//                                print("Editing expense: \(expense.title ?? "No Title") - \(expense.amount)")
//                            }) {
//                                Image(systemName: "pencil")
//                            }
//                            .tint(.blue)
//                        }
//                        .swipeActions(edge: .trailing) {
//                            Button(action: {
//                                expenseToDelete = expense
//                                showingDeleteConfirmation = true
//                            }) {
//                                Image(systemName: "trash")
//                            }
//                            .tint(.red)
//                        }
//                    }
//                    .onDelete(perform: deleteExpenses)
//                }
//                .listStyle(PlainListStyle())
//                .confirmationDialog("Are you sure you want to delete this expense?", isPresented: $showingDeleteConfirmation) {
//                    Button("Delete", role: .destructive) {
//                        if let expenseToDelete = expenseToDelete {
//                            deleteExpense(expense: expenseToDelete)
//                        }
//                    }
//                    Button("Cancel", role: .cancel) { }
//                }
//            } else {
//                Text("No expenses added yet.")
//                    .font(.body)
//                    .italic()
//                    .padding(.horizontal, 10)
//            }
//            
//            Spacer()
//        }
//        .padding()
//        .background(Color(UIColor.systemGray6))
//        .cornerRadius(10)
//        .navigationBarItems(trailing: NavigationLink(destination: AddGroupExpensesView(group: group)) {
//            Image(systemName: "plus.circle.fill")
//                .font(.title3)
//                .foregroundColor(.blue)
//        })
//        .onAppear {
//            fetchGroupExpenses() // Fetch expenses when the view appears
//        }
//    }
//
//    private func formatDate(_ date: Date?) -> String {
//        guard let date = date else { return "Unknown Date" }
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMM d, yyyy"
//        return formatter.string(from: date)
//    }
//
//    private func deleteExpense(expense: GroupExpense) {
//        withAnimation {
//            viewContext.delete(expense)
//            do {
//                try viewContext.save()
//                fetchGroupExpenses() // Refresh the expenses list after deleting
//            } catch {
//                print("Error deleting expense: \(error)")
//            }
//        }
//    }
//
//    private func deleteExpenses(at offsets: IndexSet) {
//        withAnimation {
//            offsets.map { groupExpenses[$0] }.forEach(viewContext.delete)
//            do {
//                try viewContext.save()
//                fetchGroupExpenses() // Refresh after deletion
//            } catch {
//                print("Error deleting expenses: \(error)")
//            }
//        }
//    }
//}

import SwiftUI
import CoreData

struct DetailedGroupView: View {
    var group: Group
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isNavigating = false
    @State private var expenseToDelete: GroupExpense? = nil
    @State private var showingDeleteConfirmation = false
    @State private var groupExpenses: [GroupExpense] = []
    @State private var userBalances: [String: Double] = [:]
    
    @EnvironmentObject var userData: UserData

    // Fetch group expenses
    private func fetchGroupExpenses() {
        let request: NSFetchRequest<GroupExpense> = GroupExpense.fetchRequest()
        request.predicate = NSPredicate(format: "group == %@", group)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \GroupExpense.date, ascending: false)]
        
        do {
            let expenses = try viewContext.fetch(request)
            groupExpenses = expenses
            calculateUserBalances()
        } catch {
            print("Failed to fetch group expenses: \(error)")
        }
    }

    // Calculate balances
    private func calculateUserBalances() {
        guard let currentUserName = userData.currentUser?.name else { return }
        var balances: [String: Double] = [:]

        for expense in groupExpenses {
            let paidBy = expense.paidBy?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown"
            balances[paidBy, default: 0.0] += expense.amount

            if let sharedByString = expense.sharedBy {
                let participants = sharedByString
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                
                // Calculate the share amount per participant (excluding the payer)
                let shareAmount = expense.amount / Double(participants.count + 1)

                for participant in participants {
                    // Deduct the share amount from each participant
                    balances[participant, default: 0.0] -= shareAmount
                    
                    // Add the share amount back to the payer
                    balances[paidBy, default: 0.0] += shareAmount
                }
            }
        }

        // Filter out balances that are zero for better display
        userBalances = balances.filter { $0.value != 0 }
    }
    
    


    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                // Display group image or placeholder
                if let imageData = group.groupImage, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.clear)
                }
                
                Text(group.name ?? "Unnamed Group")
                    .font(.title)
                    .bold()
                    .padding(.leading, 10)
            }
            .padding(.bottom, 10)

            // Display owed messages
            VStack(alignment: .leading, spacing: 8) {
                Text("User Balances")
                    .font(.headline)
                    .bold()

                ForEach(userBalances.sorted(by: { $0.key < $1.key }), id: \.key) { user, balance in
                    if balance > 0 {
                        Text("\(user) owes you $\(balance, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    } else if balance < 0 {
                        Text("You owe \(user) $\(abs(balance), specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                }

                let overallBalance = userBalances.values.reduce(0, +)
                if overallBalance > 0 {
                    Text("You are owed $\(overallBalance, specifier: "%.2f") overall.")
                        .font(.subheadline)
                        .foregroundColor(.green)
                } else if overallBalance < 0 {
                    Text("You owe $\(abs(overallBalance), specifier: "%.2f") overall.")
                        .font(.subheadline)
                        .foregroundColor(.red)
                } else {
                    Text("You are settled overall.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            .padding(.bottom, 10)

            // Settle Up button
            Button(action: {
                print("Settle up button tapped")
            }) {
                Text("Settle Up")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.vertical, 10)

            // Expenses list
            if !groupExpenses.isEmpty {
                List {
                    ForEach(groupExpenses) { expense in
                        VStack(alignment: .leading, spacing: 5) {
                            NavigationLink(destination: DetailedGroupExpense(expense: expense), isActive: $isNavigating) {
                                EmptyView()
                            }

                            HStack {
                                Text(formatDate(expense.date))
                                    .font(.subheadline)

                                Spacer()

                                Text(expense.title ?? "No Title")
                                    .font(.headline)

                                Spacer()

                                Text("$\(expense.amount, specifier: "%.2f")")
                                    .font(.body)
                                    .bold()
                                    .foregroundColor(.blue)
                            }

                            Text("Paid by: \(expense.paidBy ?? "Unknown")")
                                .font(.subheadline)
                                .padding(.top, 2)
                        }
                        .padding(.vertical, 8)
                        .swipeActions(edge: .leading) {
                            Button(action: {
                                print("Editing expense: \(expense.title ?? "No Title") - \(expense.amount)")
                            }) {
                                Image(systemName: "pencil")
                            }
                            .tint(.blue)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(action: {
                                expenseToDelete = expense
                                showingDeleteConfirmation = true
                            }) {
                                Image(systemName: "trash")
                            }
                            .tint(.red)
                        }
                    }
                    .onDelete(perform: deleteExpenses)
                }
                .listStyle(PlainListStyle())
                .confirmationDialog("Are you sure you want to delete this expense?", isPresented: $showingDeleteConfirmation) {
                    Button("Delete", role: .destructive) {
                        if let expenseToDelete = expenseToDelete {
                            deleteExpense(expense: expenseToDelete)
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                }
            } else {
                Text("No expenses added yet.")
                    .font(.body)
                    .italic()
                    .padding(.horizontal, 10)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
        .navigationBarItems(trailing: NavigationLink(destination: AddGroupExpensesView(group: group)) {
            Image(systemName: "plus.circle.fill")
                .font(.title3)
                .foregroundColor(.blue)
        })
        .onAppear {
            fetchGroupExpenses() // Fetch expenses when the view appears
        }
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown Date" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }

    private func deleteExpense(expense: GroupExpense) {
        withAnimation {
            viewContext.delete(expense)
            do {
                try viewContext.save()
                fetchGroupExpenses() // Refresh the expenses list after deleting
            } catch {
                print("Error deleting expense: \(error)")
            }
        }
    }

    private func deleteExpenses(at offsets: IndexSet) {
        withAnimation {
            offsets.map { groupExpenses[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
                fetchGroupExpenses() // Refresh after deletion
            } catch {
                print("Error deleting expenses: \(error)")
            }
        }
    }
}
