////
////  MyBooksView.swift
////  BearcatLib
////
////  Created by Joseph Musenge on 2/22/26.

import SwiftUI

struct MyBooksView: View {
    @EnvironmentObject var settings: AppSettings
    let checkedOutBooks = SampleData.checkedOutBooks
    private var dk: Bool { settings.isDarkMode }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Using standard system background for a native feel
                AdaptiveColors.background(dk).ignoresSafeArea()
                
                if checkedOutBooks.isEmpty {
                    emptyStateView
                } else {
                    List {
                        // MARK: - Summary Section
                        // Replaces the large gradient card with a clean, functional header
                        Section {
                            HStack(spacing: 0) {
                                SummaryStat(label: "Borrowed", value: "\(checkedOutBooks.count)")
                                
                                Divider().frame(height: 30).padding(.horizontal, 10)
                                
                                SummaryStat(
                                    label: "Overdue",
                                    value: "\(overdueBooks.count)",
                                    color: overdueBooks.isEmpty ? .primary : Theme.Colors.error
                                )
                                
                                Divider().frame(height: 30).padding(.horizontal, 10)
                                
                                SummaryStat(label: "Next Due", value: nextDueLabel)
                            }
                            .padding(.vertical, 8)
                        }
                        .listRowBackground(AdaptiveColors.surface(dk))

                        // MARK: - Overdue Section
                        if !overdueBooks.isEmpty {
                            Section("Overdue") {
                                ForEach(overdueBooks, id: \.isbn) { book in
                                    NavigationLink(value: book) {
                                        CompactBookRow(book: book)
                                    }
                                }
                            }
                        }

                        // MARK: - Active Loans Section
                        Section("Currently Borrowed") {
                            ForEach(upcomingBooks, id: \.isbn) { book in
                                NavigationLink(value: book) {
                                    CompactBookRow(book: book)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped) // The "Native App" look
                }
            }
            .navigationTitle("My Books")
            .navigationDestination(for: Book.self) { book in
                BookDetailView(book: book).environmentObject(settings)
            }
        }
    }

    // MARK: - Subcomponents
    
    private func SummaryStat(label: String, value: String, color: Color = .primary) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundColor(color)
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Books Found", systemImage: "books.vertical")
        } description: {
            Text("Your borrowed books from Leontyne Price Library will appear here.")
        }
    }

    // MARK: - Data Helpers
    private var overdueBooks: [Book] {
        checkedOutBooks.filter { daysUntilDue(for: $0) < 0 }
    }
    
    private var upcomingBooks: [Book] {
        checkedOutBooks.filter { daysUntilDue(for: $0) >= 0 }
            .sorted { daysUntilDue(for: $0) < daysUntilDue(for: $1) }
    }
    
    private var nextDueLabel: String {
        guard let next = upcomingBooks.first else { return "—" }
        let days = daysUntilDue(for: next)
        if days == 0 { return "Today" }
        if days == 1 { return "Tomorrow" }
        return "\(days)d"
    }
    
    private func daysUntilDue(for book: Book) -> Int {
        guard let due = book.dueDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: due)).day ?? 0
    }
}

// MARK: - Refined Book Row
struct CompactBookRow: View {
    let book: Book
    @EnvironmentObject var settings: AppSettings
    
    private var daysUntilDue: Int {
        guard let due = book.dueDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: due)).day ?? 0
    }

    var body: some View {
        HStack(spacing: 12) {
            // Minimalist cover identifier
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.secondary.opacity(0.1))
                Text(book.title.prefix(1))
                    .font(.system(.body, design: .serif, weight: .bold))
                    .foregroundColor(.secondary)
            }
            .frame(width: 36, height: 50)

            VStack(alignment: .leading, spacing: 2) {
                Text(book.title)
                    .font(.system(.subheadline, weight: .semibold))
                    .lineLimit(1)
                
                Text(book.author)
                    .font(.system(.caption))
                    .foregroundColor(.secondary)
                
                Text(dueBadgeText)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(daysUntilDue < 0 ? .red : Theme.Colors.primary)
            }
            
            Spacer()
            
            Button("Renew") { }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .controlSize(.small)
                .tint(Theme.Colors.primary)
        }
        .padding(.vertical, 4)
    }
    
    private var dueBadgeText: String {
        if daysUntilDue < 0 { return "OVERDUE \(abs(daysUntilDue)) DAYS" }
        if daysUntilDue == 0 { return "DUE TODAY" }
        return "DUE IN \(daysUntilDue) DAYS"
    }
}

#Preview {
    MyBooksView()
        .environmentObject(AppSettings())
}
