//
//  MainTabView.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 2/17/26.
//

// PURPOSE: This is the app's main navigation structure — the tab bar at the bottom of the screen

import SwiftUI

struct MainTabView: View {
    
    // Track which tab is selected. Starts on "browse"
    @State private var selectedTab = "browse"
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // Tab 1: Browse / Home
            // This will be our HomeView (building it next!)
            // For now, a placeholder so we can see the tabs working.
            Text("Home Screen — Coming Next!")
                .tabItem {
                    Image(systemName: "books.vertical")
                    Text("Browse")
                }
                .tag("browse")
            
            // Tab 2: My Books
            Text("My Books — Coming Soon!")
                .tabItem {
                    Image(systemName: "book.closed")
                    Text("My Books")
                }
                .tag("mybooks")
            
            // Tab 3: Profile
            Text("Profile — Coming Soon!")
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
                .tag("profile")
        }
        // Tint the active tab icon and label with our royal blue
        .tint(Theme.Colors.primary)
    }
}

// MARK: - Preview
// #Preview lets you see this view in Xcode's canvas (right side)
// without running the full app in the simulator

#Preview {
    MainTabView()
}
