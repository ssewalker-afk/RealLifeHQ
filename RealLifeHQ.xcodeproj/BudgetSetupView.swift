//
//  BudgetSetupView.swift
//  RealLifeHQ
//
//  Created by Sarah Walker on 1/16/26.
//

import SwiftUI

struct BudgetSetupView: View {
    @Binding var isPresented: Bool
    @State private var budgetManager = BudgetManager.shared
    
    @State private var currentStep = 0
    @State private var monthlyIncome: String = ""
    @State private var needsPercentage: Double = 50
    @State private var wantsPercentage: Double = 30
    @State private var savingsPercentage: Double = 20
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator
                ProgressView(value: Double(currentStep + 1), total: 3)
                    .padding()
                
                TabView(selection: $currentStep) {
                    // Step 1: Income
                    incomeStep
                        .tag(0)
                    
                    // Step 2: Budget Allocation
                    allocationStep
                        .tag(1)
                    
                    // Step 3: Review
                    reviewStep
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Navigation buttons
                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                    
                    Button(currentStep == 2 ? "Complete" : "Next") {
                        if currentStep == 2 {
                            completeSetup()
                        } else {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canProceed)
                }
                .padding()
            }
            .navigationTitle("Budget Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if budgetManager.budgetSetup.isCompleted {
                        Button("Cancel") {
                            isPresented = false
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Step 1: Income
    
    private var incomeStep: some View {
        VStack(spacing: 24) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
            
            Text("What's your monthly take-home pay?")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            
            Text("Enter the amount you receive after taxes and deductions")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Monthly Income")
                    .font(.headline)
                
                HStack {
                    Text("$")
                        .font(.title)
                        .foregroundStyle(.secondary)
                    
                    TextField("0", text: $monthlyIncome)
                        .font(.title)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.plain)
                }
                .padding()
                .background(Color.quaternaryBackground, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Step 2: Allocation
    
    private var allocationStep: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                
                Text("Allocate Your Budget")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                
                Text("We recommend the 50/30/20 rule, but you can customize it")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Needs
                BudgetAllocationRow(
                    title: "Needs",
                    subtitle: "Essentials like housing, food, utilities",
                    percentage: $needsPercentage,
                    color: .red,
                    amount: incomeValue * (needsPercentage / 100)
                )
                
                // Wants
                BudgetAllocationRow(
                    title: "Wants",
                    subtitle: "Entertainment, dining out, hobbies",
                    percentage: $wantsPercentage,
                    color: .orange,
                    amount: incomeValue * (wantsPercentage / 100)
                )
                
                // Savings
                BudgetAllocationRow(
                    title: "Savings",
                    subtitle: "Emergency fund, investments, goals",
                    percentage: $savingsPercentage,
                    color: .green,
                    amount: incomeValue * (savingsPercentage / 100)
                )
                
                // Total
                HStack {
                    Text("Total")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(totalPercentage))%")
                        .font(.headline)
                        .foregroundStyle(totalPercentage == 100 ? .green : .red)
                }
                .padding()
                .background(totalPercentage == 100 ? Color.green.opacity(0.1) : Color.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                
                if totalPercentage != 100 {
                    Text("Total must equal 100%")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Step 3: Review
    
    private var reviewStep: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)
                
                Text("Review Your Budget")
                    .font(.title2.bold())
                
                VStack(spacing: 16) {
                    // Monthly Income
                    HStack {
                        Text("Monthly Income")
                            .font(.headline)
                        Spacer()
                        Text("$\(incomeValue, specifier: "%.2f")")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                    .padding()
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                    
                    // Needs
                    ReviewCategoryCard(
                        title: "Needs",
                        percentage: needsPercentage,
                        amount: incomeValue * (needsPercentage / 100),
                        color: .red
                    )
                    
                    // Wants
                    ReviewCategoryCard(
                        title: "Wants",
                        percentage: wantsPercentage,
                        amount: incomeValue * (wantsPercentage / 100),
                        color: .orange
                    )
                    
                    // Savings
                    ReviewCategoryCard(
                        title: "Savings",
                        percentage: savingsPercentage,
                        amount: incomeValue * (savingsPercentage / 100),
                        color: .green
                    )
                }
                
                Text("You can adjust your budget and categories anytime in settings")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top)
            }
            .padding()
        }
    }
    
    // MARK: - Helpers
    
    private var incomeValue: Double {
        Double(monthlyIncome) ?? 0
    }
    
    private var totalPercentage: Double {
        needsPercentage + wantsPercentage + savingsPercentage
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 0:
            return incomeValue > 0
        case 1:
            return totalPercentage == 100
        case 2:
            return true
        default:
            return false
        }
    }
    
    private func completeSetup() {
        budgetManager.completeBudgetSetup(
            income: incomeValue,
            needs: needsPercentage,
            wants: wantsPercentage,
            savings: savingsPercentage
        )
        isPresented = false
    }
}

// MARK: - Budget Allocation Row

struct BudgetAllocationRow: View {
    let title: String
    let subtitle: String
    @Binding var percentage: Double
    let color: Color
    let amount: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(percentage))%")
                        .font(.title3.bold())
                        .foregroundStyle(color)
                    Text("$\(amount, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Slider(value: $percentage, in: 0...100, step: 5)
                .tint(color)
        }
        .padding()
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Review Category Card

struct ReviewCategoryCard: View {
    let title: String
    let percentage: Double
    let amount: Double
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text("\(Int(percentage))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("$\(amount, specifier: "%.2f")")
                .font(.title3.bold())
                .foregroundStyle(color)
        }
        .padding()
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    BudgetSetupView(isPresented: .constant(true))
}
