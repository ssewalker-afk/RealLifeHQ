import SwiftUI

// MARK: - Journal View
// Write and reflect on your day with Apple Intelligence writing assistance

struct JournalView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingAddEntry = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if dataManager.journalEntries.isEmpty {
                    emptyStateView
                } else {
                    journalList
                }
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddEntry = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddJournalEntryView()
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
                showingAddEntry = true
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
        }
        .listStyle(.insetGrouped)
    }
    
    private var sortedEntries: [JournalEntry] {
        dataManager.journalEntries.sorted { $0.date > $1.date }
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
