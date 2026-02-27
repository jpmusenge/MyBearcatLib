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
    
    // Actions passed in from MainTabView
    var onSearchTapped: () -> Void = {}
    var onReserveTapped: () -> Void = {}
    var onDatabasesTapped: () -> Void = {}
    var onMyBooksTapped: () -> Void = {}
    
    @State private var showNotifications = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    // Hero & Status
                    headerSection
                    // Big Search Bar
                    searchBarButton
                    // Quick Actions Grid
                    quickActionsSection
                    // Due Soon (Urgent Alerts)
                    dueSoonSection
                    // Featured Books
                    featuredBooksSection
    
                    Spacer().frame(height: 40)
                }
                .padding(.top, 16)
            }
            .background(Theme.Colors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("BearcatLib")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundColor(Theme.Colors.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showNotifications = true
                    }) {
                        Image(systemName: "bell")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Theme.Colors.textPrimary)
                            .overlay(alignment: .topTrailing) {
                                // little gold notifications dot
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
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Hey, Joseph")
                .font(Theme.Fonts.headline)
                .foregroundColor(Theme.Colors.textSecondary)
            
            Text("What do you need\nfrom the library?")
                .font(Theme.Fonts.largeTitle)
                .foregroundColor(Theme.Colors.textPrimary)
                .lineSpacing(2)
            
            HStack(spacing: 6) {
                Circle()
                    .fill(Theme.Colors.success)
                    .frame(width: 8, height: 8)
                Text("Leontyne Price Library is Open · Closes at 9:00 PM")
                    .font(Theme.Fonts.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, Theme.Layout.paddingLarge)
    }
    
    // MARK: - Search Bar Button
    private var searchBarButton: some View {
        Button(action: onSearchTapped) {
            // Navigate to Search
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Theme.Colors.primary) // Brand color for the search icon
                
                Text("Search titles, authors, or ISBN...")
                    .font(Theme.Fonts.body)
                    .foregroundColor(Theme.Colors.textSecondary)
                Spacer()
            }
            .padding(Theme.Layout.paddingMedium)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.Layout.cornerRadius)
            .shadow(color: Theme.Colors.textPrimary.opacity(0.04), radius: Theme.Layout.cardShadowRadius, x: 0, y: 4)
        }
        .padding(.horizontal, Theme.Layout.paddingLarge)
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(Theme.Fonts.title2)
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.horizontal, Theme.Layout.paddingLarge)
            
            HStack(spacing: 16) {
                VStack(spacing: 16) {
                    ModernQuickAction(icon: "bookmark.fill", title: "Reserve", useAccent: false, action: onReserveTapped)
                    ModernQuickAction(icon: "network", title: "Databases", useAccent: true, action: onDatabasesTapped)
                }
                VStack(spacing: 16) {
                    ModernQuickAction(icon: "barcode.viewfinder", title: "Scan ISBN", useAccent: false, action: {})
                    ModernQuickAction(icon: "map.fill", title: "Floor Map", useAccent: false, action: {})
                }
            }
            .padding(.horizontal, Theme.Layout.paddingLarge)
        }
    }
    
    // MARK: - Due Soon Section
    private var dueSoonSection: some View {
        let checkedOut = SampleData.checkedOutBooks
        
        return Group {
            if !checkedOut.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Due Soon")
                            .font(Theme.Fonts.title2)
                            .foregroundColor(Theme.Colors.textPrimary)
                        Spacer()
                        Button("See all") {
                            onMyBooksTapped()
                        }
                        .font(Theme.Fonts.subheadline)
                        .foregroundColor(Theme.Colors.primary)
                    }
                    .padding(.horizontal, Theme.Layout.paddingLarge)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(checkedOut, id: \.isbn) { book in
                                ModernDueCard(book: book)
                            }
                        }
                        .padding(.horizontal, Theme.Layout.paddingLarge)
                        .padding(.vertical, 8)
                    }
                    .padding(.vertical, -8)
                }
            }
        }
    }
    
    // MARK: - Featured Books Section
    private var featuredBooksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Popular This Week")
                    .font(Theme.Fonts.title2)
                    .foregroundColor(Theme.Colors.textPrimary)
                Spacer()
                Button("See all") {
                    onSearchTapped()
                }
                .font(Theme.Fonts.subheadline)
                .foregroundColor(Theme.Colors.primary)
            }
            .padding(.horizontal, Theme.Layout.paddingLarge)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(SampleData.availableBooks.prefix(5), id: \.isbn) { book in
                        ModernBookCard(book: book)
                    }
                }
                .padding(.horizontal, Theme.Layout.paddingLarge)
                .padding(.vertical, 8)
            }
            .padding(.vertical, -8)
        }
    }
}

// MARK: - Modern Components

struct ModernQuickAction: View {
    let icon: String
    let title: String
    let useAccent: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Soft background circle for the icon
                ZStack {
                    Circle()
                        .fill(useAccent ? Theme.Colors.accent.opacity(0.15) : Theme.Colors.primary.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(useAccent ? Theme.Colors.accent : Theme.Colors.primary)
                }
                
                Text(title)
                    .font(Theme.Fonts.headline)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                
                Spacer()
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.Layout.cornerRadius)
            .shadow(color: Theme.Colors.textPrimary.opacity(0.04), radius: Theme.Layout.cardShadowRadius, x: 0, y: 3)
        }
    }
}

struct ModernDueCard: View {
    let book: Book // Assuming your Book struct is available
    
    var daysUntilDue: Int {
        guard let due = book.dueDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: Date(), to: due).day ?? 0
    }
    
    var isOverdue: Bool { daysUntilDue < 0 }
    
    var statusColor: Color {
        if isOverdue { return Theme.Colors.error }
        if daysUntilDue <= 2 { return Theme.Colors.warning }
        return Theme.Colors.success
    }
    
    var statusText: String {
        if isOverdue { return "Overdue by \(abs(daysUntilDue)) days" }
        if daysUntilDue == 0 { return "Due today" }
        return "Due in \(daysUntilDue) days"
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 4)
                .fill(statusColor)
                .frame(width: 4)
                .padding(.vertical, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(book.title)
                    .font(Theme.Fonts.headline)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Image(systemName: isOverdue ? "exclamationmark.triangle.fill" : "clock.fill")
                        .font(.system(size: 12))
                    Text(statusText)
                        .font(Theme.Fonts.caption)
                }
                .foregroundColor(statusColor)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(statusColor.opacity(0.1))
                .cornerRadius(6)
            }
            Spacer()
        }
        .padding(12)
        .frame(width: 240)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.Layout.cornerRadius)
        .shadow(color: Theme.Colors.textPrimary.opacity(0.05), radius: Theme.Layout.cardShadowRadius, x: 0, y: 4)
    }
}

struct ModernBookCard: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Placeholder for actual book cover
            ZStack {
                RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusSmall)
                    .fill(Theme.Colors.primaryDark)
                    .frame(width: 140, height: 200)
                
                // Subtle overlay pattern or text for the placeholder
                VStack {
                    Text(book.title.prefix(1))
                        .font(.system(size: 40, weight: .bold, design: .serif))
                        .foregroundColor(Theme.Colors.textOnPrimary.opacity(0.2))
                }
                
                // Availability Badge
                VStack {
                    HStack {
                        Spacer()
                        Text("Available")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.Colors.availableBg)
                            .foregroundColor(Theme.Colors.availableText)
                            .clipShape(Capsule())
                            .padding(8)
                    }
                    Spacer()
                }
            }
            .shadow(color: Theme.Colors.textPrimary.opacity(0.08), radius: 6, x: 0, y: 3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(Theme.Fonts.headline)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .lineLimit(1)
                
                Text(book.author)
                    .font(Theme.Fonts.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineLimit(1)
                
                // Directly addressing the shelf location pain point
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 10))
                    Text("Floor \(book.floor), \(book.section)-\(book.aisle)")
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(Theme.Colors.accent)
                .padding(.top, 4)
            }
            .frame(width: 140, alignment: .leading)
        }
    }
}

#Preview {
    HomeView()
}
