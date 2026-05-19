import SwiftUI

// MARK: - My Shopping List View
// Displays shopping list organized by department with print/share functionality

struct MyShoppingListView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddItem = false
    @State private var showingClearAlert = false
    @State private var showingPrintOptions = false
    
    var groupedItems: [(ShoppingItem.ShoppingCategory, [ShoppingItem])] {
        let grouped = Dictionary(grouping: dataManager.shoppingItems) { $0.category }
        return ShoppingItem.ShoppingCategory.allCases.compactMap { category in
            guard let items = grouped[category], !items.isEmpty else { return nil }
            return (category, items.sorted { $0.name < $1.name })
        }
    }
    
    var uncheckedCount: Int {
        dataManager.shoppingItems.filter { !$0.isChecked }.count
    }
    
    var checkedCount: Int {
        dataManager.shoppingItems.filter { $0.isChecked }.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if dataManager.shoppingItems.isEmpty {
                emptyState
            } else {
                shoppingListContent
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddShoppingItemView()
        }
        .alert("Clear Checked Items", isPresented: $showingClearAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                dataManager.clearCheckedItems()
            }
        } message: {
            Text("Remove all checked items from your shopping list?")
        }
        .sheet(isPresented: $showingPrintOptions) {
            PrintOptionsView(items: dataManager.shoppingItems)
        }
    }
    
    // MARK: - Shopping List Content
    
    private var shoppingListContent: some View {
        VStack(spacing: 0) {
            // Stats Bar
            statsBar
            
            // Action Buttons
            actionButtons
            
            // Shopping List
            List {
                ForEach(groupedItems, id: \.0) { category, items in
                    Section {
                        ForEach(items) { item in
                            ShoppingItemRow(item: item)
                        }
                        .onDelete { indexSet in
                            deleteItems(in: items, at: indexSet)
                        }
                    } header: {
                        HStack {
                            Image(systemName: category.icon)
                            Text(category.rawValue)
                        }
                        .font(.headline)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }
    
    // MARK: - Stats Bar
    
    private var statsBar: some View {
        HStack(spacing: 20) {
            HStack(spacing: 8) {
                Circle()
                    .fill(themeManager.currentTheme.primaryColor)
                    .frame(width: 12, height: 12)
                Text("\(uncheckedCount) to buy")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 12, height: 12)
                Text("\(checkedCount) checked")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                showingPrintOptions = true
            } label: {
                HStack {
                    Image(systemName: "printer.fill")
                    Text("Print/Share")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(themeManager.currentTheme.primaryColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(themeManager.currentTheme.primaryColor.opacity(0.15))
                .cornerRadius(10)
            }
            
            Button {
                showingClearAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Clear Checked")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.red.opacity(0.15))
                .cornerRadius(10)
            }
            .disabled(checkedCount == 0)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(themeManager.currentTheme.cardColor)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "cart.fill.badge.plus")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            themeManager.currentTheme.primaryColor,
                            themeManager.currentTheme.accentColor
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Shopping List Empty")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Add items manually or generate a list from your meal plan")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showingAddItem = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Item")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(themeManager.currentTheme.primaryColor)
                .cornerRadius(12)
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .overlay(alignment: .bottomTrailing) {
            addButton
        }
    }
    
    // MARK: - Add Button (FAB)
    
    private var addButton: some View {
        Button {
            showingAddItem = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                Text("Add Item")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [
                        themeManager.currentTheme.primaryColor,
                        themeManager.currentTheme.accentColor
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(30)
            .shadow(color: themeManager.currentTheme.primaryColor.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }
    
    private func deleteItems(in items: [ShoppingItem], at offsets: IndexSet) {
        for index in offsets {
            dataManager.deleteShoppingItem(items[index])
        }
    }
}

// MARK: - Shopping Item Row

struct ShoppingItemRow: View {
    let item: ShoppingItem
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button {
            dataManager.toggleShoppingItemChecked(item)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(item.isChecked ? .gray : themeManager.currentTheme.primaryColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.body)
                        .foregroundColor(item.isChecked ? .gray : .primary)
                        .strikethrough(item.isChecked)
                    
                    if !item.quantity.isEmpty {
                        Text(item.quantity)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Add Shopping Item View

struct AddShoppingItemView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    
    @State private var name = ""
    @State private var quantity = ""
    @State private var category: ShoppingItem.ShoppingCategory = .other
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Item Name", text: $name)
                    TextField("Quantity (e.g., 2 lbs, 1 box)", text: $quantity)
                } header: {
                    Text("Item Details")
                }
                
                Section {
                    Picker("Category", selection: $category) {
                        ForEach(ShoppingItem.ShoppingCategory.allCases, id: \.self) { cat in
                            HStack {
                                Image(systemName: cat.icon)
                                Text(cat.rawValue)
                            }
                            .tag(cat)
                        }
                    }
                } header: {
                    Text("Department")
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let item = ShoppingItem(
                            name: name,
                            quantity: quantity,
                            category: category
                        )
                        dataManager.addShoppingItem(item)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Print Options View

struct PrintOptionsView: View {
    let items: [ShoppingItem]
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var includeCheckedItems = false
    
    var filteredItems: [ShoppingItem] {
        includeCheckedItems ? items : items.filter { !$0.isChecked }
    }
    
    var groupedItems: [(ShoppingItem.ShoppingCategory, [ShoppingItem])] {
        let grouped = Dictionary(grouping: filteredItems) { $0.category }
        return ShoppingItem.ShoppingCategory.allCases.compactMap { category in
            guard let items = grouped[category], !items.isEmpty else { return nil }
            return (category, items.sorted { $0.name < $1.name })
        }
    }
    
    var listText: String {
        var text = "Shopping List\n"
        text += "Generated: \(Date().formatted(date: .abbreviated, time: .shortened))\n"
        text += "\(filteredItems.count) items\n\n"
        
        for (category, items) in groupedItems {
            text += "\n\(category.rawValue.uppercased())\n"
            text += String(repeating: "-", count: category.rawValue.count) + "\n"
            for item in items {
                let checkbox = item.isChecked ? "☑" : "☐"
                text += "\(checkbox) \(item.name)"
                if !item.quantity.isEmpty {
                    text += " - \(item.quantity)"
                }
                text += "\n"
            }
        }
        
        return text
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Preview
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Preview")
                            .font(.headline)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        
                        Text(listText)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(themeManager.currentTheme.cardColor)
                            .cornerRadius(12)
                    }
                    .padding()
                }
                
                // Options
                VStack(spacing: 12) {
                    Toggle(isOn: $includeCheckedItems) {
                        Text("Include checked items")
                            .font(.subheadline)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button {
                            shareList()
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share or Print")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(themeManager.currentTheme.primaryColor)
                            .cornerRadius(12)
                        }
                        
                        Button {
                            copyToClipboard()
                        } label: {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text("Copy to Clipboard")
                            }
                            .font(.headline)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(themeManager.currentTheme.primaryColor.opacity(0.15))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(themeManager.currentTheme.cardColor)
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Print/Share List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func shareList() {
        let activityVC = UIActivityViewController(
            activityItems: [listText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            
            // For iPad, set source for popover
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = listText
    }
}

#Preview {
    MyShoppingListView()
        .environmentObject(ThemeManager())
        .environmentObject(DataManager())
}
