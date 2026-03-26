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
    @EnvironmentObject var bookService: BookService

    @State private var searchText = ""
    @State private var selectedGenre: String = "All"

    private var dk: Bool { settings.isDarkMode }

    private var filterOptions: [String] {
        ["All"] + bookService.genres
    }

    var filteredBooks: [Book] {
        bookService.filter(genre: selectedGenre, searchText: searchText)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar
                Divider()

                if bookService.isLoading {
                    ProgressView("Loading catalog...")
                        .frame(maxHeight: .infinity)
                } else if filteredBooks.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        Text("\(filteredBooks.count) results")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)

                        ForEach(filteredBooks, id: \.id) { book in
                            NavigationLink(value: book) {
                                StandardBookRow(
                                    book: book,
                                    copyInfo: bookService.copyInfo(for: book)
                                )
                            }
                        }
                    }
                    .listStyle(.plain)
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
    var copyInfo: (total: Int, available: Int) = (1, 1)

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

            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                HStack {
                    // Availability with copy count
                    if copyInfo.available > 0 {
                        Text("\(copyInfo.available) of \(copyInfo.total) available")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    } else {
                        Text("All \(copyInfo.total) checked out")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }

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
        .environmentObject(BookService.shared)
}
