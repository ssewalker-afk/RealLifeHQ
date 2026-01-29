//
//  AddCategoryView.swift
//  RealLifeHQ
//
//  Created by Sarah Walker on 1/16/26.
//

import SwiftUI

struct AddCategoryView: View {
    @Binding var isPresented: Bool
    @State private var budgetManager = BudgetManager.shared
    
    var categoryToEdit: BudgetCategory?
    
    @State private var name: String = ""
    @State private var selectedIcon: String = "tag.fill"
    @State private var selectedColor: Color = .blue
    @State private var limit: String = ""
    @State private var type: BudgetCategory.CategoryType = .needs
    
    init(isPresented: Binding<Bool>, categoryToEdit: BudgetCategory? = nil) {
        self._isPresented = isPresented
        self.categoryToEdit = categoryToEdit
        
        if let category = categoryToEdit {
            _name = State(initialValue: category.name)
            _selectedIcon = State(initialValue: category.icon)
            _selectedColor = State(initialValue: category.colorValue)
            _limit = State(initialValue: String(format: "%.2f", category.limit))
            _type = State(initialValue: category.type)
        }
    }
    
    let availableIcons = [
        "tag.fill", "house.fill", "car.fill", "cart.fill", "bag.fill",
        "fork.knife", "ticket.fill", "gamecontroller.fill", "tv.fill",
        "bolt.fill", "phone.fill", "wifi", "heart.fill", "gift.fill",
        "book.fill", "graduationcap.fill", "briefcase.fill", "wrench.fill",
        "paintbrush.fill", "leaf.fill", "flame.fill", "drop.fill"
    ]
    
    let availableColors: [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal,
        .cyan, .blue, .indigo, .purple, .pink, .brown
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Category Name", text: $name)
                    
                    Picker("Type", selection: $type) {
                        ForEach(BudgetCategory.CategoryType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    HStack {
                        Text("$")
                            .font(.title2)
                        TextField("Monthly Limit", text: $limit)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                    }
                }
                
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundStyle(selectedIcon == icon ? selectedColor : .secondary)
                                    .frame(width: 44, height: 44)
                                    .background(selectedIcon == icon ? selectedColor.opacity(0.2) : Color.clear)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                        ForEach(availableColors, id: \.self) { color in
                            Button {
                                selectedColor = color
                            } label: {
                                Circle()
                                    .fill(color)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(.white, lineWidth: selectedColor == color ? 3 : 0)
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Preview") {
                    HStack {
                        Image(systemName: selectedIcon)
                            .foregroundStyle(selectedColor)
                            .frame(width: 30)
                        
                        Text(name.isEmpty ? "Category Name" : name)
                            .font(.headline)
                        
                        Spacer()
                        
                        if let limitValue = Double(limit), limitValue > 0 {
                            Text("$\(limitValue, specifier: "%.2f")")
                                .font(.subheadline.bold())
                        }
                    }
                    .padding()
                    .background(Color.quaternaryBackground, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .navigationTitle(categoryToEdit == nil ? "New Category" : "Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(categoryToEdit == nil ? "Add" : "Save") {
                        saveCategory()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty && (Double(limit) ?? 0) > 0
    }
    
    private func saveCategory() {
        guard let limitValue = Double(limit) else { return }
        
        let colorHex = selectedColor.toHex() ?? "0000FF"
        
        if let existing = categoryToEdit {
            let updated = BudgetCategory(
                id: existing.id,
                name: name,
                icon: selectedIcon,
                color: colorHex,
                limit: limitValue,
                type: type
            )
            budgetManager.updateCategory(updated)
        } else {
            let category = BudgetCategory(
                name: name,
                icon: selectedIcon,
                color: colorHex,
                limit: limitValue,
                type: type
            )
            budgetManager.addCategory(category)
        }
        
        isPresented = false
    }
}

#Preview {
    AddCategoryView(isPresented: .constant(true))
}
