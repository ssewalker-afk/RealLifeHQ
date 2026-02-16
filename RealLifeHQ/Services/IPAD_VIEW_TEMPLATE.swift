// MARK: - iPad Optimization Template
// Use this template to add iPad optimization to any view in your app

import SwiftUI

// Example 1: List-based View with Grid Support
struct ExampleListView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if horizontalSizeClass == .regular {
                    // iPad: 2-column grid
                    iPadGridLayout
                } else {
                    // iPhone: vertical list
                    iPhoneListLayout
                }
            }
            .navigationTitle("Example")
        }
    }
    
    // iPhone Layout
    private var iPhoneListLayout: some View {
        VStack(spacing: 16) {
            ForEach(sampleItems) { item in
                ItemCard(item: item)
            }
        }
        .padding()
    }
    
    // iPad Layout
    private var iPadGridLayout: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 20),
            GridItem(.flexible(), spacing: 20)
        ], spacing: 20) {
            ForEach(sampleItems) { item in
                ItemCard(item: item)
            }
        }
        .padding()
    }
    
    private var sampleItems: [SampleItem] {
        // Your data array
        []
    }
}

// Example 2: Detail View with Adaptive Width
struct ExampleDetailView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Your content here
                Text("Detail Content")
            }
            .padding()
            .frame(maxWidth: horizontalSizeClass == .regular ? 700 : .infinity)
            // ↑ Limit width on iPad for better readability
            .frame(maxWidth: .infinity) // Center the content
        }
    }
}

// Example 3: Form/Settings View with Sections
struct ExampleFormView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Settings") {
                    Toggle("Example Setting", isOn: .constant(true))
                }
            }
            .navigationTitle("Settings")
            // Form automatically adapts to iPad with wider layout
            .formStyle(.grouped)
        }
    }
}

// Example 4: Dashboard with Mixed Widget Sizes
struct ExampleDashboardView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ScrollView {
            if horizontalSizeClass == .regular {
                iPadDashboard
            } else {
                iPhoneDashboard
            }
        }
    }
    
    private var iPhoneDashboard: some View {
        VStack(spacing: 16) {
            WidgetCard(title: "Widget 1")
            WidgetCard(title: "Widget 2")
            WidgetCard(title: "Widget 3")
        }
        .padding()
    }
    
    private var iPadDashboard: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 20),
            GridItem(.flexible(), spacing: 20)
        ], spacing: 20) {
            WidgetCard(title: "Widget 1")
            WidgetCard(title: "Widget 2")
            
            // Full-width widget
            WidgetCard(title: "Widget 3")
                .gridCellColumns(2) // Spans both columns
            
            WidgetCard(title: "Widget 4")
            WidgetCard(title: "Widget 5")
        }
        .padding()
    }
}

// Example 5: Calendar/Grid View with Adaptive Columns
struct ExampleCalendarView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    private var columns: [GridItem] {
        if horizontalSizeClass == .regular {
            // iPad: 4 columns
            return Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
        } else {
            // iPhone: 2 columns
            return Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<20) { index in
                    CalendarCell(day: index + 1)
                }
            }
            .padding()
        }
    }
}

// MARK: - Helper Views

struct ItemCard: View {
    let item: SampleItem
    
    var body: some View {
        VStack {
            Text(item.title)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct WidgetCard: View {
    let title: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
            Text("Widget content here")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .padding()
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct CalendarCell: View {
    let day: Int
    
    var body: some View {
        Text("\(day)")
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct SampleItem: Identifiable {
    let id = UUID()
    let title: String
}

// MARK: - Responsive Sizing Guide

/*
 
 RESPONSIVE SIZING TIPS:
 
 1. Use Size Classes:
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    - .regular = iPad (or large iPhone in landscape)
    - .compact = iPhone (portrait)
 
 2. Grid Layouts:
    iPhone: 1-2 columns
    iPad Portrait: 2-3 columns
    iPad Landscape: 3-4 columns
 
 3. Maximum Width:
    .frame(maxWidth: horizontalSizeClass == .regular ? 700 : .infinity)
    - Prevents content from being too wide on iPad
    - Good for reading text, forms, detail views
 
 4. Spacing:
    iPhone: 12-16 points
    iPad: 16-24 points
 
 5. Font Sizes:
    Let SwiftUI handle with Dynamic Type
    Or use .font(.system(.body, design: .default))
 
 6. Grid Cell Spanning:
    .gridCellColumns(2) // Span 2 columns
    Great for featured items or wide widgets
 
 7. Navigation:
    - Use NavigationStack for simple hierarchical navigation
    - Use NavigationSplitView for iPad sidebar experiences
    - TabView for primary navigation
 
 8. Padding:
    iPhone: 16-20 points
    iPad: 24-32 points
 
 9. Card Sizes:
    iPhone: Full width
    iPad: Fixed or flexible in grid
 
 10. Modern Styling:
     - Use .clipShape(RoundedRectangle(cornerRadius: X)) instead of .cornerRadius()
     - Use .foregroundStyle() instead of .foregroundColor()
     - These provide better performance and semantic color support
 
 */

// MARK: - Quick Reference

/*
 
 COMMON PATTERNS:
 
 1. Adaptive Grid:
 LazyVGrid(columns: [
     GridItem(.flexible()),
     GridItem(.flexible())
 ])
 
 2. Conditional Layout:
 if horizontalSizeClass == .regular {
     iPadLayout
 } else {
     iPhoneLayout
 }
 
 3. Adaptive Columns:
 private var columns: [GridItem] {
     Array(repeating: GridItem(.flexible()), 
           count: horizontalSizeClass == .regular ? 3 : 2)
 }
 
 4. Maximum Width:
 .frame(maxWidth: horizontalSizeClass == .regular ? 600 : .infinity)
 
 5. Form Style:
 .formStyle(.grouped) // Or use .automatic for platform default
 
 */
