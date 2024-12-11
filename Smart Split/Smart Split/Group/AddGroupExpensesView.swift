//
//  AddGroupExpensesView.swift
//  Smart Split
//
//  Created by Shrivatsa Naragund on 12/10/24.
//

import SwiftUI
import CoreData

struct AddGroupExpensesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var title = ""
    @State private var amount = ""
    @State private var category = "Food and Drink"
    @State private var paidBy: User?
    @State private var sharedBy: Set<User> = []
    @State private var expenseDate = Date()

    @Environment(\.presentationMode) var presentationMode

    // Error and Success Alerts
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var showSuccessAlert = false
    @State private var successMessage = "Expense added successfully!"

    // Predefined categories for the picker
    private let categories = ["Entertainment", "Food and Drink", "Household", "Healthcare", "Transportation", "Utilities", "Other"]

    // Fetching users for "Paid By" and "Shared By" dropdowns
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \User.name, ascending: true)])
    private var users: FetchedResults<User>

    // Computed property to disable Save button
    private var isSaveButtonDisabled: Bool {
        title.isEmpty ||
        amount.isEmpty ||
        Double(amount) == nil ||
        Double(amount)! <= 0 ||
        paidBy == nil ||
        sharedBy.isEmpty
    }

    var group: Group

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Add Group Expense")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 10)

                // Title Field
                TextFieldView(title: "Expense Title", text: $title)

                // Amount Field
                TextFieldView(title: "Amount", text: $amount, keyboardType: .decimalPad)

                // Category Dropdown
                LabeledSection(label: "Category") {
                    Picker("Select Category", selection: $category) {
                        ForEach(categories, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxHeight: 150)
                }

                // Paid By Dropdown
                LabeledSection(label: "Paid By") {
                    Picker("Select User", selection: $paidBy) {
                        ForEach(users, id: \.self) { user in
                            Text(user.name ?? "Unknown").tag(user as User?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                // Shared By Multi-Selection
                LabeledSection(label: "Shared By") {
                    MultiSelectionPicker(users: users, selectedUsers: $sharedBy)
                }

                // Date Picker
                LabeledSection(label: "Expense Date") {
                    DatePicker("Select Date", selection: $expenseDate, displayedComponents: .date)
                        .labelsHidden()
                }

                // Save Button
                Button(action: saveExpense) {
                    Text("Save Expense")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isSaveButtonDisabled ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 2)
                }
                .disabled(isSaveButtonDisabled)
                .padding(.top, 20)

                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .cornerRadius(12)
            .padding()
        }
        .navigationBarTitle("Add Expense", displayMode: .inline)
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Success"),
                message: Text(successMessage),
                dismissButton: .default(Text("OK")) {
                    clearFields()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }

    private func saveExpense() {
        guard !title.isEmpty else {
            showError("Title is required.")
            return
        }
        guard let amountValue = Double(amount), amountValue > 0 else {
            showError("Amount must be a valid number and greater than 0.")
            return
        }
        guard let paidBy = paidBy else {
            showError("Paid By is required.")
            return
        }
        guard !sharedBy.isEmpty else {
            showError("At least one person must share the expense.")
            return
        }

        let newExpense = GroupExpense(context: viewContext)
        newExpense.id = UUID()
        newExpense.title = title
        newExpense.amount = amountValue
        newExpense.category = category
        newExpense.paidBy = paidBy.name ?? "Unknown"
        newExpense.sharedBy = sharedBy.map { $0.name ?? "Unknown" }.joined(separator: ", ")
        newExpense.date = expenseDate
        newExpense.group = group

        do {
            try viewContext.save()
            showSuccessAlert = true
        } catch {
            showError("Failed to save expense: \(error.localizedDescription)")
        }
    }

    private func showError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
    }

    private func clearFields() {
        title = ""
        amount = ""
        category = "Food and Drink"
        paidBy = nil
        sharedBy = []
        expenseDate = Date()
    }
}

struct GroupMultiSelectionPicker: View {
    let users: FetchedResults<User>
    @Binding var selectedUsers: Set<User>

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(users, id: \.self) { user in
                HStack {
                    Text(user.name ?? "Unknown")
                    Spacer()
                    if selectedUsers.contains(user) {
                        Image(systemName: "checkmark")
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    toggleSelection(for: user)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }

    private func toggleSelection(for user: User) {
        if selectedUsers.contains(user) {
            selectedUsers.remove(user)
        } else {
            selectedUsers.insert(user)
        }
    }
}

struct GroupTextFieldView: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
            TextField(title, text: $text)
                .keyboardType(keyboardType)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
        }
    }
}

struct GroupLabeledSection<Content: View>: View {
    let label: String
    let content: () -> Content

    init(label: String, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.headline)
            content()
        }
        .padding(.vertical)
    }
}
