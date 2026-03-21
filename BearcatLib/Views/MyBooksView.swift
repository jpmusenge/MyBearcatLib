//
//  MyBooksView.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 2/22/26.

import SwiftUI

struct MyBooksView: View {
    @EnvironmentObject var settings: AppSettings
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
                        VStack(alignment: .leading, spacing: 32) {
                            
                            // new premium Library Card header
                            libraryCardHeader
                            
                            // Organized Sections
                            overdueSection
                            dueSoonSection
                            allBooksSection
                            
                            Spacer().frame(height: 40)
                        }
                        .padding(.top, 16)
                    }
                }
            }
            .navigationTitle("My Books")
        }
    }
    
    // MARK: - Premium Library Card
    private var libraryCardHeader: some View {
        VStack(spacing: 24) {
            // Card Identity
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("BEARCAT LIBRARY CARD")
                        .font(.custom("AvenirNext-Bold", size: 12))
                        .foregroundColor(.white.opacity(0.7))
                        .tracking(1.5)
                    
                    Text("Joseph Musenge")
                        .font(Theme.Fonts.title2)
                        .foregroundColor(.white)
                }
                Spacer()
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.3))
            }
            
            // Stats Row
            HStack(spacing: 0) {
                SummaryMetric(value: "\(checkedOutBooks.count)", label: "Borrowed")
                
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 1, height: 30)
                
                SummaryMetric(value: "\(overdueBooks.count)", label: "Overdue")
                
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 1, height: 30)
                
                SummaryMetric(value: nextDueLabel, label: "Next Due")
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [Theme.Colors.primaryLight, Theme.Colors.primaryDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: Theme.Colors.primary.opacity(0.3), radius: 15, x: 0, y: 8)
        .padding(.horizontal, Theme.Layout.paddingLarge)
    }
    
    // MARK: - Overdue Section
    @ViewBuilder
    private var overdueSection: some View {
        if !overdueBooks.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                // Kept Error Red for true urgency
                SectionHeader(title: "Overdue", icon: "exclamationmark.circle.fill", color: Theme.Colors.error)
                
                ForEach(overdueBooks, id: \.isbn) { book in
                    NavigationLink(value: book) {
                        ModernCheckedOutRow(book: book).environmentObject(settings)
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
            VStack(alignment: .leading, spacing: 16) {
                // In Primary (Blue) color
                SectionHeader(title: "Due Soon", icon: "clock.fill", color: Theme.Colors.primary)
                
                ForEach(dueSoon, id: \.isbn) { book in
                    NavigationLink(value: book) {
                        ModernCheckedOutRow(book: book).environmentObject(settings)
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
                VStack(alignment: .leading, spacing: 16) {
                    // In Primary (Blue) color
                    SectionHeader(title: "On Track", icon: "checkmark.circle.fill", color: Theme.Colors.primary)
                    
                    ForEach(safeBooks, id: \.isbn) { book in
                        NavigationLink(value: book) {
                            ModernCheckedOutRow(book: book).environmentObject(settings)
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
                    .fill(Theme.Colors.primary.opacity(dk ? 0.2 : 0.1)).frame(width: 120, height: 120)
                
                Image(systemName: "books.vertical").font(.system(size: 50)).foregroundColor(dk ? Theme.Colors.primaryLight : Theme.Colors.primary)
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
        if days == 1 { return "Tomorrow" }
        return "\(days) days"
    }
    
    private func daysUntilDue(for book: Book) -> Int {
        guard let due = book.dueDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: due)).day ?? 0
    }
}

// MARK: - Subcomponents
private struct SummaryMetric: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.custom("AvenirNext-Bold", size: 24))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .frame(height: 30)
            
            Text(label)
                .font(Theme.Fonts.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct SectionHeader: View {
    @EnvironmentObject var settings: AppSettings

    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            
            Text(title)
                .font(Theme.Fonts.title2)
                .foregroundColor(AdaptiveColors.textPrimary(settings.isDarkMode))
            
            Spacer()
        }
        .padding(.horizontal, Theme.Layout.paddingLarge)
    }
}

struct ModernCheckedOutRow: View {
    @EnvironmentObject var settings: AppSettings
    let book: Book
    private var dk: Bool { settings.isDarkMode }
    private var daysUntilDue: Int {
        guard let due = book.dueDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: due)).day ?? 0
    }
    
    // Use red for errors and primary blue for rest
    private var statusColor: Color {
        if daysUntilDue < 0 { return Theme.Colors.error }
        return Theme.Colors.primary
    }
    
    private var statusText: String {
        if daysUntilDue < 0 { return "Overdue \(abs(daysUntilDue))d" }
        if daysUntilDue == 0 { return "Due Today" }
        if daysUntilDue == 1 { return "Due Tomorrow" }
        return "Due in \(daysUntilDue)d"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AdaptiveColors.surfaceSecondary(dk))
                    .frame(width: 50, height: 75)
                
                Text(book.title.prefix(1))
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(AdaptiveColors.textSecondary(dk).opacity(0.5))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(book.title)
                    .font(Theme.Fonts.headline)
                    .foregroundColor(AdaptiveColors.textPrimary(dk))
                    .lineLimit(1)
                
                Text(book.author)
                    .font(Theme.Fonts.caption)
                    .foregroundColor(AdaptiveColors.textSecondary(dk))
                    .lineLimit(1)
                
                Text(statusText)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .clipShape(Capsule())
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("Renew")
                    .font(Theme.Fonts.subheadline)
                    .foregroundColor(Theme.Colors.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Theme.Colors.primary.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(AdaptiveColors.surface(dk))
        .cornerRadius(16)
        .shadow(color: AdaptiveColors.cardShadow(dk), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    MyBooksView()
        .environmentObject(AppSettings())
}
