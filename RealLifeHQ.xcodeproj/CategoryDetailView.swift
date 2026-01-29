//
//  CategoryDetailView.swift
//  RealLifeHQ
//
//  Created by Sarah Walker on 1/16/26.
//

import SwiftUI

struct CategoryDetailView: View {
    @State private var budgetManager = BudgetManager.shared
    @Environment(\.dismiss) private var dismiss
    
    let category: BudgetCategory
    let selectedMonth: Date
    
    @State private var showEditCategory = false
    @State private var showAddExpense = false
    @State private var showDeleteAlert = false
    
    var expenses: [Expense] {
        budgetManager.expensesForCategory(category, in: selectedMonth)
            .sorted { $0.date > $1.date }
    }
    
    var totalSpent: Double {
        budgetManager.totalSpent(for: category, in: selectedMonth)
    }
    
    var remaining: Double {
        category.limit - totalSpent
    }
    
    var progress: Double {
        budgetManager.categoryProgress(category, in: selectedMonth)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Category Header
                VStack(spacing: 16) {
                    Image(systemName: category.icon)
                        .font(.system(size: 60))
                        .foregroundStyle(category.colorValue)
                    
                    Text(category.name)
                        .font(.title.bold())
                    
                    Text(category.type.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(category.type.color.opacity(0.2), in: Capsule())
                }
                .padding()
                
                // Budget Progress
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Spent")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("$\(totalSpent, specifier: "%.2f")")
                                .font(.title2.bold())
                                .foregroundStyle(progress > 1 ? .red : .primary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Budget")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("$\(category.limit, specifier: "%.2f")")
                                .font(.title2.bold())
                        }
                    }
                    
                    ProgressView(value: min(progress, 1.0))
                        .tint(progress > 0.9 ? .red : (progress > 0.7 ? .orange : category.colorValue))
                    
                    if progress > 1 {
                        Text("Over budget by $\(abs(remaining), specifier: "%.2f")")
                            .font(.subheadline.bold())
                            .foregroundStyle(.red)
                    } else {
                        Text("$\(remaining, specifier: "%.2f") remaining")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                
                // Expenses List
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Expenses")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button {
                            showAddExpense = true
                        } label: {
                            Label("Add", systemImage: "plus.circle.fill")
                                .font(.subheadline)
                        }
                    }
                    
                    if expenses.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "tray")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                            
                            Text("No expenses in this category")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ForEach(expenses) { expense in
                            NavigationLink {
                                ExpenseDetailView(expense: expense)
                            } label: {
                                ExpenseRow(expense: expense)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Category Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showEditCategory = true
                    } label: {
                        Label("Edit Category", systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete Category", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showEditCategory) {
            AddCategoryView(isPresented: $showEditCategory, categoryToEdit: category)
        }
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView(isPresented: $showAddExpense, selectedMonth: selectedMonth)
        }
        .alert("Delete Category", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                budgetManager.deleteCategory(category)
                dismiss()
            }
        } message: {
            Text("This will delete the category and all associated expenses. This action cannot be undone.")
        }
    }
}

#Preview {
    NavigationStack {
        CategoryDetailView(
            category: BudgetCategory(name: "Groceries", icon: "cart.fill", color: "FF6B6B", limit: 500, type: .needs),
            selectedMonth: Date()
        )
    }
}
