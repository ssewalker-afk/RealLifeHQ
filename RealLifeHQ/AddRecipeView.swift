import SwiftUI
import PhotosUI

// MARK: - Add/Edit Recipe View
// Form to create or edit a recipe

struct AddRecipeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    
    // If editing, pass in existing recipe
    var recipeToEdit: Recipe?
    
    @State private var name = ""
    @State private var mealType: Recipe.MealType = .lunch
    @State private var prepTime = 15
    @State private var cookTime = 30
    @State private var servings = 4
    @State private var recipeDescription = ""
    @State private var notes = ""
    @State private var ingredients: [IngredientInput] = [IngredientInput()]
    @State private var instructions: [String] = [""]
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var recipeImage: UIImage?
    
    struct IngredientInput: Identifiable {
        let id = UUID()
        var amount = ""
        var unit = ""
        var name = ""
    }
    
    var isEditing: Bool {
        recipeToEdit != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Basic Info Section
                Section {
                    TextField("Recipe Name", text: $name)
                        .font(.headline)
                    
                    Picker("Meal Type", selection: $mealType) {
                        ForEach(Recipe.MealType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                } header: {
                    Text("Basic Information")
                }
                
                // Photo Section
                Section {
                    if let image = recipeImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(8)
                    }
                    
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label(recipeImage == nil ? "Add Photo" : "Change Photo", systemImage: "photo")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                } header: {
                    Text("Photo")
                }
                
                // Time & Servings Section
                Section {
                    Stepper("Prep Time: \(prepTime) min", value: $prepTime, in: 0...300, step: 5)
                    Stepper("Cook Time: \(cookTime) min", value: $cookTime, in: 0...600, step: 5)
                    Stepper("Servings: \(servings)", value: $servings, in: 1...20)
                } header: {
                    Text("Time & Servings")
                }
                
                // Ingredients Section
                Section {
                    ForEach($ingredients) { $ingredient in
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                TextField("Amount", text: $ingredient.amount)
                                    .keyboardType(.decimalPad)
                                    .frame(width: 60)
                                    .textFieldStyle(.roundedBorder)
                                
                                TextField("Unit", text: $ingredient.unit)
                                    .frame(width: 80)
                                    .textFieldStyle(.roundedBorder)
                                
                                TextField("Ingredient", text: $ingredient.name)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                    }
                    .onDelete(perform: deleteIngredient)
                    
                    Button {
                        ingredients.append(IngredientInput())
                    } label: {
                        Label("Add Ingredient", systemImage: "plus.circle.fill")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                } header: {
                    Text("Ingredients")
                } footer: {
                    Text("Example: Amount: 2, Unit: cups, Ingredient: flour")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Instructions Section
                Section {
                    ForEach(instructions.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Step \(index + 1)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                            
                            TextEditor(text: $instructions[index])
                                .frame(minHeight: 60)
                        }
                    }
                    .onDelete(perform: deleteInstruction)
                    
                    Button {
                        instructions.append("")
                    } label: {
                        Label("Add Step", systemImage: "plus.circle.fill")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                } header: {
                    Text("Instructions")
                }
                
                // Description Section
                Section {
                    TextEditor(text: $recipeDescription)
                        .frame(minHeight: 80)
                } header: {
                    Text("How to Prepare (Description)")
                } footer: {
                    Text("Add any special notes about preparation, techniques, or tips")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Notes Section
                Section {
                    TextEditor(text: $notes)
                        .frame(minHeight: 60)
                } header: {
                    Text("Additional Notes (Optional)")
                }
                
                // Delete Button (if editing)
                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            if let recipe = recipeToEdit {
                                dataManager.deleteRecipe(recipe)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Label("Delete Recipe", systemImage: "trash")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Recipe" : "New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        saveRecipe()
                    }
                    .disabled(name.isEmpty || ingredients.allSatisfy { $0.name.isEmpty })
                }
            }
            .onChange(of: selectedPhotoItem) { oldValue, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        recipeImage = image
                    }
                }
            }
            .onAppear {
                loadRecipeData()
            }
        }
    }
    
    private func loadRecipeData() {
        guard let recipe = recipeToEdit else { return }
        
        name = recipe.name
        mealType = recipe.mealType
        prepTime = recipe.prepTime
        cookTime = recipe.cookTime
        servings = recipe.servings
        recipeDescription = recipe.recipeDescription ?? ""
        notes = recipe.notes ?? ""
        
        // Load ingredients
        ingredients = recipe.ingredients.map { ingredient in
            IngredientInput(amount: ingredient.amount, unit: ingredient.unit, name: ingredient.name)
        }
        
        if ingredients.isEmpty {
            ingredients = [IngredientInput()]
        }
        
        // Load instructions
        instructions = recipe.instructions
        if instructions.isEmpty {
            instructions = [""]
        }
        
        // Load image
        if let imageData = recipe.imageData {
            recipeImage = UIImage(data: imageData)
        }
    }
    
    private func deleteIngredient(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
        if ingredients.isEmpty {
            ingredients.append(IngredientInput())
        }
    }
    
    private func deleteInstruction(at offsets: IndexSet) {
        instructions.remove(atOffsets: offsets)
        if instructions.isEmpty {
            instructions.append("")
        }
    }
    
    private func saveRecipe() {
        // Convert ingredient inputs to proper format
        let recipeIngredients = ingredients
            .filter { !$0.name.isEmpty }
            .map { Recipe.Ingredient(name: $0.name, amount: $0.amount, unit: $0.unit) }
        
        // Filter out empty instructions
        let recipeInstructions = instructions.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        var recipe = Recipe(
            id: recipeToEdit?.id ?? UUID(),
            name: name,
            mealType: mealType,
            prepTime: prepTime,
            cookTime: cookTime,
            servings: servings,
            ingredients: recipeIngredients,
            instructions: recipeInstructions,
            recipeDescription: recipeDescription.isEmpty ? nil : recipeDescription,
            notes: notes.isEmpty ? nil : notes,
            isFavorite: recipeToEdit?.isFavorite ?? false,
            imageData: recipeImage?.jpegData(compressionQuality: 0.7),
            createdDate: recipeToEdit?.createdDate ?? Date()
        )
        
        if isEditing {
            dataManager.updateRecipe(recipe)
        } else {
            dataManager.addRecipe(recipe)
        }
        
        dismiss()
    }
}

#Preview {
    AddRecipeView()
        .environmentObject(ThemeManager())
        .environmentObject(DataManager())
}
