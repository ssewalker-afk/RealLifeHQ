// MARK: - AI Recipe Generator View (DEPRECATED)
// This file has been deprecated. External AI integrations have been removed.
// See APPLE_INTELLIGENCE_NOTES.md for information about using Apple Intelligence.

/*
 DEPRECATION NOTICE
 ==================
 This view has been removed from active use.
 Remove this file from Build Phases → Compile Sources to prevent compilation.
 See NEXT_STEPS.md for instructions.
 */

#if false // Disable compilation

import SwiftUI

struct AIRecipeGeneratorView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var aiService = AIServiceManager.shared
    @State private var mealDescription: String = ""
    @State private var selectedCuisine: String? = nil
    @State private var dietaryRestrictions: Set<String> = []
    @State private var servings: Int = 4
    @State private var maxPrepTime: Int? = nil
    @State private var maxCookTime: Int? = nil
    @State private var showPrepTimeLimit = false
    @State private var showCookTimeLimit = false
    @State private var isGenerating = false
    @State private var generatedRecipe: Recipe?
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingAISettings = false
    
    // Cuisine options
    private let cuisines = [
        "Italian", "Mexican", "Chinese", "Japanese", "Indian", "Thai",
        "French", "Mediterranean", "American", "Korean", "Greek", "Spanish",
        "Vietnamese", "Middle Eastern", "Brazilian", "Caribbean"
    ]
    
    // Common dietary restrictions
    private let dietaryOptions = [
        "Vegetarian", "Vegan", "Gluten-Free", "Dairy-Free",
        "Nut-Free", "Keto", "Paleo", "Low-Carb", "Low-Sodium"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                // AI Provider Status
                Section {
                    HStack {
                        Image(systemName: aiService.currentProvider.icon)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Using \(aiService.currentProvider.rawValue)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            if aiService.currentProvider.requiresAPIKey {
                                if aiService.hasAPIKey(for: aiService.currentProvider) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                        Text("API Key Configured")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                } else {
                                    HStack {
                                        Image(systemName: "exclamationmark.circle.fill")
                                            .foregroundColor(.red)
                                            .font(.caption)
                                        Text("No API Key - Please configure")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            showingAISettings = true
                        } label: {
                            Text("Change")
                                .font(.caption)
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                    }
                } footer: {
                    Text("The AI will generate a complete recipe with ingredients and step-by-step instructions.")
                        .font(.caption)
                }
                
                // Meal Description
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What would you like to make?")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $mealDescription)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        
                        if mealDescription.isEmpty {
                            Text("Examples: \"Creamy pasta with mushrooms\", \"Spicy chicken tacos\", \"Healthy vegetable stir-fry\"")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Meal Description")
                }
                
                // Cuisine Selection
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // "Any" option
                            Button {
                                selectedCuisine = nil
                            } label: {
                                Text("Any")
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCuisine == nil ? themeManager.currentTheme.primaryColor : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedCuisine == nil ? .white : .primary)
                                    .cornerRadius(20)
                            }
                            
                            ForEach(cuisines, id: \.self) { cuisine in
                                Button {
                                    selectedCuisine = cuisine
                                } label: {
                                    Text(cuisine)
                                        .font(.subheadline)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedCuisine == cuisine ? themeManager.currentTheme.primaryColor : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedCuisine == cuisine ? .white : .primary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                } header: {
                    Text("Cuisine Type (Optional)")
                }
                
                // Dietary Restrictions
                Section {
                    ForEach(dietaryOptions, id: \.self) { option in
                        Button {
                            if dietaryRestrictions.contains(option) {
                                dietaryRestrictions.remove(option)
                            } else {
                                dietaryRestrictions.insert(option)
                            }
                        } label: {
                            HStack {
                                Text(option)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if dietaryRestrictions.contains(option) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(themeManager.currentTheme.primaryColor)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Dietary Restrictions (Optional)")
                }
                
                // Recipe Parameters
                Section {
                    // Servings
                    Stepper("Servings: \(servings)", value: $servings, in: 1...12)
                    
                    // Prep Time Limit
                    Toggle("Limit Prep Time", isOn: $showPrepTimeLimit)
                        .onChange(of: showPrepTimeLimit) { _, newValue in
                            if !newValue {
                                maxPrepTime = nil
                            } else {
                                maxPrepTime = 30
                            }
                        }
                    
                    if showPrepTimeLimit {
                        Stepper("Max Prep: \(maxPrepTime ?? 30) min", value: Binding(
                            get: { maxPrepTime ?? 30 },
                            set: { maxPrepTime = $0 }
                        ), in: 5...120, step: 5)
                    }
                    
                    // Cook Time Limit
                    Toggle("Limit Cook Time", isOn: $showCookTimeLimit)
                        .onChange(of: showCookTimeLimit) { _, newValue in
                            if !newValue {
                                maxCookTime = nil
                            } else {
                                maxCookTime = 30
                            }
                        }
                    
                    if showCookTimeLimit {
                        Stepper("Max Cook: \(maxCookTime ?? 30) min", value: Binding(
                            get: { maxCookTime ?? 30 },
                            set: { maxCookTime = $0 }
                        ), in: 5...180, step: 5)
                    }
                } header: {
                    Text("Recipe Parameters")
                }
                
                // Generate Button
                Section {
                    Button {
                        generateRecipe()
                    } label: {
                        HStack {
                            Spacer()
                            
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .padding(.trailing, 8)
                                Text("Generating Recipe...")
                            } else {
                                Image(systemName: "sparkles")
                                Text("Generate Recipe")
                            }
                            
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .background(canGenerate ? themeManager.currentTheme.primaryColor : Color.gray)
                        .cornerRadius(10)
                    }
                    .disabled(!canGenerate || isGenerating)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("AI Recipe Generator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isGenerating)
                }
            }
            .sheet(isPresented: $showingAISettings) {
                AISettingsView()
            }
            .sheet(item: $generatedRecipe) { recipe in
                GeneratedRecipePreviewView(recipe: recipe) { savedRecipe in
                    dataManager.addRecipe(savedRecipe)
                    dismiss()
                }
            }
            .alert("Error Generating Recipe", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
                if !aiService.hasAPIKey(for: aiService.currentProvider) && aiService.currentProvider.requiresAPIKey {
                    Button("Configure API Key") {
                        showingAISettings = true
                    }
                }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var canGenerate: Bool {
        !mealDescription.isEmpty && !isGenerating && 
        (aiService.hasAPIKey(for: aiService.currentProvider) || !aiService.currentProvider.requiresAPIKey)
    }
    
    private func generateRecipe() {
        guard canGenerate else { return }
        
        isGenerating = true
        
        Task {
            do {
                let recipe = try await aiService.generateRecipe(
                    mealDescription: mealDescription,
                    cuisine: selectedCuisine,
                    dietaryRestrictions: Array(dietaryRestrictions),
                    servings: servings,
                    maxPrepTime: maxPrepTime,
                    maxCookTime: maxCookTime
                )
                
                await MainActor.run {
                    generatedRecipe = recipe
                    isGenerating = false
                }
            } catch let error as AIError {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                    showingError = true
                    isGenerating = false
                }
            }
        }
    }
}

// MARK: - Generated Recipe Preview View

struct GeneratedRecipePreviewView: View {
    let recipe: Recipe
    let onSave: (Recipe) -> Void
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var editedRecipe: Recipe
    @State private var isEditing = false
    
    init(recipe: Recipe, onSave: @escaping (Recipe) -> Void) {
        self.recipe = recipe
        self.onSave = onSave
        _editedRecipe = State(initialValue: recipe)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        if isEditing {
                            TextField("Recipe Name", text: $editedRecipe.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            Text(editedRecipe.name)
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        
                        HStack {
                            Label("\(editedRecipe.prepTime) min prep", systemImage: "clock")
                            Label("\(editedRecipe.cookTime) min cook", systemImage: "flame")
                            Label("\(editedRecipe.servings) servings", systemImage: "person.2")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        Text(editedRecipe.category)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(themeManager.currentTheme.primaryColor.opacity(0.2))
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                            .cornerRadius(12)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(themeManager.currentTheme.cardColor)
                    .cornerRadius(12)
                    
                    // Ingredients
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "list.bullet")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                            Text("Ingredients")
                                .font(.headline)
                        }
                        
                        ForEach(editedRecipe.ingredients.indices, id: \.self) { index in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 6))
                                    .foregroundColor(themeManager.currentTheme.accentColor)
                                    .padding(.top, 6)
                                
                                Text(editedRecipe.ingredients[index])
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(themeManager.currentTheme.cardColor)
                    .cornerRadius(12)
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "text.alignleft")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                            Text("Instructions")
                                .font(.headline)
                        }
                        
                        ForEach(editedRecipe.instructions.indices, id: \.self) { index in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 28, height: 28)
                                    .background(themeManager.currentTheme.primaryColor)
                                    .clipShape(Circle())
                                
                                Text(editedRecipe.instructions[index])
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(themeManager.currentTheme.cardColor)
                    .cornerRadius(12)
                    
                    // Notes
                    if let notes = editedRecipe.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                                Text("Notes")
                                    .font(.headline)
                            }
                            
                            Text(notes)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(themeManager.currentTheme.cardColor)
                        .cornerRadius(12)
                    }
                    
                    // AI Attribution
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        Text("Generated by AI")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .padding()
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Preview Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Discard") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(editedRecipe)
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    AIRecipeGeneratorView()
        .environmentObject(DataManager())
        .environmentObject(ThemeManager())
}
#endif // End disabled code

