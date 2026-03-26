////
////  HomeView.swift
////  BearcatLib
////
////  Created by Joseph Musenge on 2/17/26.
////
//
//// PURPOSE: The main Browse screen — the first thing students see
import Foundation

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var bookService: BookService

    // Actions passed in from MainTabView
    var onSearchTapped: () -> Void = {}
    var onReserveTapped: () -> Void = {}
    var onDatabasesTapped: () -> Void = {}
    var onMyBooksTapped: () -> Void = {}
    
    @State private var showNotifications = false
    private var dk: Bool { settings.isDarkMode }
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Welcome & Status Section
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Hey, \(authViewModel.userFirstName)")
                            .font(.subheadline)
                            .foregroundColor(AdaptiveColors.textSecondary(dk))
                        
                        Text("What do you need\nfrom the library?")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AdaptiveColors.textPrimary(dk))
                            .lineSpacing(2)
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Theme.Colors.success)
                                .frame(width: 8, height: 8)
                            Text("Leontyne Price Library is Open · Closes at 9:00 PM")
                                .font(.caption)
                                .foregroundColor(AdaptiveColors.textSecondary(dk))
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(AdaptiveColors.surface(dk))
                
                // MARK: - Search Section
                Section {
                    Button(action: onSearchTapped) {
                        Label("Search titles, authors, or ISBN...", systemImage: "magnifyingglass")
                            .foregroundColor(.secondary)
                    }
                }
                .listRowBackground(AdaptiveColors.surface(dk))

                // MARK: - Quick Actions Grid
                Section("Quick Actions") {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        // Hooked up to onReserveTapped
                        Button(action: onReserveTapped) {
                            HomeActionTile(title: "Reserve", icon: "bookmark.fill", color: Theme.Colors.primary)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {}) {
                            HomeActionTile(title: "Scan ISBN", icon: "barcode.viewfinder", color: Theme.Colors.primary)
                        }
                        .buttonStyle(.plain)
                        
                        // Hooked up to onDatabasesTapped
                        Button(action: onDatabasesTapped) {
                            HomeActionTile(title: "Databases", icon: "network", color: Theme.Colors.accent)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {}) {
                            HomeActionTile(title: "Floor Map", icon: "map.fill", color: Theme.Colors.primary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())

                // MARK: - Urgent Alerts (Due Soon)
                let checkedOut = bookService.checkedOutBooks
                if !checkedOut.isEmpty {
                    Section(header: Text("Due Soon")) {
                        ForEach(checkedOut.prefix(2)) { book in
                            Button(action: onMyBooksTapped) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(book.title)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(AdaptiveColors.textPrimary(dk))
                                            .lineLimit(1)
                                        
                                        // Using standard Apple HIG warning colors
                                        Text(book.formattedDueDate ?? "Due soon")
                                            .font(.caption)
                                            .foregroundColor(book.isOverdue ? .red : .orange)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // App Logo Restored to Top Left
                ToolbarItem(placement: .topBarLeading) {
                    BearcatLibLogo(showTitle: false)
                        .scaleEffect(0.35)
                        .frame(width: 36, height: 36)
                }
                
                // Notifications Icon on Top Right
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showNotifications = true }) {
                        Image(systemName: "bell")
                            .symbolVariant(.fill)
                            .foregroundColor(Theme.Colors.textPrimary)
                            .overlay(alignment: .topTrailing) {
                                Circle()
                                    .fill(Theme.Colors.accent)
                                    .frame(width: 10, height: 10)
                                    .offset(x: 2, y: -2)
                            }
                    }
                }
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
            }
        }
    }
}

// Minimalist Grid Tile for Home
struct HomeActionTile: View {
    @EnvironmentObject var settings: AppSettings
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(AdaptiveColors.textPrimary(settings.isDarkMode))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(AdaptiveColors.surface(settings.isDarkMode))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppSettings())
        .environmentObject(AuthViewModel())
        .environmentObject(BookService.shared) 
}
