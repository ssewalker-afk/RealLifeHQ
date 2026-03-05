import SwiftUI
import UIKit

// MARK: - Journal View
// Write and reflect on your day with Apple Intelligence writing assistance

struct JournalView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    // Check whether the user has an active premium subscription
    @Environment(SubscriptionManager.self) private var subscriptionManager
    // A single enum that describes every sheet JournalView can present.
    // Using one sheet(item:) is far more reliable than chaining multiple
    // sheet(isPresented:) modifiers — chaining caused export to show a blank screen
    // because SwiftUI only reliably activates the *last* modifier in the chain.
    private enum ActiveSheet: Identifiable {
        case addEntry
        case export(URL)
        case paywall

        var id: String {
            switch self {
            case .addEntry:        return "addEntry"
            case .export(let url): return "export-\(url.path)"
            case .paywall:         return "paywall"
            }
        }
    }
    @State private var activeSheet: ActiveSheet?

    // Free users can create up to this many entries before hitting the paywall
    private static let freeEntryLimit = 3

    // MARK: - Entry limit helper

    // Call this instead of setting showingAddEntry directly.
    // It checks whether the user is allowed to add another entry first.
    private func requestAddEntry() {
        if subscriptionManager.isPremium || dataManager.journalEntries.count < Self.freeEntryLimit {
            activeSheet = .addEntry
        } else {
            // Free user is at the limit — show the upgrade screen instead
            activeSheet = .paywall
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                if dataManager.journalEntries.isEmpty {
                    emptyStateView
                } else {
                    if horizontalSizeClass == .regular {
                        // iPad: Grid layout
                        iPadGridLayout
                    } else {
                        // iPhone: List layout
                        journalList
                    }
                }
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !dataManager.journalEntries.isEmpty {
                        Button {
                            // Premium check: free users see the paywall instead of the export sheet
                            if subscriptionManager.isPremium {
                                // Embed the URL directly in the enum case so there's
                                // no separate optional that could cause a blank sheet
                                if let url = JournalPDFExporter.exportAll(entries: sortedEntries) {
                                    activeSheet = .export(url)
                                }
                            } else {
                                activeSheet = .paywall
                            }
                        } label: {
                            // Show a small lock badge over the icon so free users know
                            // this is a premium feature before they even tap it
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                                if !subscriptionManager.isPremium {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.secondary)
                                        .offset(x: 5, y: -5)
                                }
                            }
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        requestAddEntry()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                }
            }
            // Single sheet modifier — drives all three possible sheets
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .addEntry:
                    AddJournalEntryView()
                case .export(let url):
                    ActivityViewController(items: [url])
                case .paywall:
                    PaywallView()
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    // iPad Grid Layout
    private var iPadGridLayout: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20)
            ], spacing: 20) {
                ForEach(sortedEntries) { entry in
                    NavigationLink(destination: JournalDetailView(entry: entry)) {
                        JournalCardView(entry: entry)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()

            // Same usage banner shown below the grid on iPad
            if !subscriptionManager.isPremium {
                entryUsageBanner
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 60))
                .foregroundColor(themeManager.currentTheme.primaryColor.opacity(0.5))
            
            Text("No Journal Entries")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start documenting your thoughts and experiences")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Write Your First Entry") {
                requestAddEntry()
            }
            .buttonStyle(.borderedProminent)
            .tint(themeManager.currentTheme.primaryColor)
        }
    }
    
    private var journalList: some View {
        List {
            ForEach(sortedEntries) { entry in
                NavigationLink(destination: JournalDetailView(entry: entry)) {
                    JournalEntryRow(entry: entry)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        dataManager.deleteJournalEntry(entry)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }

            // Usage banner — only shown to free users so they know their limit.
            // Premium users never see this section.
            if !subscriptionManager.isPremium {
                Section {
                    entryUsageBanner
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // The banner that shows free entry usage.
    // When the limit is reached it becomes a tappable upgrade prompt.
    @ViewBuilder
    private var entryUsageBanner: some View {
        let count = dataManager.journalEntries.count
        let atLimit = count >= Self.freeEntryLimit

        if atLimit {
            // At the limit — show a prominent upgrade call-to-action
            Button {
                activeSheet = .paywall
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "star.circle.fill")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Upgrade for unlimited entries")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        Text("You've used all \(Self.freeEntryLimit) free entries")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        } else {
            // Under the limit — show a quiet progress note
            HStack(spacing: 6) {
                Image(systemName: "lock.fill")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("\(count) of \(Self.freeEntryLimit) free entries used")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .listRowBackground(Color.clear)
        }
    }
    
    private var sortedEntries: [JournalEntry] {
        dataManager.journalEntries.sorted { $0.date > $1.date }
    }

}

// MARK: - Journal Card View (iPad Grid)

struct JournalCardView: View {
    let entry: JournalEntry
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date and mood
            HStack {
                Text(entry.dateString)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let mood = entry.mood {
                    Text(mood.rawValue)
                        .font(.title3)
                }
            }
            
            // Content preview
            Text(entry.content)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
            
            // Tags
            if !entry.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(entry.tags.prefix(5), id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(themeManager.currentTheme.primaryColor.opacity(0.2))
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                                .cornerRadius(6)
                        }
                    }
                }
            }
            
            // Delete button
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .frame(height: 220)
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .alert("Delete Entry", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataManager.deleteJournalEntry(entry)
            }
        } message: {
            Text("Are you sure you want to delete this journal entry? This action cannot be undone.")
        }
    }
}

// MARK: - Journal Entry Row

struct JournalEntryRow: View {
    let entry: JournalEntry
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.dateString)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let mood = entry.mood {
                    Spacer()
                    Text(mood.rawValue)
                        .font(.title3)
                }
            }
            
            Text(entry.content)
                .font(.body)
                .lineLimit(3)
            
            if !entry.tags.isEmpty {
                HStack {
                    ForEach(entry.tags.prefix(3), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(themeManager.currentTheme.primaryColor.opacity(0.2))
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                            .cornerRadius(6)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Journal Entry View

struct AddJournalEntryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var content = ""
    @State private var selectedMood: JournalEntry.Mood? = nil
    @State private var tagText = ""
    @State private var tags: [String] = []
    @State private var date = Date()
    
    // AI Writing Assistant
    @State private var showingTopicSuggestions = false
    @State private var selectedTopic: String? = nil
    
    // Journal topic suggestions
    let topicSuggestions = [
        "Gratitude & Appreciation",
        "Today's Accomplishments",
        "Challenges & Growth",
        "Future Goals",
        "Mindfulness Moment",
        "Relationships & Connections",
        "Self-Reflection",
        "Creative Ideas",
        "Health & Wellness",
        "Learning & Insights",
        "Dreams & Aspirations",
        "Daily Highlights"
    ]
    
    let topicPrompts: [String: String] = [
        "Gratitude & Appreciation": "What am I grateful for today? List three things that brought me joy or comfort.",
        "Today's Accomplishments": "What did I accomplish today, big or small? What am I proud of?",
        "Challenges & Growth": "What challenges did I face today? What did I learn from them?",
        "Future Goals": "What are my goals for tomorrow, this week, or this year? What steps can I take?",
        "Mindfulness Moment": "Describe a moment today when I felt truly present. What did I notice?",
        "Relationships & Connections": "How did I connect with others today? What conversations stood out?",
        "Self-Reflection": "How am I feeling right now? What emotions have I experienced today?",
        "Creative Ideas": "What ideas or inspirations came to me today? What sparked my creativity?",
        "Health & Wellness": "How did I take care of my physical and mental health today?",
        "Learning & Insights": "What new thing did I learn today? What insights did I gain?",
        "Dreams & Aspirations": "What do I dream about for my future? What excites me about tomorrow?",
        "Daily Highlights": "What was the best part of my day? What moment made me smile?"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section("How are you feeling?") {
                    HStack(spacing: 12) {
                        ForEach(JournalEntry.Mood.allCases, id: \.self) { mood in
                            moodButton(mood)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Your thoughts")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            // AI Topic Suggestions
                            Button {
                                showingTopicSuggestions = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "sparkles")
                                    Text("Get Topic Ideas")
                                }
                                .font(.caption)
                                .foregroundColor(themeManager.currentTheme.accentColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(themeManager.currentTheme.accentColor.opacity(0.15))
                                .cornerRadius(8)
                            }
                        }
                        
                        // Show selected topic prompt if any
                        if let topic = selectedTopic, let prompt = topicPrompts[topic] {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(topic)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(themeManager.currentTheme.primaryColor)
                                    
                                    Spacer()
                                    
                                    Button {
                                        selectedTopic = nil
                                        content = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Text(prompt)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(10)
                            .background(themeManager.currentTheme.accentColor.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 200)
                    }
                } header: {
                    Text("What's on your mind?")
                }
                
                Section("Tags (Optional)") {
                    HStack {
                        TextField("Add tag", text: $tagText)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .onSubmit {
                                addTag()
                            }
                        
                        Button {
                            addTag()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                        .disabled(tagText.isEmpty)
                    }
                    
                    if !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    HStack(spacing: 4) {
                                        Text("#\(tag)")
                                        
                                        Button {
                                            tags.removeAll { $0 == tag }
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption)
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(themeManager.currentTheme.primaryColor.opacity(0.2))
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(content.isEmpty)
                }
            }
            .sheet(isPresented: $showingTopicSuggestions) {
                TopicSuggestionsView(
                    topics: topicSuggestions,
                    topicPrompts: topicPrompts,
                    onSelectTopic: { topic, prompt in
                        selectedTopic = topic
                        if content.isEmpty {
                            content = prompt
                        }
                        showingTopicSuggestions = false
                    }
                )
            }
        }
    }
    
    private func moodButton(_ mood: JournalEntry.Mood) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if selectedMood == mood {
                    selectedMood = nil
                } else {
                    selectedMood = mood
                }
            }
        } label: {
            VStack(spacing: 4) {
                Text(mood.rawValue)
                    .font(.title2)
                
                Text(mood.displayName)
                    .font(.caption2)
                    .foregroundColor(selectedMood == mood ? themeManager.currentTheme.primaryColor : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(selectedMood == mood ?
                          themeManager.currentTheme.primaryColor.opacity(0.2) :
                          Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selectedMood == mood ? themeManager.currentTheme.primaryColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func addTag() {
        let trimmed = tagText.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !tags.contains(trimmed) {
            tags.append(trimmed)
            tagText = ""
        }
    }
    
    private func saveEntry() {
        let newEntry = JournalEntry(
            date: date,
            mood: selectedMood,
            content: content,
            tags: tags
        )
        dataManager.addJournalEntry(newEntry)
        dismiss()
    }
}

// MARK: - Topic Suggestions View

struct TopicSuggestionsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    let topics: [String]
    let topicPrompts: [String: String]
    let onSelectTopic: (String, String) -> Void
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("Choose a topic to help you get started with your journal entry")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .listRowBackground(Color.clear)
                }
                
                Section("Writing Prompts") {
                    ForEach(topics, id: \.self) { topic in
                        Button {
                            if let prompt = topicPrompts[topic] {
                                onSelectTopic(topic, prompt)
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Image(systemName: topicIcon(for: topic))
                                        .foregroundColor(themeManager.currentTheme.primaryColor)
                                        .frame(width: 24)
                                    
                                    Text(topic)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                if let prompt = topicPrompts[topic] {
                                    Text(prompt)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                        .padding(.leading, 24)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Journal Topics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func topicIcon(for topic: String) -> String {
        switch topic {
        case "Gratitude & Appreciation": return "heart.fill"
        case "Today's Accomplishments": return "star.fill"
        case "Challenges & Growth": return "chart.line.uptrend.xyaxis"
        case "Future Goals": return "target"
        case "Mindfulness Moment": return "leaf.fill"
        case "Relationships & Connections": return "person.2.fill"
        case "Self-Reflection": return "mirror"
        case "Creative Ideas": return "lightbulb.fill"
        case "Health & Wellness": return "heart.circle.fill"
        case "Learning & Insights": return "brain.head.profile"
        case "Dreams & Aspirations": return "sparkles"
        case "Daily Highlights": return "sun.max.fill"
        default: return "pencil"
        }
    }
}

// MARK: - Journal Detail View

struct JournalDetailView: View {
    let entry: JournalEntry
    @EnvironmentObject var themeManager: ThemeManager
    // Check whether the user has an active premium subscription
    @Environment(SubscriptionManager.self) private var subscriptionManager
    // Single enum — same fix as JournalView, prevents blank screen from
    // chaining two sheet(isPresented:) modifiers on the same view.
    private enum ActiveSheet: Identifiable {
        case export(URL)
        case paywall

        var id: String {
            switch self {
            case .export(let url): return "export-\(url.path)"
            case .paywall:         return "paywall"
            }
        }
    }
    @State private var activeSheet: ActiveSheet?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Date and Mood
                HStack {
                    VStack(alignment: .leading) {
                        Text(entry.dateString)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        if let mood = entry.mood {
                            HStack {
                                Text(mood.rawValue)
                                Text(mood.displayName)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(themeManager.currentTheme.cardColor)
                .cornerRadius(12)
                
                // Content
                Text(entry.content)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(themeManager.currentTheme.cardColor)
                    .cornerRadius(12)
                
                // Tags
                if !entry.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        FlexibleView(
                            data: entry.tags,
                            spacing: 8,
                            alignment: .leading
                        ) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(themeManager.currentTheme.primaryColor.opacity(0.2))
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(themeManager.currentTheme.cardColor)
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle("Journal Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Premium check: free users see the paywall instead of the export sheet
                    if subscriptionManager.isPremium {
                        if let url = JournalPDFExporter.exportSingle(entry) {
                            activeSheet = .export(url)
                        }
                    } else {
                        activeSheet = .paywall
                    }
                } label: {
                    // Lock badge over the icon lets free users know it's premium
                    // before they tap — same pattern used throughout the app
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        if !subscriptionManager.isPremium {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.secondary)
                                .offset(x: 5, y: -5)
                        }
                    }
                }
            }
        }
        // Single sheet modifier drives both possible sheets
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .export(let url):
                ActivityViewController(items: [url])
            case .paywall:
                PaywallView()
            }
        }
    }
}

// MARK: - Flexible View for Tags
// This creates a flowing layout for tags

struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    
    @State private var availableWidth: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: alignment, vertical: .center)) {
            Color.clear
                .frame(height: 1)
                .readSize { size in
                    availableWidth = size.width
                }
            
            FlexibleViewContent(
                availableWidth: availableWidth,
                data: data,
                spacing: spacing,
                alignment: alignment,
                content: content
            )
        }
    }
}

struct FlexibleViewContent<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let availableWidth: CGFloat
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    
    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(computeRows(), id: \.self) { rowElements in
                HStack(spacing: spacing) {
                    ForEach(rowElements, id: \.self) { element in
                        content(element)
                    }
                }
            }
        }
    }
    
    func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRow = 0
        var remainingWidth = availableWidth
        
        for element in data {
            let elementWidth = element.hashValue % 100 + 50 // Simplified width calculation
            
            if remainingWidth - CGFloat(elementWidth) >= 0 {
                rows[currentRow].append(element)
            } else {
                currentRow += 1
                rows.append([element])
                remainingWidth = availableWidth
            }
            
            remainingWidth -= CGFloat(elementWidth)
        }
        
        return rows
    }
}

// Helper to read view size
extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

// MARK: - Journal PDF Exporter
// Renders journal entries to a printable PDF file using UIGraphicsPDFRenderer.
// Returns a temp file URL that ActivityViewController passes to the iOS share sheet,
// which gives the user options to Print, Mail, Message, AirDrop, or Save to Files.

struct JournalPDFExporter {

    private static let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter
    private static let margin: CGFloat = 56
    private static let bottomPad: CGFloat = 56
    private static var usableWidth: CGFloat { pageRect.width - margin * 2 }
    private static var pageBottom: CGFloat { pageRect.height - bottomPad }

    // Export all entries to a single PDF
    static func exportAll(entries: [JournalEntry]) -> URL? {
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            var y: CGFloat = margin
            drawDocumentHeader(entryCount: entries.count, y: &y)
            for (i, entry) in entries.enumerated() {
                if i > 0 {
                    if y + 30 > pageBottom { ctx.beginPage(); y = margin }
                    UIColor.systemGray5.setFill()
                    UIRectFill(CGRect(x: margin, y: y, width: usableWidth, height: 0.5))
                    y += 20
                }
                drawEntry(entry, y: &y, ctx: ctx)
            }
        }
        return writeTemp(data: data, name: "My-Journal-Export")
    }

    // Export a single entry to its own PDF
    static func exportSingle(_ entry: JournalEntry) -> URL? {
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            var y: CGFloat = margin
            drawEntry(entry, y: &y, ctx: ctx)
        }
        return writeTemp(data: data, name: "Journal-Entry")
    }

    // MARK: - Section drawing

    private static func drawDocumentHeader(entryCount: Int, y: inout CGFloat) {
        y = drawText("RealLife HQ", y: y, font: .systemFont(ofSize: 10, weight: .medium), color: .darkGray)
        y += 6
        y = drawText("My Journal", y: y, font: .systemFont(ofSize: 28, weight: .bold), color: .black)
        y += 4
        let sub = "Exported \(Date().formatted(date: .long, time: .omitted))  ·  \(entryCount) \(entryCount == 1 ? "entry" : "entries")"
        y = drawText(sub, y: y, font: .systemFont(ofSize: 11), color: .darkGray)
        y += 16
        UIColor.systemGray3.setFill()
        UIRectFill(CGRect(x: margin, y: y, width: usableWidth, height: 1.5))
        y += 20
    }

    private static func drawEntry(_ entry: JournalEntry, y: inout CGFloat, ctx: UIGraphicsPDFRendererContext) {
        // Ensure enough room for at least the date header before drawing
        if y + 50 > pageBottom { ctx.beginPage(); y = margin }

        y = drawText(entry.date.formatted(date: .long, time: .omitted),
                     y: y, font: .systemFont(ofSize: 16, weight: .semibold), color: .black)
        y += 2

        if let mood = entry.mood {
            y = drawText("\(mood.rawValue)  \(mood.displayName)",
                         y: y, font: .systemFont(ofSize: 12), color: .darkGray)
            y += 2
        }

        if !entry.tags.isEmpty {
            let tagStr = entry.tags.map { "#\($0)" }.joined(separator: "  ")
            y = drawText(tagStr, y: y, font: .italicSystemFont(ofSize: 11), color: .systemBlue)
            y += 2
        }

        y += 8
        drawContent(entry.content, y: &y, ctx: ctx)
    }

    // Draws body text, inserting page breaks when a paragraph would overflow
    private static func drawContent(_ text: String, y: inout CGFloat, ctx: UIGraphicsPDFRendererContext) {
        let font = UIFont.systemFont(ofSize: 13)
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.black]

        let totalH = ceil((text as NSString).boundingRect(
            with: CGSize(width: usableWidth, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin, attributes: attrs, context: nil).height)

        if y + totalH <= pageBottom {
            // Entire content fits — draw in one shot
            (text as NSString).draw(
                in: CGRect(x: margin, y: y, width: usableWidth, height: totalH),
                withAttributes: attrs)
            y += totalH
            return
        }

        // Content is long — draw paragraph by paragraph so we can add page breaks
        for paragraph in text.components(separatedBy: "\n") {
            let line = paragraph.isEmpty ? " " : paragraph
            let lineH = ceil((line as NSString).boundingRect(
                with: CGSize(width: usableWidth, height: .greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin, attributes: attrs, context: nil).height)
            if y + lineH > pageBottom { ctx.beginPage(); y = margin }
            (line as NSString).draw(
                in: CGRect(x: margin, y: y, width: usableWidth, height: lineH),
                withAttributes: attrs)
            y += lineH + 2
        }
    }

    // MARK: - Primitives

    @discardableResult
    private static func drawText(_ text: String, y: CGFloat, font: UIFont, color: UIColor) -> CGFloat {
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let h = ceil((text as NSString).boundingRect(
            with: CGSize(width: usableWidth, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin, attributes: attrs, context: nil).height)
        (text as NSString).draw(in: CGRect(x: margin, y: y, width: usableWidth, height: h), withAttributes: attrs)
        return y + h
    }

    private static func writeTemp(data: Data, name: String) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(name).pdf")
        try? data.write(to: url)
        return url
    }
}

// MARK: - Share Sheet

struct ActivityViewController: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
