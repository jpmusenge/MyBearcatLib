//
//  MyBooksView.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 2/22/26.
//

import SwiftUI

struct MyBooksView: View {
    // Pulling the checked-out books from your mock data
    let checkedOutBooks = SampleData.checkedOutBooks
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                if checkedOutBooks.isEmpty {
                    emptyStateView
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(checkedOutBooks, id: \.isbn) { book in
                                // We are reusing the ModernDueCard logic from your HomeView
                                // but expanding it to span the full width of the screen
                                FullWidthDueCard(book: book)
                            }
                        }
                        .padding(.horizontal, Theme.Layout.paddingLarge)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationTitle("My Books")
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(Theme.Colors.success)
            
            Text("You're all caught up!")
                .font(Theme.Fonts.title2)
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text("You don't have any books checked out right now.")
                .font(Theme.Fonts.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Full Width Due Card
struct FullWidthDueCard: View {
    let book: Book
    
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
        HStack(alignment: .top, spacing: 16) {
            // Urgency Indicator Bar
            RoundedRectangle(cornerRadius: 4)
                .fill(statusColor)
                .frame(width: 6)
                .padding(.vertical, 6)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(book.title)
                    .font(Theme.Fonts.headline)
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text(book.author)
                    .font(Theme.Fonts.subheadline)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                HStack(spacing: 6) {
                    Image(systemName: isOverdue ? "exclamationmark.triangle.fill" : "clock.fill")
                        .font(.system(size: 14))
                    Text(statusText)
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(statusColor)
                .padding(.top, 4)
            }
            
            Spacer()
            
            // Adding a button for renewing the book
            VStack {
                Spacer()
                Button(action: {
                    // Action to renew book
                }) {
                    Text("Renew")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Theme.Colors.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Theme.Colors.primary.opacity(0.1))
                        .clipShape(Capsule())
                }
                Spacer()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.Layout.cornerRadius)
        .shadow(color: Theme.Colors.textPrimary.opacity(0.05), radius: Theme.Layout.cardShadowRadius, x: 0, y: 4)
    }
}

#Preview {
    MyBooksView()
}
