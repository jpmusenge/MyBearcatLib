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
    
    @State private var searchText = ""
    @State private var selectedGenre: String? = nil
    
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
                                    .foregroundColor(Theme.Colors.textSecondary)
                                Spacer()
                            }
                            .padding(.horizontal, Theme.Layout.paddingLarge)
                            .padding(.top, 12)
                            
                            // Replaced Grid with a LazyVStack for better readability
                            LazyVStack(spacing: 16) {
                                ForEach(filteredBooks, id: \.isbn) { book in
                                    NavigationLink(value: book) {
                                        ModernBookListRow(book: book)
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
            .background(Theme.Colors.background.ignoresSafeArea())
            // Native iOS Search Bar
            .searchable(text: $searchText, prompt: "Search titles, authors, or ISBN...")
            .navigationTitle("Search Catalog")
            .navigationDestination(for: Book.self) { book in
                BookDetailView(book: book)
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
                
                ForEach(SampleData.genres, id: \.self) { genre in
                    GenreChip(
                        title: genre,
                        isSelected: selectedGenre == genre,
                        action: {
                            // Toggle selection
                            selectedGenre = selectedGenre == genre ? nil : genre
                        }
                    )
                }
            }
            .padding(.horizontal, Theme.Layout.paddingLarge)
            .padding(.vertical, 12)
        }
        .background(Theme.Colors.surface)
        // Add a subtle shadow separating the filters from the scrolling content
        .shadow(color: Theme.Colors.textPrimary.opacity(0.03), radius: 3, x: 0, y: 3)
        .zIndex(1) // Ensures shadow renders over the scrollview
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(Theme.Colors.textSecondary.opacity(0.5))
            
            Text("No books found")
                .font(Theme.Fonts.title2)
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text("Try adjusting your search or\nselecting a different genre.")
                .font(Theme.Fonts.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Genre Chip Component
struct GenreChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Fonts.subheadline)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? Theme.Colors.textOnPrimary : Theme.Colors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Theme.Colors.primary : Theme.Colors.surfaceSecondary)
                )
                // Add a very subtle outline to unselected chips
                .overlay(
                    Capsule()
                        .strokeBorder(Theme.Colors.textSecondary.opacity(0.1), lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

// MARK: - Modern List Row
struct ModernBookListRow: View {
    let book: Book
    
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
            .shadow(color: Theme.Colors.textPrimary.opacity(0.08), radius: 4, x: 0, y: 2)
            
            // Book Details
            VStack(alignment: .leading, spacing: 6) {
                Text(book.title)
                    .font(Theme.Fonts.headline)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true) // Prevents truncation if possible
                
                Text(book.author)
                    .font(Theme.Fonts.subheadline)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineLimit(1)
                
                Spacer()
                
                HStack {
                    // Availability Badge
                    Text(book.isAvailable ? "Available" : "Checked Out")
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(book.isAvailable ? Theme.Colors.availableBg : Theme.Colors.checkedOutBg)
                        .foregroundColor(book.isAvailable ? Theme.Colors.availableText : Theme.Colors.checkedOutText)
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
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.Layout.cornerRadius)
        .shadow(color: Theme.Colors.textPrimary.opacity(0.04), radius: Theme.Layout.cardShadowRadius, x: 0, y: 3)
    }
}

#Preview {
    SearchView()
}
