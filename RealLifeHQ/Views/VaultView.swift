import SwiftUI
import LocalAuthentication

// MARK: - Vault View
// Securely store passwords and sensitive information

struct VaultView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isUnlocked = false
    @State private var showingAddItem = false
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            if isUnlocked {
                vaultContent
            } else {
                lockScreen
            }
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle("Vault")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if dataManager.settings.biometricEnabled {
                authenticateWithBiometrics()
            }
        }
    }
    
    // MARK: - Lock Screen
    
    private var lockScreen: some View {
        VStack(spacing: 30) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundColor(themeManager.currentTheme.primaryColor)
            
            Text("Vault Locked")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Your sensitive information is protected")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                authenticateWithBiometrics()
            } label: {
                Label("Unlock with Face ID", systemImage: "faceid")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(themeManager.currentTheme.primaryColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Vault Content
    
    private var vaultContent: some View {
        ZStack {
            if filteredItems.isEmpty {
                emptyStateView
            } else {
                itemsList
            }
        }
        .searchable(text: $searchText, prompt: "Search vault")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddItem = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddVaultItemView()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "key.fill")
                .font(.system(size: 60))
                .foregroundColor(themeManager.currentTheme.primaryColor.opacity(0.5))
            
            Text("No Items in Vault")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Store passwords and sensitive information securely")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Add Your First Item") {
                showingAddItem = true
            }
            .buttonStyle(.borderedProminent)
            .tint(themeManager.currentTheme.primaryColor)
        }
    }
    
    private var itemsList: some View {
        List {
            ForEach(filteredItems) { item in
                NavigationLink(destination: VaultItemDetailView(item: item)) {
                    VaultItemRow(item: item)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        dataManager.deleteVaultItem(item)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var filteredItems: [VaultItem] {
        if searchText.isEmpty {
            return dataManager.vaultItems
        } else {
            return dataManager.vaultItems.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Biometric Authentication
    
    private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock your vault to access sensitive information"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        isUnlocked = true
                    }
                }
            }
        } else {
            // No biometrics available, unlock anyway for demo
            isUnlocked = true
        }
    }
}

// MARK: - Vault Item Row

struct VaultItemRow: View {
    let item: VaultItem
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Image(systemName: item.category.icon)
                .foregroundColor(themeManager.currentTheme.primaryColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    if let username = item.username {
                        Text(username)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Show photo indicator if image is attached
                    if item.imageData != nil {
                        HStack(spacing: 2) {
                            Image(systemName: "photo.fill")
                                .font(.caption2)
                            Text("Photo")
                                .font(.caption2)
                        }
                        .foregroundColor(themeManager.currentTheme.accentColor)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Vault Item Detail View

struct VaultItemDetailView: View {
    let item: VaultItem
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showPassword = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Title and Category
                VStack(spacing: 8) {
                    Image(systemName: item.category.icon)
                        .font(.system(size: 50))
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    
                    Text(item.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(item.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(themeManager.currentTheme.cardColor)
                .cornerRadius(12)
                
                // Attached Photo (if exists)
                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Attached Photo")
                            .font(.headline)
                        
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(themeManager.currentTheme.cardColor)
                    .cornerRadius(12)
                }
                
                // Details
                VStack(alignment: .leading, spacing: 16) {
                    if let username = item.username {
                        DetailRow(label: "Username", value: username, isCopyable: true)
                    }
                    
                    if let password = item.password {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Password")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(showPassword ? password : String(repeating: "•", count: 12))
                                    .font(.body)
                            }
                            
                            Spacer()
                            
                            Button {
                                showPassword.toggle()
                            } label: {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                            }
                            
                            Button {
                                UIPasteboard.general.string = password
                            } label: {
                                Image(systemName: "doc.on.doc.fill")
                                    .foregroundColor(themeManager.currentTheme.accentColor)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    if let url = item.url {
                        DetailRow(label: "Website", value: url, isCopyable: true)
                    }
                    
                    if let notes = item.notes {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(notes)
                                .font(.body)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(themeManager.currentTheme.cardColor)
                .cornerRadius(12)
            }
            .padding()
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    let isCopyable: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
            }
            
            Spacer()
            
            if isCopyable {
                Button {
                    UIPasteboard.general.string = value
                } label: {
                    Image(systemName: "doc.on.doc.fill")
                        .foregroundColor(themeManager.currentTheme.accentColor)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Add Vault Item View

struct AddVaultItemView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var title = ""
    @State private var category: VaultItem.VaultCategory = .login
    @State private var username = ""
    @State private var password = ""
    @State private var url = ""
    @State private var notes = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $title)
                    
                    Picker("Category", selection: $category) {
                        ForEach(VaultItem.VaultCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                }
                
                Section("Details") {
                    TextField("Username", text: $username)
                        .textContentType(.username)
                    
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                    
                    TextField("Website URL", text: $url)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                }
                
                Section("Attachment (Optional)") {
                    if let image = selectedImage {
                        VStack(spacing: 12) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(8)
                            
                            Button(role: .destructive) {
                                selectedImage = nil
                            } label: {
                                Label("Remove Photo", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    } else {
                        Button {
                            showingImagePicker = true
                        } label: {
                            Label("Attach Photo", systemImage: "photo.on.rectangle.angled")
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("New Vault Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }
    
    private func saveItem() {
        // Convert UIImage to Data if image is selected
        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        let newItem = VaultItem(
            title: title,
            username: username.isEmpty ? nil : username,
            password: password.isEmpty ? nil : password,
            url: url.isEmpty ? nil : url,
            notes: notes.isEmpty ? nil : notes,
            category: category,
            imageData: imageData
        )
        
        dataManager.addVaultItem(newItem)
        dismiss()
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

