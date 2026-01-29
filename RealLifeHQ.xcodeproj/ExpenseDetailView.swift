//
//  ExpenseDetailView.swift
//  RealLifeHQ
//
//  Created by Sarah Walker on 1/16/26.
//

import SwiftUI

struct ExpenseDetailView: View {
    @State private var budgetManager = BudgetManager.shared
    @Environment(\.dismiss) private var dismiss
    
    let expense: Expense
    
    @State private var showEditExpense = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Amount
                VStack(spacing: 8) {
                    Text("$\(expense.amount, specifier: "%.2f")")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(expense.category.colorValue)
                }
                .padding()
                
                // Details
                VStack(spacing: 16) {
                    DetailRow(
                        icon: expense.category.icon,
                        label: "Category",
                        value: expense.category.name,
                        color: expense.category.colorValue
                    )
                    
                    DetailRow(
                        icon: "calendar",
                        label: "Date",
                        value: expense.date.formatted(date: .long, time: .omitted)
                    )
                    
                    if !expense.note.isEmpty {
                        DetailRow(
                            icon: "note.text",
                            label: "Note",
                            value: expense.note
                        )
                    }
                    
                    if expense.isRecurring {
                        DetailRow(
                            icon: "arrow.clockwise",
                            label: "Recurring",
                            value: expense.recurringSchedule?.frequency.rawValue ?? "Yes",
                            color: .blue
                        )
                        
                        if let schedule = expense.recurringSchedule {
                            DetailRow(
                                icon: "calendar.badge.clock",
                                label: "Start Date",
                                value: schedule.startDate.formatted(date: .long, time: .omitted)
                            )
                            
                            if let endDate = schedule.endDate {
                                DetailRow(
                                    icon: "calendar.badge.exclamationmark",
                                    label: "End Date",
                                    value: endDate.formatted(date: .long, time: .omitted)
                                )
                            }
                        }
                    }
                    
                    DetailRow(
                        icon: "tag.fill",
                        label: "Type",
                        value: expense.category.type.rawValue,
                        color: expense.category.type.color
                    )
                }
                .padding()
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .navigationTitle("Expense Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showEditExpense = true
                    } label: {
                        Label("Edit Expense", systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete Expense", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showEditExpense) {
            AddExpenseView(isPresented: $showEditExpense, selectedMonth: expense.date, expenseToEdit: expense)
        }
        .alert("Delete Expense", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                budgetManager.deleteExpense(expense)
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    var color: Color = .primary
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.body)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        ExpenseDetailView(
            expense: Expense(
                amount: 125.50,
                category: BudgetCategory(name: "Groceries", icon: "cart.fill", color: "FF6B6B", limit: 500, type: .needs),
                date: Date(),
                note: "Weekly grocery shopping"
            )
        )
    }
}
