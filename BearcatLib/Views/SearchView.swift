//
//  SearchView.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 2/17/26.
//

// PURPOSE: This is the dedicated Search/Browse tab
import Foundation

import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject var settings: AppSettings
    
    @State private var searchText = ""
    @State private var selectedGenre: String? = nil
    
    private var dk: Bool { settings.isDarkMode }
    
    var filteredBooks: [Book] {
        var results = SampleData.books
        
        // Filter by text
        if !searchText.isEmpty {
            results = results.filter { book in
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.author.localizedCaseInsensitiveContains(searchText) ||
                book.isbn.contains(searchText)
            }
        }
        
        // Filter by genre
        if let genre = selectedGenre {
            results = results.filter { $0.genre == genre }
        }
        
        return results
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Genre filter chips
                genreFilterBar
                
                // Main Content Area
                if filteredBooks.isEmpty {
                    emptyStateView
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            HStack {
                                Text("\(filteredBooks.count) \(filteredBooks.count == 1 ? "result" : "results")")
                                    .font(Theme.Fonts.subheadline)
                                    .foregroundColor(AdaptiveColors.textSecondary(dk))
                                Spacer()
                            }
                            .padding(.horizontal, Theme.Layout.paddingLarge)
                            .padding(.top, 12)
                            
                            // Replaced Grid with a LazyVStack for better readability
                            LazyVStack(spacing: 16) {
                                ForEach(filteredBooks, id: \.isbn) { book in
                                    NavigationLink(value: book) {
                                        ModernBookListRow(book: book)
                                            .environmentObject(settings)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, Theme.Layout.paddingLarge)
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
            .background(AdaptiveColors.background(dk).ignoresSafeArea())
            // Native iOS Search Bar
            .searchable(text: $searchText, prompt: "Search titles, authors, or ISBN...")
            .navigationTitle("Search Catalog")
            .navigationDestination(for: Book.self) { book in
                BookDetailView(book: book)
                    .environmentObject(settings)
            }
        }
    }
    
    // MARK: - Genre Filter Bar
    private var genreFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                GenreChip(
                    title: "All",
                    isSelected: selectedGenre == nil,
                    action: { selectedGenre = nil }
                )
                .environmentObject(settings)
                
                ForEach(SampleData.genres, id: \.self) { genre in
                    GenreChip(
                        title: genre,
                        isSelected: selectedGenre == genre,
                        action: {
                            // Toggle selection
                            selectedGenre = selectedGenre == genre ? nil : genre
                        }
                    )
                    .environmentObject(settings)
                }
            }
            .padding(.horizontal, Theme.Layout.paddingLarge)
            .padding(.vertical, 12)
        }
        .background(Theme.Colors.surface)
        // Add a subtle shadow separating the filters from the scrolling content
        .shadow(color: AdaptiveColors.cardShadow(dk), radius: 3, x: 0, y: 3)
        .zIndex(1) // Ensures shadow renders over the scrollview
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(AdaptiveColors.textSecondary(dk).opacity(0.5))
            
            Text("No books found")
                .font(Theme.Fonts.title2)
                .foregroundColor(AdaptiveColors.textPrimary(dk))
            
            Text("Try adjusting your search or\nselecting a different genre.")
                .font(Theme.Fonts.body)
                .foregroundColor(AdaptiveColors.textSecondary(dk))
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Genre Chip Component
struct GenreChip: View {
    @EnvironmentObject var settings: AppSettings
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    private var dk: Bool { settings.isDarkMode }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Fonts.subheadline)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? Theme.Colors.textOnPrimary : AdaptiveColors.textPrimary(dk))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Theme.Colors.primary : AdaptiveColors.surfaceSecondary(dk))
                )
                // Add a very subtle outline to unselected chips
                .overlay(
                    Capsule()
                        .strokeBorder(AdaptiveColors.textSecondary(dk).opacity(0.1), lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

// MARK: - Modern List Row
struct ModernBookListRow: View {
    @EnvironmentObject var settings: AppSettings
    let book: Book
    private var dk: Bool { settings.isDarkMode }
    
    var body: some View {
        HStack(spacing: 16) {
            // Book Cover Placeholder
            ZStack {
                RoundedRectangle(cornerRadius: Theme.Layout.cornerRadiusSmall)
                    .fill(Theme.Colors.primaryDark)
                    .frame(width: 70, height: 100)
                
                Text(book.title.prefix(1))
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(Theme.Colors.textOnPrimary.opacity(0.3))
            }
            .shadow(color: AdaptiveColors.cardShadow(dk).opacity(0.08), radius: 4, x: 0, y: 2)
            
            // Book Details
            VStack(alignment: .leading, spacing: 6) {
                Text(book.title)
                    .font(Theme.Fonts.headline)
                    .foregroundColor(AdaptiveColors.textPrimary(dk))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true) // Prevents truncation if possible
                
                Text(book.author)
                    .font(Theme.Fonts.subheadline)
                    .foregroundColor(AdaptiveColors.textSecondary(dk))
                    .lineLimit(1)
                
                Spacer()
                
                HStack {
                    // Availability Badge
                    Text(book.isAvailable ? "Available" : "Checked Out")
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(book.isAvailable ? AdaptiveColors.availableBg(dk) : AdaptiveColors.checkedOutBg(dk))
                        .foregroundColor(book.isAvailable ? AdaptiveColors.availableText(dk) : AdaptiveColors.checkedOutText(dk))
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    // Location Indicator
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 10))
                        Text("Flr \(book.floor), \(book.section)-\(book.aisle)")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(Theme.Colors.accent)
                }
            }
            .frame(height: 100) // Match cover height
        }
        .padding(Theme.Layout.paddingMedium)
        .background(AdaptiveColors.surface(dk))
        .cornerRadius(Theme.Layout.cornerRadius)
        .shadow(color: AdaptiveColors.cardShadow(dk), radius: Theme.Layout.cardShadowRadius, x: 0, y: 3)
    }
}

#Preview {
    SearchView()
        .environmentObject(AppSettings())
}
