import SwiftUI
import CoreData


struct ExpensesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Expense.date, ascending: false)])
    private var expenses: FetchedResults<Expense>


    @EnvironmentObject var userData: UserData

    @State private var showingDeleteConfirmation = false
    @State private var expenseToDelete: Expense?

    // State variables for displaying summary info
    @State private var totalAmount: Double = 0.0
    @State private var totalOwedByUser: Double = 0.0
    @State private var totalAmountOwed: Double = 0.0

    @State private var selectedExpense: Expense? = nil // To store the selected expense for navigation
    @State private var isNavigating = false // To control when navigation occurs

    var body: some View {
        NavigationView {
            VStack {
                // Summary section for Total Expenses and Amount Owed
                VStack(alignment: .leading, spacing: 10) {
                    Text("Summary")
                        .font(.title)
                        .bold()
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing))

                    HStack {
                        Text("Total Expenses: ")
                        Spacer()
                        Text("$\(totalAmount, specifier: "%.2f")")
                            .foregroundColor(.blue)
                            .bold()
                    }

                    HStack {
                        Text("You owe: ")
                        Spacer()
                        Text("$\(totalOwedByUser, specifier: "%.2f")")
                            .foregroundColor(.red)
                            .bold()
                    }

                    HStack {
                        Text("You are owed: ")
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

                // List of Expenses

                List {
                    ForEach(filteredExpenses()) { expense in
                        VStack(alignment: .leading, spacing: 5) { // Reduced spacing between elements
                            // NavigationLink that is controlled by the state variable
                            NavigationLink(destination: DetailedExpenseView(expense: expense), isActive: $isNavigating) {
                                EmptyView() // Invisible NavigationLink, it's activated programmatically
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

                            // Only "Paid by" field is displayed
                            Text("Paid by: \(expense.paidBy ?? "Unknown")")
                                .font(.subheadline)
                                .padding(.top, 2) // Minimal padding for clarity
                        }
                        .padding(.vertical, 8) // Adjust vertical padding for a compact look
                        .swipeActions(edge: .leading) {
                            Button(action: {
                                editExpense(expense)
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
                }

//                .navigationTitle("Expenses")
//                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .navigationBarItems(trailing: NavigationLink(destination: AddExpenseView()) {
                    Image(systemName: "plus.circle.fill")
//                        .foregroundColor(.blue)
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .topLeading, endPoint: .bottomTrailing))
                })

                // Confirmation Alert for Deletion
                .alert(isPresented: $showingDeleteConfirmation) {
                    Alert(
                        title: Text("Delete Expense"),
                        message: Text("Are you sure you want to delete this expense?"),
                        primaryButton: .destructive(Text("Delete")) {
                            if let expenseToDelete = expenseToDelete {
                                deleteExpense(expenseToDelete)
                            }
                        },
                        secondaryButton: .cancel {
                            expenseToDelete = nil
                        }
                    )
                }
                .onAppear {
                    calculateTotals()
                }
            }
        }
    }

    // Filter expenses based on the current user
    private func filteredExpenses() -> [Expense] {
        guard let currentUserName = userData.currentUser?.name else { return [] }

        return expenses.filter { expense in
            guard let sharedBy = expense.sharedBy, let paidBy = expense.paidBy else { return false }
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

    private func deleteExpense(_ expense: Expense) {
        viewContext.delete(expense)

        do {
            try viewContext.save()
            calculateTotals()
        } catch {
            print("Failed to delete expense: \(error.localizedDescription)")
        }
    }

    private func editExpense(_ expense: Expense) {
        // Set the selected expense and trigger navigation
        selectedExpense = expense
        isNavigating = true // This will activate the NavigationLink
    }

    private func calculateTotals() {
        guard let currentUserName = userData.currentUser?.name else { return }

        var totalAmount = 0.0
        var totalOwedByUser = 0.0
        var totalAmountOwed = 0.0

        for expense in filteredExpenses() {
            totalAmount += expense.amount

            if let sharedBy = expense.sharedBy, let paidBy = expense.paidBy {
                let participants = sharedBy.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                let shareAmount = expense.amount / Double(participants.count + 1)

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
}
