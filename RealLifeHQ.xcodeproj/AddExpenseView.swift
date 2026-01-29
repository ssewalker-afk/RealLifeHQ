//
//  AddExpenseView.swift
//  RealLifeHQ
//
//  Created by Sarah Walker on 1/16/26.
//

import SwiftUI

struct AddExpenseView: View {
    @Binding var isPresented: Bool
    @State private var budgetManager = BudgetManager.shared
    
    var selectedMonth: Date
    var expenseToEdit: Expense?
    
    @State private var amount: String = ""
    @State private var selectedCategory: BudgetCategory?
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var isRecurring: Bool = false
    @State private var frequency: RecurringSchedule.Frequency = .monthly
    @State private var endDate: Date?
    @State private var hasEndDate: Bool = false
    
    init(isPresented: Binding<Bool>, selectedMonth: Date, expenseToEdit: Expense? = nil) {
        self._isPresented = isPresented
        self.selectedMonth = selectedMonth
        self.expenseToEdit = expenseToEdit
        
        if let expense = expenseToEdit {
            _amount = State(initialValue: String(format: "%.2f", expense.amount))
            _selectedCategory = State(initialValue: expense.category)
            _date = State(initialValue: expense.date)
            _note = State(initialValue: expense.note)
            _isRecurring = State(initialValue: expense.isRecurring)
            if let schedule = expense.recurringSchedule {
                _frequency = State(initialValue: schedule.frequency)
                _endDate = State(initialValue: schedule.endDate)
                _hasEndDate = State(initialValue: schedule.endDate != nil)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    HStack {
                        Text("$")
                            .font(.title2)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                    }
                }
                
                Section("Category") {
                    if budgetManager.categories.isEmpty {
                        Text("No categories available")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Category", selection: $selectedCategory) {
                            Text("Select Category").tag(nil as BudgetCategory?)
                            ForEach(budgetManager.categories) { category in
                                HStack {
                                    Image(systemName: category.icon)
                                    Text(category.name)
                                }
                                .tag(category as BudgetCategory?)
                            }
                        }
                    }
                }
                
                Section("Details") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextField("Note (optional)", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Toggle("Recurring Expense", isOn: $isRecurring)
                    
                    if isRecurring {
                        Picker("Frequency", selection: $frequency) {
                            ForEach(RecurringSchedule.Frequency.allCases, id: \.self) { freq in
                                Text(freq.rawValue).tag(freq)
                            }
                        }
                        
                        Toggle("Set End Date", isOn: $hasEndDate)
                        
                        if hasEndDate {
                            DatePicker("End Date", selection: Binding(
                                get: { endDate ?? Date() },
                                set: { endDate = $0 }
                            ), in: date..., displayedComponents: .date)
                        }
                    }
                } header: {
                    Text("Recurring")
                } footer: {
                    if isRecurring {
                        Text("Recurring expenses will automatically generate new expenses based on the schedule")
                    }
                }
            }
            .navigationTitle(expenseToEdit == nil ? "Add Expense" : "Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(expenseToEdit == nil ? "Add" : "Save") {
                        saveExpense()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        guard let amountValue = Double(amount), amountValue > 0 else { return false }
        guard selectedCategory != nil else { return false }
        return true
    }
    
    private func saveExpense() {
        guard let amountValue = Double(amount),
              let category = selectedCategory else { return }
        
        let schedule: RecurringSchedule? = isRecurring ? RecurringSchedule(
            frequency: frequency,
            startDate: date,
            endDate: hasEndDate ? endDate : nil
        ) : nil
        
        if let existing = expenseToEdit {
            let updated = Expense(
                id: existing.id,
                amount: amountValue,
                category: category,
                date: date,
                note: note,
                isRecurring: isRecurring,
                recurringSchedule: schedule
            )
            budgetManager.updateExpense(updated)
        } else {
            let expense = Expense(
                amount: amountValue,
                category: category,
                date: date,
                note: note,
                isRecurring: isRecurring,
                recurringSchedule: schedule
            )
            budgetManager.addExpense(expense)
        }
        
        isPresented = false
    }
}

#Preview {
    AddExpenseView(isPresented: .constant(true), selectedMonth: Date())
}
