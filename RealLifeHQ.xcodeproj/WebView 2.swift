//
//  WebView.swift
//  RealLifeHQ
//
//  Created by Sarah Walker on 1/10/26.
//

import SwiftUI
import WebKit

/// A SwiftUI wrapper for WKWebView to display web content
struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    var onNavigationChange: ((URL) -> Void)?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url != url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            if let url = webView.url {
                parent.onNavigationChange?(url)
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            print("WebView navigation failed: \(error.localizedDescription)")
        }
    }
}

/// Configuration for the app's website
struct AppConfiguration {
    /// Your Base44 website URL
    static let websiteURL = "https://reallifehq-6410e686.base44.app"
    
    /// Fallback URL if the main site fails to load
    static let fallbackURL = "https://www.apple.com"
    
    /// Support email
    static let supportEmail = "support@reallifehq.com" // ⚠️ Update with your actual support email
    
    /// Privacy policy URL
    static let privacyPolicyURL = "https://reallifehq-6410e686.base44.app/privacy"
    
    /// Terms of service URL
    static let termsOfServiceURL = "https://reallifehq-6410e686.base44.app/terms"
}

#Preview {
    struct PreviewWrapper: View {
        @State private var isLoading = false
        
        var body: some View {
            WebView(
                url: URL(string: AppConfiguration.websiteURL)!,
                isLoading: $isLoading
            )
        }
    }
    
    return PreviewWrapper()
}
