//
//  MainTabView.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 2/17/26.
//

// PURPOSE: This is the app's main navigation structure — the tab bar at the bottom of the screen

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var bookService: BookService
    
    // Track which tab is selected. Starts on "browse"
    @State private var selectedTab = "home"
    @State private var showPrintSheet = false
    @State private var showDatabases = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // Tab 1: Browse / Home
            HomeView(
                onSearchTapped: { selectedTab = "search" },
                onReserveTapped: { selectedTab = "search" },
                onDatabasesTapped: { showDatabases = true },
                onMyBooksTapped: { selectedTab = "mybooks" }
            )
            .sheet(isPresented: $showDatabases) {
                // Wrapping it in a NavigationStack gives the nice title bar at the top
                NavigationStack {
                    ResourcesView()
                }
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            .tag("home")
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag("search")
            
            // Tab 2: My Books
            MyBooksView()
                .tabItem {
                    Image(systemName: "book.closed")
                    Text("My Books")
                }
                .tag("mybooks")
            
            // Tab 3: Profile
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
                .tag("profile")
        }
    }
}

// MARK: - Preview
// #Preview lets you see this view in Xcode's canvas (right side)

#Preview {
    MainTabView()
        .environmentObject(AppSettings())
        .environmentObject(AuthViewModel())
        .environmentObject(BookService.shared)
        .environmentObject(CheckoutService.shared)
}
