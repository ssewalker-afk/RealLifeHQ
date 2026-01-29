//
//  WebContentView.swift
//  RealLifeHQ
//
//  Created by Sarah Walker on 1/10/26.
//

import SwiftUI

/// Main view that displays the Base44 website with subscription integration
struct WebContentView: View {
    @State private var storeManager = StoreManager.shared
    @State private var showSubscriptionView = false
    @State private var isLoading = false
    @State private var currentURL: URL?
    
    var websiteURL: URL {
        URL(string: AppConfiguration.websiteURL)!
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main web content
                if storeManager.isSubscribed {
                    // Show full website for premium users
                    WebView(
                        url: websiteURL,
                        isLoading: $isLoading,
                        onNavigationChange: { url in
                            currentURL = url
                        }
                    )
                    .ignoresSafeArea(edges: .bottom)
                } else {
                    // Show limited or paywall for free users
                    freeUserView
                }
                
                // Loading indicator
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("RealLifeHQ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if !storeManager.isSubscribed {
                        Button {
                            showSubscriptionView = true
                        } label: {
                            Label("Premium", systemImage: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                    }
                }
                
                // Subscription status badge
                ToolbarItem(placement: .topBarLeading) {
                    subscriptionBadge
                }
            }
            .sheet(isPresented: $showSubscriptionView) {
                SubscriptionView()
            }
        }
    }
    
    // MARK: - Subscription Badge
    
    @ViewBuilder
    private var subscriptionBadge: some View {
        switch storeManager.subscriptionStatus {
        case .subscribed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .imageScale(.medium)
            
        case .inFreeTrial:
            Image(systemName: "gift.fill")
                .foregroundStyle(.blue)
                .imageScale(.medium)
            
        case .notSubscribed, .expired:
            EmptyView()
        }
    }
    
    // MARK: - Free User View
    
    private var freeUserView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App icon/logo
            Image(systemName: "globe")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)
            
            // Title
            VStack(spacing: 12) {
                Text("Welcome to RealLifeHQ")
                    .font(.largeTitle.bold())
                
                Text("Subscribe to unlock full access")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Features preview
            VStack(alignment: .leading, spacing: 16) {
                FeaturePreview(icon: "star.fill", title: "Full Website Access", description: "Browse all content and features")
                FeaturePreview(icon: "lock.open.fill", title: "Premium Content", description: "Access exclusive materials")
                FeaturePreview(icon: "arrow.triangle.2.circlepath", title: "Sync Everywhere", description: "Access from any device")
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
            
            // Call to action
            Button {
                showSubscriptionView = true
            } label: {
                HStack {
                    Image(systemName: "star.fill")
                    Text("Try 7 Days Free")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Preview button (optional - shows limited web content)
            Button {
                // You can optionally show a preview of the website
            } label: {
                Text("Preview Website →")
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
            .padding(.bottom)
        }
    }
}

// MARK: - Feature Preview

struct FeaturePreview: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    WebContentView()
}
