//
//  DeepLinkManager.swift
//  Clnk
//
//  Handles deep linking for sharing bars, drinks, reviews, and profiles
//

import Foundation
import SwiftUI

// MARK: - Deep Link Types
enum DeepLink: Equatable {
    case bar(id: UUID)
    case drink(barId: UUID, drinkId: UUID)
    case review(id: UUID)
    case profile(id: UUID)
    
    /// Parse a URL into a DeepLink
    static func from(url: URL) -> DeepLink? {
        guard url.scheme == "clnk" else { return nil }
        
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        
        switch url.host {
        case "bar":
            guard let idString = pathComponents.first,
                  let id = UUID(uuidString: idString) else { return nil }
            return .bar(id: id)
            
        case "drink":
            guard pathComponents.count >= 2,
                  let barId = UUID(uuidString: pathComponents[0]),
                  let drinkId = UUID(uuidString: pathComponents[1]) else { return nil }
            return .drink(barId: barId, drinkId: drinkId)
            
        case "review":
            guard let idString = pathComponents.first,
                  let id = UUID(uuidString: idString) else { return nil }
            return .review(id: id)
            
        case "profile":
            guard let idString = pathComponents.first,
                  let id = UUID(uuidString: idString) else { return nil }
            return .profile(id: id)
            
        default:
            return nil
        }
    }
    
    /// Generate a shareable URL
    var url: URL {
        switch self {
        case .bar(let id):
            return URL(string: "clnk://bar/\(id.uuidString)")!
        case .drink(let barId, let drinkId):
            return URL(string: "clnk://drink/\(barId.uuidString)/\(drinkId.uuidString)")!
        case .review(let id):
            return URL(string: "clnk://review/\(id.uuidString)")!
        case .profile(let id):
            return URL(string: "clnk://profile/\(id.uuidString)")!
        }
    }
    
    /// Human-readable share text
    func shareText(barName: String? = nil, drinkName: String? = nil, userName: String? = nil) -> String {
        switch self {
        case .bar:
            return "Check out \(barName ?? "this bar") on Clnk! 🥂"
        case .drink:
            if let drink = drinkName, let bar = barName {
                return "Try the \(drink) at \(bar)! 🍹"
            }
            return "Check out this cocktail on Clnk! 🍹"
        case .review:
            return "Check out this review on Clnk! ⭐"
        case .profile:
            return "Follow \(userName ?? "this person") on Clnk! 👤"
        }
    }
}

// MARK: - Deep Link Manager
@MainActor
class DeepLinkManager: ObservableObject {
    static let shared = DeepLinkManager()
    
    @Published var pendingDeepLink: DeepLink?
    @Published var navigationPath = NavigationPath()
    
    private init() {}
    
    /// Handle an incoming URL
    func handle(url: URL) {
        guard let deepLink = DeepLink.from(url: url) else { return }
        pendingDeepLink = deepLink
    }
    
    /// Clear the pending deep link after navigation
    func clearPendingLink() {
        pendingDeepLink = nil
    }
}

// MARK: - Share Sheet Helper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Share Button View Modifier
struct ShareButton: ViewModifier {
    let deepLink: DeepLink
    let itemName: String
    @State private var showShareSheet = false
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [
                    deepLink.shareText(barName: itemName),
                    deepLink.url
                ])
            }
    }
}

extension View {
    func shareButton(deepLink: DeepLink, itemName: String = "") -> some View {
        modifier(ShareButton(deepLink: deepLink, itemName: itemName))
    }
}
