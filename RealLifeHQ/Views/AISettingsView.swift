import SwiftUI

// MARK: - AI Settings View (DEPRECATED - For Reference Only)
// This file has been deprecated. External AI integrations have been removed.
// See APPLE_INTELLIGENCE_NOTES.md for information about using Apple Intelligence.

/*
 
 DEPRECATION NOTICE
 ==================
 
 This AI Settings View has been removed from the active codebase.
 External AI providers (OpenAI, Anthropic, Google) are no longer integrated.
 
 WHY REMOVED?
 - Privacy: External APIs send user data to third-party servers
 - Cost: API calls require payment
 - Complexity: Multiple providers increase maintenance
 - Apple Intelligence: iOS 18.1+ provides free, private, on-device AI
 
 WHAT'S NEXT?
 - Use Apple Intelligence when available (iOS 18.1+)
 - Continue with manual recipe entry
 - Focus on privacy and simplicity
 
 See APPLE_INTELLIGENCE_NOTES.md for integration guidance.
 
 */

// MARK: - Archive of Previous Implementation

// This code is kept for reference only and should not be compiled into the app.
// Remove this file from your target's "Compile Sources" build phase.

#if false // Disable compilation

struct AISettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    private let aiService = AIServiceManager.shared
    @State private var selectedProviderForKey: AIServiceManager.AIProvider?
    @State private var showingDeleteConfirmation = false
    @State private var providerToDelete: AIServiceManager.AIProvider?
    
    var body: some View {
        List {
            // Current provider section
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: aiService.currentProvider.icon)
                            .font(.title2)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current AI Provider")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(aiService.currentProvider.rawValue)
                                .font(.headline)
                        }
                        
                        Spacer()
                        
                        if aiService.currentProvider.requiresAPIKey {
                            if aiService.hasAPIKey(for: aiService.currentProvider) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            } header: {
                Text("Active Provider")
            } footer: {
                if aiService.currentProvider.requiresAPIKey && !aiService.hasAPIKey(for: aiService.currentProvider) {
                    Text("⚠️ Please add an API key to use this provider")
                        .foregroundColor(.orange)
                }
            }
            
            // Apple Intelligence section (currently unavailable)
            Section {
                HStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .frame(width: 40)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Apple Intelligence")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                            Text("Not Available")
                                .font(.caption)
                        }
                        .foregroundColor(.red)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 8)
            } header: {
                Text("On-Device AI")
            } footer: {
                Text("Apple Intelligence is not available on this device or is not enabled. Enable it in Settings > Apple Intelligence & Siri.")
            }
            
            // External providers section
            Section {
                ForEach([AIServiceManager.AIProvider.openAI, .anthropic, .google], id: \.self) { provider in
                    HStack(spacing: 16) {
                        Image(systemName: provider.icon)
                            .font(.title2)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                            .frame(width: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(provider.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            if aiService.hasAPIKey(for: provider) {
                                HStack(spacing: 4) {
                                    Image(systemName: "key.fill")
                                        .font(.caption)
                                    Text("API Key Configured")
                                        .font(.caption)
                                }
                                .foregroundColor(.green)
                            } else {
                                HStack(spacing: 4) {
                                    Image(systemName: "key")
                                        .font(.caption)
                                    Text("No API Key")
                                        .font(.caption)
                                }
                                .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Menu {
                            if aiService.hasAPIKey(for: provider) {
                                Button {
                                    aiService.currentProvider = provider
                                } label: {
                                    Label("Use This Provider", systemImage: "checkmark.circle")
                                }
                                .disabled(aiService.currentProvider == provider)
                                
                                Divider()
                            }
                            
                            Button {
                                selectedProviderForKey = provider
                            } label: {
                                Label(
                                    aiService.hasAPIKey(for: provider) ? "Update API Key" : "Add API Key",
                                    systemImage: "key.fill"
                                )
                            }
                            
                            if aiService.hasAPIKey(for: provider) {
                                Divider()
                                
                                Button(role: .destructive) {
                                    providerToDelete = provider
                                    showingDeleteConfirmation = true
                                } label: {
                                    Label("Remove API Key", systemImage: "trash")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                    }
                    .padding(.vertical, 8)
                }
            } header: {
                Text("External AI Services")
            } footer: {
                Text("External services require an API key from the provider's website. They may incur costs based on usage.")
            }
            
            // Information section
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    InfoRow(
                        icon: "shield.fill",
                        title: "Private & Secure",
                        description: "API keys are stored securely in the iOS Keychain"
                    )
                    
                    Divider()
                    
                    InfoRow(
                        icon: "dollarsign.circle.fill",
                        title: "Pay As You Go",
                        description: "External providers charge per API request. Check their pricing pages for details"
                    )
                    
                    Divider()
                    
                    InfoRow(
                        icon: "sparkles",
                        title: "Flexible Choice",
                        description: "Switch between providers anytime based on your needs"
                    )
                }
                .padding(.vertical, 8)
            } header: {
                Text("About AI Integration")
            }
            
            // Provider links section
            Section {
                Link(destination: URL(string: "https://platform.openai.com/api-keys")!) {
                    HStack {
                        Label("Get OpenAI API Key", systemImage: "arrow.up.forward.square")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Link(destination: URL(string: "https://console.anthropic.com/settings/keys")!) {
                    HStack {
                        Label("Get Anthropic API Key", systemImage: "arrow.up.forward.square")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Link(destination: URL(string: "https://aistudio.google.com/app/apikey")!) {
                    HStack {
                        Label("Get Google API Key", systemImage: "arrow.up.forward.square")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("Get API Keys")
            }
        }
        .navigationTitle("AI Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedProviderForKey) { provider in
            AddAPIKeyView(provider: provider)
                .environmentObject(themeManager)
        }
        .alert("Remove API Key", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                if let provider = providerToDelete {
                    aiService.deleteAPIKey(for: provider)
                    if aiService.currentProvider == provider {
                        // Switch to another provider that has an API key, or default to OpenAI
                        let providersWithKeys = AIServiceManager.AIProvider.allCases.filter { aiService.hasAPIKey(for: $0) && $0 != provider }
                        aiService.currentProvider = providersWithKeys.first ?? .openAI
                    }
                }
            }
        } message: {
            if let provider = providerToDelete {
                Text("Are you sure you want to remove the API key for \(provider.rawValue)?")
            }
        }
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Add API Key View

struct AddAPIKeyView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    let provider: AIServiceManager.AIProvider
    
    @State private var apiKey = ""
    @State private var isSecureEntry = true
    @State private var showingSuccessAlert = false
    @State private var isValidating = false
    @State private var validationError: String?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: provider.icon)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        
                        Text(provider.rawValue)
                            .font(.headline)
                    }
                } header: {
                    Text("Provider")
                }
                
                Section {
                    HStack {
                        if isSecureEntry {
                            SecureField("Paste your API key here", text: $apiKey)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        } else {
                            TextField("Paste your API key here", text: $apiKey)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                        
                        Button {
                            isSecureEntry.toggle()
                        } label: {
                            Image(systemName: isSecureEntry ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("API Key")
                } footer: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your API key is stored securely in the iOS Keychain and never shared.")
                        
                        Text("Get your API key from the provider's website.")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Validation error
                if let error = validationError {
                    Section {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "shield.fill")
                                .foregroundColor(.green)
                            Text("Encrypted storage")
                                .font(.caption)
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.green)
                            Text("Protected by device passcode")
                                .font(.caption)
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "eye.slash.fill")
                                .foregroundColor(.green)
                            Text("Never leaves your device")
                                .font(.caption)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Security")
                }
                
                // How to get API key
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Steps to get your API key:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        switch provider {
                        case .openAI:
                            VStack(alignment: .leading, spacing: 4) {
                                Text("1. Visit platform.openai.com")
                                Text("2. Create an account or sign in")
                                Text("3. Go to API Keys section")
                                Text("4. Create a new secret key")
                                Text("5. Copy and paste it here")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                            Link(destination: URL(string: "https://platform.openai.com/api-keys")!) {
                                HStack {
                                    Text("Open OpenAI Platform")
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                }
                                .font(.caption)
                            }
                            .padding(.top, 4)
                            
                        case .anthropic:
                            VStack(alignment: .leading, spacing: 4) {
                                Text("1. Visit console.anthropic.com")
                                Text("2. Create an account or sign in")
                                Text("3. Go to Settings > API Keys")
                                Text("4. Create a new key")
                                Text("5. Copy and paste it here")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                            Link(destination: URL(string: "https://console.anthropic.com/settings/keys")!) {
                                HStack {
                                    Text("Open Anthropic Console")
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                }
                                .font(.caption)
                            }
                            .padding(.top, 4)
                            
                        case .google:
                            VStack(alignment: .leading, spacing: 4) {
                                Text("1. Visit aistudio.google.com")
                                Text("2. Sign in with your Google account")
                                Text("3. Go to Get API Key")
                                Text("4. Create or use existing key")
                                Text("5. Copy and paste it here")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                            Link(destination: URL(string: "https://aistudio.google.com/app/apikey")!) {
                                HStack {
                                    Text("Open Google AI Studio")
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                }
                                .font(.caption)
                            }
                            .padding(.top, 4)
                        }
                    }
                } header: {
                    Text("How to Get Your API Key")
                }
            }
            .navigationTitle("Add API Key")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAPIKey()
                    }
                    .disabled(apiKey.isEmpty || isValidating)
                }
            }
            .alert("API Key Saved", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your API key has been securely saved. You can now use \(provider.rawValue) to generate recipes and meal plans.")
            }
            .overlay {
                if isValidating {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Validating API Key...")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(32)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                    }
                }
            }
        }
    }
    
    private func saveAPIKey() {
        validationError = nil
        isValidating = true
        
        Task {
            // Validate the API key by making a simple test request
            let isValid = await validateAPIKey()
            
            await MainActor.run {
                isValidating = false
                
                if isValid {
                    AIServiceManager.shared.saveAPIKey(apiKey, for: provider)
                    showingSuccessAlert = true
                } else {
                    validationError = "The API key appears to be invalid. Please check and try again."
                }
            }
        }
    }
    
    private func validateAPIKey() async -> Bool {
        // Simple validation - just try to make a minimal request
        // This is a basic implementation - you might want to add more robust checking
        
        switch provider {
        case .openAI:
            return await validateOpenAIKey()
        case .anthropic:
            return await validateAnthropicKey()
        case .google:
            return await validateGoogleKey()
        }
    }
    
    private func validateOpenAIKey() async -> Bool {
        // Make a simple request to verify the key works
        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": [["role": "user", "content": "test"]],
            "max_tokens": 5
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody),
              let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = 10
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            return false
        }
    }
    
    private func validateAnthropicKey() async -> Bool {
        let requestBody: [String: Any] = [
            "model": "claude-3-5-sonnet-20241022",
            "max_tokens": 5,
            "messages": [["role": "user", "content": "test"]]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody),
              let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = 10
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            return false
        }
    }
    
    private func validateGoogleKey() async -> Bool {
        let requestBody: [String: Any] = [
            "contents": [
                ["parts": [["text": "test"]]]
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody),
              let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=\(apiKey)") else {
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = 10
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            return false
        }
    }
}

#Preview {
    NavigationStack {
        AISettingsView()
            .environmentObject(ThemeManager())
    }
}
#endif // End disabled code

