//
//  BookDetailView.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 2/23/26.
//

import Foundation
import SwiftUI

struct BookDetailView: View {
    let book: Book
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var checkoutService: CheckoutService

    @State private var isCheckingOut = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorText = ""
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // MARK: - Hero Header
                coverHeader
                
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - Title & Author
                    titleAndAuthorSection
                    
                    // MARK: - Action Buttons
                    actionSection
                    
                    // MARK: - Location Card
                    locationCard
                    
                    // MARK: - Synopsis
                    synopsisSection
                    
                    // MARK: - Details
                    metadataSection
                    
                    Spacer().frame(height: 40)
                }
                .padding(.top, 24)
            }
        }
        .background(Theme.Colors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        // Hide the default back button to use our own custom one, or keep it standard
        .alert("Book Checked Out", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { dismiss() }
        } message: {
            Text("You've checked out this book. It's due in 14 days. You can view it in My Books.")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK") {}
        } message: {
            Text(errorText)
        }
    }
    
    // MARK: - Components
    
    private var coverHeader: some View {
        ZStack(alignment: .bottom) {
            // Blurred Background
            LinearGradient(
                colors: gradientColors(for: book.genre),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 300)
            .blur(radius: 40)
            .overlay(Color.black.opacity(0.2))
            .ignoresSafeArea(edges: .top)
            
            // The actual Book Cover (matching BookCardView proportions)
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: gradientColors(for: book.genre),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                VStack {
                    Spacer()
                    Text(book.title.prefix(1))
                        .font(.system(size: 80, weight: .bold, design: .serif))
                        .foregroundColor(.white.opacity(0.25))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                Image(systemName: genreIcon(for: book.genre))
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
            .frame(width: 160, height: 240)
            .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
            .offset(y: 40) // Push down so it overlaps the content area
        }
        .padding(.bottom, 40) // Make room for the offset
    }
    
    private var titleAndAuthorSection: some View {
        VStack(spacing: 8) {
            Text(book.title)
                .font(Theme.Fonts.largeTitle)
                .foregroundColor(Theme.Colors.textPrimary)
                .multilineTextAlignment(.center)
            
            Text(book.author)
                .font(Theme.Fonts.title2)
                .foregroundColor(Theme.Colors.textSecondary)
            
            // Availability Badge
            HStack {
                Circle()
                    .fill(book.isAvailable ? Theme.Colors.success : Theme.Colors.error)
                    .frame(width: 8, height: 8)
                Text(book.isAvailable ? "Available Now" : "Currently Checked Out")
                    .font(Theme.Fonts.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(book.isAvailable ? Theme.Colors.success : Theme.Colors.error)
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity) // Center align everything in this block
        .padding(.horizontal, Theme.Layout.paddingLarge)
    }
    
    private var actionSection: some View {
        VStack {
            Button(action: {
                checkoutBook()
            }) {
                HStack {
                    if isCheckingOut {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: book.isAvailable ? "book.fill" : "clock.fill")
                        Text(book.isAvailable ? "Check Out" : "Currently Unavailable")
                    }
                }
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Theme.Colors.textOnPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(book.isAvailable ? Theme.Colors.primary : Theme.Colors.textSecondary)
                )
                .shadow(color: (book.isAvailable ? Theme.Colors.primary : Color.clear).opacity(0.3), radius: 10, x: 0, y: 4)
            }
            .disabled(!book.isAvailable || isCheckingOut)
        }
        .padding(.horizontal, Theme.Layout.paddingLarge)
    }

    private func checkoutBook() {
        isCheckingOut = true
        Task {
            do {
                try await checkoutService.checkoutBook(book)
                showSuccessAlert = true
            } catch {
                errorText = error.localizedDescription
                showErrorAlert = true
            }
            isCheckingOut = false
        }
    }
    
    private var locationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Find it on the shelf")
                .font(Theme.Fonts.headline)
                .foregroundColor(Theme.Colors.textPrimary)
            
            HStack(spacing: 20) {
                LocationDetailItem(title: "Floor", value: "\(book.floor)", icon: "building.2.fill")
                Divider()
                LocationDetailItem(title: "Section", value: book.section, icon: "books.vertical.fill")
                Divider()
                LocationDetailItem(title: "Aisle", value: book.aisle, icon: "arrow.left.and.right")
                Divider()
                LocationDetailItem(title: "Shelf", value: book.shelf, icon: "list.dash")
            }
            .padding(16)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.Layout.cornerRadius)
            // Accent outline to draw the eye
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Layout.cornerRadius)
                    .stroke(Theme.Colors.accent.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.horizontal, Theme.Layout.paddingLarge)
    }
    
    private var synopsisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Synopsis")
                .font(Theme.Fonts.headline)
                .foregroundColor(Theme.Colors.textPrimary)
            
            // Assuming mock data has a description. If not, fallback text.
            Text(book.description)
                .font(Theme.Fonts.body)
                .foregroundColor(Theme.Colors.textSecondary)
                .lineSpacing(4)
        }
        .padding(.horizontal, Theme.Layout.paddingLarge)
    }
    
    private var metadataSection: some View {
        VStack(spacing: 0) {
            MetadataRow(title: "Genre", value: book.genre)
            Divider().padding(.vertical, 12)
            MetadataRow(title: "ISBN", value: book.isbn)
        }
        .padding(16)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.Layout.cornerRadius)
        .padding(.horizontal, Theme.Layout.paddingLarge)
    }
    
    // MARK: - Helpers (Same as BookCardView)
    private func gradientColors(for genre: String) -> [Color] {
        switch genre {
        case "Literature", "Language & Literature":
            return [Color(hex: "0C8599"), Color(hex: "22B8CF")]
        case "History", "American History", "American History - Local", "World History":
            return [Color(hex: "099268"), Color(hex: "20C997")]
        case "Science", "Biology", "Chemistry", "Physics":
            return [Color(hex: "E8590C"), Color(hex: "FD7E14")]
        case "Business", "Social Sciences":
            return [Color(hex: "7048E8"), Color(hex: "9775FA")]        default:                 return [Theme.Colors.primary, Theme.Colors.primaryLight]
        }
    }
    
    private func genreIcon(for genre: String) -> String {
        switch genre {
        case "Literature", "Language & Literature":
            return "books.vertical.fill"
        case "History", "American History", "American History - Local", "World History":
            return "building.columns.fill"
        case "Science", "Biology", "Chemistry", "Physics":
            return "atom"
        case "Business", "Social Sciences":
            return "chart.bar.fill"
        case "Computer Science", "Technology":
            return "laptopcomputer"
        case "Mathematics":
            return "x.squareroot"
        case "Psychology":
            return "brain.head.profile"
        default:
            return "book.closed.fill"
        }
    }
}

// MARK: - Subcomponents

struct LocationDetailItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Theme.Colors.accent) // Gold accent
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Theme.Colors.textSecondary)
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Theme.Colors.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MetadataRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(Theme.Fonts.subheadline)
                .foregroundColor(Theme.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(Theme.Fonts.body)
                .fontWeight(.medium)
                .foregroundColor(Theme.Colors.textPrimary)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        BookDetailView(book: SampleData.books[0])
            .environmentObject(AppSettings())
            .environmentObject(CheckoutService.shared)
    }
}
