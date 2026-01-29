//
//  BudgetComponents.swift
//  RealLifeHQ
//
//  Created by Sarah Walker on 1/16/26.
//

import SwiftUI
import Charts

// MARK: - Summary Card

struct SummaryCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color
    var fullWidth: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Text("$\(amount, specifier: "%.2f")")
                .font(.title2.bold())
                .foregroundStyle(color)
        }
        .frame(maxWidth: fullWidth ? .infinity : nil, alignment: .leading)
        .padding()
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Category Type Card

struct CategoryTypeCard: View {
    let type: BudgetCategory.CategoryType
    let budgeted: Double
    let spent: Double
    
    var progress: Double {
        guard budgeted > 0 else { return 0 }
        return min(spent / budgeted, 1.0)
    }
    
    var remaining: Double {
        budgeted - spent
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(type.rawValue)
                    .font(.headline)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("$\(spent, specifier: "%.2f") / $\(budgeted, specifier: "%.2f")")
                        .font(.subheadline.bold())
                    
                    Text("$\(remaining, specifier: "%.2f") left")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            ProgressView(value: progress)
                .tint(type.color)
        }
        .padding()
        .background(type.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    @State private var budgetManager = BudgetManager.shared
    let category: BudgetCategory
    let month: Date
    
    var spent: Double {
        budgetManager.totalSpent(for: category, in: month)
    }
    
    var progress: Double {
        budgetManager.categoryProgress(category, in: month)
    }
    
    var remaining: Double {
        category.limit - spent
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundStyle(category.colorValue)
                    .frame(width: 30)
                
                Text(category.name)
                    .font(.headline)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("$\(spent, specifier: "%.2f")")
                        .font(.subheadline.bold())
                        .foregroundStyle(progress > 1 ? .red : .primary)
                    
                    Text("of $\(category.limit, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            ProgressView(value: min(progress, 1.0))
                .tint(progress > 0.9 ? .red : (progress > 0.7 ? .orange : category.colorValue))
            
            if progress > 1 {
                Text("Over budget by $\(abs(remaining), specifier: "%.2f")")
                    .font(.caption)
                    .foregroundStyle(.red)
            } else {
                Text("$\(remaining, specifier: "%.2f") remaining")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.quaternaryBackground, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Expense Row

struct ExpenseRow: View {
    let expense: Expense
    var showCategory: Bool = false
    
    var body: some View {
        HStack {
            if showCategory {
                Image(systemName: expense.category.icon)
                    .foregroundStyle(expense.category.colorValue)
                    .frame(width: 30)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if showCategory {
                    Text(expense.category.name)
                        .font(.headline)
                }
                
                if !expense.note.isEmpty {
                    Text(expense.note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Text(expense.date, format: .dateTime.month().day().year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("$\(expense.amount, specifier: "%.2f")")
                .font(.headline)
        }
        .padding()
        .background(Color.quaternaryBackground, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Spending Pie Chart

struct SpendingPieChart: View {
    let data: [(category: BudgetCategory, amount: Double)]
    
    var body: some View {
        VStack(spacing: 16) {
            Chart {
                ForEach(data, id: \.category.id) { item in
                    SectorMark(
                        angle: .value("Amount", item.amount),
                        innerRadius: .ratio(0.5),
                        angularInset: 2
                    )
                    .foregroundStyle(item.category.colorValue)
                }
            }
            
            // Legend
            FlowLayout(spacing: 12) {
                ForEach(data, id: \.category.id) { item in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(item.category.colorValue)
                            .frame(width: 12, height: 12)
                        
                        Text(item.category.name)
                            .font(.caption)
                        
                        Text("$\(item.amount, specifier: "%.0f")")
                            .font(.caption.bold())
                    }
                }
            }
        }
    }
}

// MARK: - Monthly Trend Chart

struct MonthlyTrendChart: View {
    let data: [(month: Date, amount: Double)]
    
    var body: some View {
        Chart {
            ForEach(data, id: \.month) { item in
                BarMark(
                    x: .value("Month", item.month, unit: .month),
                    y: .value("Amount", item.amount)
                )
                .foregroundStyle(.blue.gradient)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(date, format: .dateTime.month(.narrow))
                    }
                }
            }
        }
    }
}

// MARK: - Flow Layout (for legend)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    let category = BudgetCategory(name: "Groceries", icon: "cart.fill", color: "FF6B6B", limit: 500, type: .needs)
    CategoryCard(category: category, month: Date())
}
