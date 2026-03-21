//
//  MyBooksView.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 2/22/26.

// PURPOSE: Shows user's checked-out books organized by urgency — overdue, due soon, on track

import SwiftUI

struct MyBooksView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var authViewModel: AuthViewModel
    let checkedOutBooks = SampleData.checkedOutBooks
    private var dk: Bool { settings.isDarkMode }

    var body: some View {
        NavigationStack {
            ZStack {
                AdaptiveColors.background(dk).ignoresSafeArea()

                if checkedOutBooks.isEmpty {
                    emptyStateView
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 28) {

                            // MARK: - Summary Stats
                            summaryStats

                            // MARK: - Sections
                            overdueSection
                            dueSoonSection
                            allBooksSection

                            Spacer().frame(height: 40)
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("My Books")
        }
    }

    // MARK: - Summary Stats

    private var summaryStats: some View {
        HStack(spacing: 12) {
            StatPill(
                icon: "book.closed.fill",
                value: "\(checkedOutBooks.count)",
                label: "Borrowed",
                color: Theme.Colors.primary,
                dk: dk
            )

            StatPill(
                icon: "exclamationmark.circle.fill",
                value: "\(overdueBooks.count)",
                label: "Overdue",
                color: overdueBooks.isEmpty ? AdaptiveColors.textSecondary(dk) : Theme.Colors.error,
                dk: dk
            )

            StatPill(
                icon: "clock.fill",
                value: nextDueLabel,
                label: "Next Due",
                color: Theme.Colors.accent,
                dk: dk
            )
        }
        .padding(.horizontal, Theme.Layout.paddingLarge)
    }

    // MARK: - Overdue Section

    @ViewBuilder
    private var overdueSection: some View {
        if !overdueBooks.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Overdue", icon: "exclamationmark.circle.fill", color: Theme.Colors.error)

                ForEach(overdueBooks, id: \.isbn) { book in
                    NavigationLink(value: book) {
                        BookCheckoutRow(book: book, dk: dk)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, Theme.Layout.paddingLarge)
            }
            .navigationDestination(for: Book.self) { book in
                BookDetailView(book: book).environmentObject(settings)
            }
        }
    }

    // MARK: - Due Soon Section

    @ViewBuilder
    private var dueSoonSection: some View {
        let dueSoon = upcomingBooks.filter { daysUntilDue(for: $0) <= 3 && daysUntilDue(for: $0) >= 0 }

        if !dueSoon.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Due Soon", icon: "clock.fill", color: Theme.Colors.warning)

                ForEach(dueSoon, id: \.isbn) { book in
                    NavigationLink(value: book) {
                        BookCheckoutRow(book: book, dk: dk)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, Theme.Layout.paddingLarge)
            }
        }
    }

    // MARK: - All Books Section

    private var allBooksSection: some View {
        let safeBooks = upcomingBooks.filter { daysUntilDue(for: $0) > 3 }

        return Group {
            if !safeBooks.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "On Track", icon: "checkmark.circle.fill", color: Theme.Colors.success)

                    ForEach(safeBooks, id: \.isbn) { book in
                        NavigationLink(value: book) {
                            BookCheckoutRow(book: book, dk: dk)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, Theme.Layout.paddingLarge)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Theme.Colors.primary.opacity(dk ? 0.2 : 0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "books.vertical")
                    .font(.system(size: 50))
                    .foregroundColor(dk ? Theme.Colors.primaryLight : Theme.Colors.primary)
            }

            VStack(spacing: 8) {
                Text("No books checked out")
                    .font(Theme.Fonts.title2)
                    .foregroundColor(AdaptiveColors.textPrimary(dk))

                Text("Your borrowed books and their due dates will appear here.")
                    .font(Theme.Fonts.body)
                    .foregroundColor(AdaptiveColors.textSecondary(dk))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)

            Spacer()
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
        if days == 1 { return "1 day" }
        return "\(days) days"
    }

    private func daysUntilDue(for book: Book) -> Int {
        guard let due = book.dueDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: due)).day ?? 0
    }
}

// MARK: - Stat Pill

private struct StatPill: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let dk: Bool

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)

            Text(value)
                .font(.custom("AvenirNext-Bold", size: 18))
                .foregroundColor(AdaptiveColors.textPrimary(dk))
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(label)
                .font(Theme.Fonts.caption)
                .foregroundColor(AdaptiveColors.textSecondary(dk))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AdaptiveColors.surface(dk))
        .cornerRadius(Theme.Layout.cornerRadius)
        .shadow(color: AdaptiveColors.cardShadow(dk), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Section Header

private struct SectionHeader: View {
    @EnvironmentObject var settings: AppSettings

    let title: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)

            Text(title)
                .font(Theme.Fonts.title2)
                .foregroundColor(AdaptiveColors.textPrimary(settings.isDarkMode))

            Spacer()
        }
        .padding(.horizontal, Theme.Layout.paddingLarge)
    }
}

// MARK: - Book Checkout Row

struct BookCheckoutRow: View {
    let book: Book
    let dk: Bool

    private var daysUntilDue: Int {
        guard let due = book.dueDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: due)).day ?? 0
    }

    private var statusColor: Color {
        if daysUntilDue < 0 { return Theme.Colors.error }
        if daysUntilDue <= 3 { return Theme.Colors.warning }
        return Theme.Colors.success
    }

    private var statusText: String {
        if daysUntilDue < 0 { return "Overdue \(abs(daysUntilDue))d" }
        if daysUntilDue == 0 { return "Due Today" }
        if daysUntilDue == 1 { return "Due Tomorrow" }
        return "Due in \(daysUntilDue)d"
    }

    private var dueDateFormatted: String {
        guard let due = book.dueDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: due)
    }

    var body: some View {
        HStack(spacing: 14) {
            // Book cover placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(statusColor.opacity(0.12))
                    .frame(width: 48, height: 68)

                Image(systemName: "book.closed.fill")
                    .font(.system(size: 20))
                    .foregroundColor(statusColor.opacity(0.6))
            }

            // Book info
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(Theme.Fonts.headline)
                    .foregroundColor(AdaptiveColors.textPrimary(dk))
                    .lineLimit(1)

                Text(book.author)
                    .font(Theme.Fonts.caption)
                    .foregroundColor(AdaptiveColors.textSecondary(dk))
                    .lineLimit(1)

                HStack(spacing: 8) {
                    // Status badge
                    Text(statusText)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(statusColor.opacity(0.12))
                        .clipShape(Capsule())

                    if !dueDateFormatted.isEmpty {
                        Text(dueDateFormatted)
                            .font(Theme.Fonts.caption)
                            .foregroundColor(AdaptiveColors.textSecondary(dk))
                    }
                }
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AdaptiveColors.textSecondary(dk).opacity(0.5))
        }
        .padding(14)
        .background(AdaptiveColors.surface(dk))
        .cornerRadius(Theme.Layout.cornerRadius)
        .shadow(color: AdaptiveColors.cardShadow(dk), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    MyBooksView()
        .environmentObject(AppSettings())
        .environmentObject(AuthViewModel())
}
