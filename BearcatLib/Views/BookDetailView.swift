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
    @EnvironmentObject var reservationService: ReservationService

    @State private var isCheckingOut = false
    @State private var isReserving = false
    @State private var showSuccessAlert = false
    @State private var showReserveSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var showCancelReserveAlert = false
    @State private var errorText = ""
    @State private var waitlistCount: Int = 0

    /// The user's active reservation for this book, if any
    private var activeReservation: Reservation? {
        guard let bookId = book.firestoreId else { return nil }
        return reservationService.activeReservation(forBookId: bookId)
    }

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
        .task {
            // Fetch waitlist count when view appears
            if let bookId = book.firestoreId, !book.isAvailable {
                waitlistCount = await reservationService.fetchWaitlistCount(forBookId: bookId)
            }
        }
        .alert("Book Checked Out", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { dismiss() }
        } message: {
            Text("You've checked out this book. It's due in 14 days. You can view it in My Books.")
        }
        .alert("Book Reserved", isPresented: $showReserveSuccessAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You've been added to the waitlist. We'll notify you when this book becomes available.")
        }
        .alert("Cancel Reservation?", isPresented: $showCancelReserveAlert) {
            Button("Keep Reservation", role: .cancel) {}
            Button("Cancel Reservation", role: .destructive) {
                cancelReservation()
            }
        } message: {
            Text("You'll lose your place in the waitlist.")
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

            // Book Cover — real image from Open Library, with gradient fallback
            bookCoverImage
                .frame(width: 160, height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
                .offset(y: 40)
        }
        .padding(.bottom, 40)
    }

    /// Attempts to load a real cover image via Open Library Covers API,
    /// falling back to the genre-based gradient cover.
    @ViewBuilder
    private var bookCoverImage: some View {
        let isbn = book.isbn.replacingOccurrences(of: "-", with: "")
        if !isbn.isEmpty, let url = URL(string: "https://covers.openlibrary.org/b/isbn/\(isbn)-L.jpg") {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    fallbackCover
                case .empty:
                    ZStack {
                        fallbackCover
                        ProgressView()
                            .tint(.white)
                    }
                @unknown default:
                    fallbackCover
                }
            }
        } else {
            fallbackCover
        }
    }

    /// Genre-based gradient cover (same style as BookCardView)
    private var fallbackCover: some View {
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
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Theme.Layout.paddingLarge)
    }

    private var actionSection: some View {
        VStack(spacing: 12) {
            if book.isAvailable {
                // MARK: - Check Out Button
                Button(action: { checkoutBook() }) {
                    HStack {
                        if isCheckingOut {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "book.fill")
                            Text("Check Out")
                        }
                    }
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Theme.Colors.textOnPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Theme.Colors.primary)
                    )
                    .shadow(color: Theme.Colors.primary.opacity(0.3), radius: 10, x: 0, y: 4)
                }
                .disabled(isCheckingOut)
            } else if let reservation = activeReservation {
                // MARK: - Already Reserved — show status + cancel option
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "clock.badge.checkmark.fill")
                        Text(reservation.statusText)
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.Colors.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Theme.Colors.accent.opacity(0.12))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Theme.Colors.accent.opacity(0.3), lineWidth: 1)
                    )

                    Button(action: { showCancelReserveAlert = true }) {
                        Text("Cancel Reservation")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Theme.Colors.error)
                    }
                }
            } else {
                // MARK: - Reserve Button (book is checked out, no active reservation)
                Button(action: { reserveBook() }) {
                    HStack {
                        if isReserving {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "bell.badge.fill")
                            Text("Reserve This Book")
                        }
                    }
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Theme.Colors.accent)
                    )
                    .shadow(color: Theme.Colors.accent.opacity(0.3), radius: 10, x: 0, y: 4)
                }
                .disabled(isReserving)

                if waitlistCount > 0 {
                    Text("\(waitlistCount) \(waitlistCount == 1 ? "person" : "people") waiting")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
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

    private func reserveBook() {
        isReserving = true
        Task {
            do {
                try await reservationService.reserveBook(book)
                showReserveSuccessAlert = true
                // Refresh waitlist count
                if let bookId = book.firestoreId {
                    waitlistCount = await reservationService.fetchWaitlistCount(forBookId: bookId)
                }
            } catch {
                errorText = error.localizedDescription
                showErrorAlert = true
            }
            isReserving = false
        }
    }

    private func cancelReservation() {
        guard let reservation = activeReservation else { return }
        Task {
            do {
                try await reservationService.cancelReservation(reservation)
                if let bookId = book.firestoreId {
                    waitlistCount = await reservationService.fetchWaitlistCount(forBookId: bookId)
                }
            } catch {
                errorText = error.localizedDescription
                showErrorAlert = true
            }
        }
    }

    private var locationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Find it on the shelf")
                .font(Theme.Fonts.headline)
                .foregroundColor(Theme.Colors.textPrimary)

            HStack(spacing: 0) {
                LocationDetailItem(title: "Floor", value: "\(book.floor)", icon: "building.2.fill")

                Divider().frame(height: 50)

                LocationDetailItem(title: "Section", value: book.section, icon: "books.vertical.fill")

                Divider().frame(height: 50)

                LocationDetailItem(title: "Aisle", value: book.aisle, icon: "arrow.left.and.right")

                Divider().frame(height: 50)

                LocationDetailItem(title: "Shelf", value: book.displayCallNumber, icon: "list.dash")
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.Layout.cornerRadius)
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
            return [Color(hex: "7048E8"), Color(hex: "9775FA")]
        default:
            return [Theme.Colors.primary, Theme.Colors.primaryLight]
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
                .foregroundColor(Theme.Colors.accent)

            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Theme.Colors.textSecondary)
                .textCase(.uppercase)

            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Theme.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
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
            .environmentObject(ReservationService.shared)
    }
}
