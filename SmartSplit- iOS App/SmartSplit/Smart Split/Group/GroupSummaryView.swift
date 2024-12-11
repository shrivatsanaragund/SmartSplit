//
//  GroupSummaryView.swift
//  Smart Split
//
//  Created by Shrivatsa Naragund on 11/28/24.
//

import SwiftUI

struct GroupSummaryView: View {
    var body: some View {
        VStack {
            Text("Group Expense Summary")
                .font(.largeTitle)
                .padding()

            // Add your summary content here
            Text("Here you can see a detailed summary of your group's expenses.")
                .font(.body)
                .foregroundColor(.gray)
                .padding()

            // Example summary content
            List {
                Section(header: Text("Summary").font(.headline)) {
                    Text("Total Expenses: $1,200")
                    Text("Average Per Member: $300")
                    Text("Most Spent Category: Food")
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .padding()
        .navigationTitle("Summary")
    }
}
