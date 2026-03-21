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
    @State private var selectedGenre: String = "All"
    
    private var dk: Bool { settings.isDarkMode }
    
    // Create an array that includes "All" at the beginning for the filter bar
    private var filterOptions: [String] {
        ["All"] + SampleData.genres
    }
    
    var filteredBooks: [Book] {
        var results = SampleData.books
        
        // 1. Filter by Genre
        if selectedGenre != "All" {
            results = results.filter { $0.genre == selectedGenre }
        }
        
        // 2. Filter by Search Text
        if !searchText.isEmpty {
            results = results.filter { book in
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.author.localizedCaseInsensitiveContains(searchText) ||
                book.isbn.contains(searchText)
            }
        }
        
        return results
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Native-feeling filter scroll without the heavy drop shadow
                filterBar
                Divider() // Standard system separator
                
                if filteredBooks.isEmpty {
                    // Using iOS Native Empty State
                    ContentUnavailableView.search(text: searchText)
                } else {
                    // Standard System List (High Density)
                    List {
                        Text("\(filteredBooks.count) results")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        
                        ForEach(filteredBooks, id: \.isbn) { book in
                            NavigationLink(value: book) {
                                StandardBookRow(book: book)
                            }
                        }
                    }
                    .listStyle(.plain) // The standard style for search catalogs
                }
            }
            .navigationTitle("Search Catalog")
            .searchable(text: $searchText, prompt: "Search titles, authors, or ISBN...")
            .navigationDestination(for: Book.self) { book in
                BookDetailView(book: book)
                    .environmentObject(settings)
            }
        }
    }
    
    // MARK: - HIG Filter Bar
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filterOptions, id: \.self) { genre in
                    Button(action: {
                        withAnimation { selectedGenre = genre }
                    }) {
                        Text(genre)
                            .font(.subheadline)
                            .fontWeight(selectedGenre == genre ? .semibold : .regular)
                            .foregroundColor(selectedGenre == genre ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedGenre == genre ? Theme.Colors.primary : Color(UIColor.tertiarySystemFill))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Standard System Cell
struct StandardBookRow: View {
    let book: Book
    
    var body: some View {
        HStack(spacing: 16) {
            // Minimalist Cover Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(UIColor.secondarySystemFill))
                
                Text(book.title.prefix(1))
                    .font(.system(.title3, design: .serif, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .frame(width: 50, height: 75)
            
            // Text Layout following standard iOS table cell design
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    // Status
                    Text(book.isAvailable ? "Available" : "Checked Out")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(book.isAvailable ? .green : .red)
                    
                    Spacer()
                    
                    // Location
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                        Text("Flr \(book.floor), \(book.section)-\(book.aisle)")
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SearchView()
        .environmentObject(AppSettings())
}
