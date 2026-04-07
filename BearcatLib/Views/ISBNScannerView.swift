//
//  ISBNScannerView.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 3/31/26.
//

// PURPOSE: Full ISBN scanner flow — camera viewfinder → scan barcode → show book result

import SwiftUI

struct ISBNScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var bookService: BookService
    @EnvironmentObject var settings: AppSettings

    @State private var scannedISBN: String?
    @State private var matchedBooks: [Book] = []
    @State private var scanState: ScanState = .scanning

    private var dk: Bool { settings.isDarkMode }

    enum ScanState {
        case scanning
        case found
        case notFound
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Camera layer (always present behind content)
                if scanState == .scanning {
                    scannerView
                } else if scanState == .found, let book = matchedBooks.first {
                    resultFoundView(book: book)
                } else if scanState == .notFound {
                    resultNotFoundView
                }
            }
            .navigationTitle(scanState == .scanning ? "Scan ISBN" : "Scan Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(scanState == .scanning ? .white : Theme.Colors.primary)
                }

                if scanState != .scanning {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Scan Again") { resetScanner() }
                            .foregroundColor(Theme.Colors.primary)
                    }
                }
            }
            .toolbarBackground(scanState == .scanning ? .hidden : .visible, for: .navigationBar)
        }
    }

    // MARK: - Scanner View

    private var scannerView: some View {
        ZStack {
            // Camera feed
            BarcodeScannerUIView { isbn in
                handleScan(isbn)
            }
            .ignoresSafeArea()

            // Overlay with viewfinder
            VStack {
                Spacer()

                // Viewfinder frame
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 280, height: 160)

                    // Corner accents
                    ViewfinderCorners()
                        .frame(width: 280, height: 160)
                }

                Spacer().frame(height: 40)

                // Instructions
                VStack(spacing: 8) {
                    Text("Point camera at book barcode")
                        .font(Theme.Fonts.headline)
                        .foregroundColor(.white)

                    Text("Align the ISBN barcode within the frame")
                        .font(Theme.Fonts.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 32)
                .multilineTextAlignment(.center)

                Spacer().frame(height: 60)

                // Manual entry option
                Button {
                    // Could add manual ISBN entry here in the future
                } label: {
                    Label("Enter ISBN manually", systemImage: "keyboard")
                        .font(Theme.Fonts.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 32)
            }

            // Dark overlay outside viewfinder
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .mask(
                    Rectangle()
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .frame(width: 280, height: 160)
                                .blendMode(.destinationOut)
                        )
                        .compositingGroup()
                )
                .allowsHitTesting(false)
        }
    }

    // MARK: - Result Found View

    private func resultFoundView(book: Book) -> some View {
        let copies = matchedBooks
        let available = copies.filter { $0.isAvailable }.count
        let total = copies.count

        return ScrollView {
            VStack(spacing: 24) {
                // Success indicator
                ZStack {
                    Circle()
                        .fill(Theme.Colors.success.opacity(0.1))
                        .frame(width: 80, height: 80)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Theme.Colors.success)
                }
                .padding(.top, 20)

                Text("Book Found!")
                    .font(Theme.Fonts.title)

                // Scanned ISBN
                Text("ISBN: \(scannedISBN ?? "")")
                    .font(Theme.Fonts.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(UIColor.tertiarySystemFill))
                    .cornerRadius(8)

                // Book info card
                VStack(alignment: .leading, spacing: 16) {
                    // Title & Author
                    VStack(alignment: .leading, spacing: 4) {
                        Text(book.title)
                            .font(Theme.Fonts.title2)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(book.author)
                            .font(Theme.Fonts.body)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // Availability
                    HStack(spacing: 12) {
                        Image(systemName: available > 0 ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(available > 0 ? Theme.Colors.success : Theme.Colors.error)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(available > 0 ? "Available" : "All Copies Checked Out")
                                .font(Theme.Fonts.headline)
                                .foregroundColor(available > 0 ? Theme.Colors.success : Theme.Colors.error)

                            Text("\(available) of \(total) \(total == 1 ? "copy" : "copies") available")
                                .font(Theme.Fonts.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Divider()

                    // Location
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Location", systemImage: "mappin.and.ellipse")
                            .font(Theme.Fonts.headline)

                        HStack(spacing: 16) {
                            LocationPill(label: "Floor", value: "\(book.floor)")
                            LocationPill(label: "Section", value: book.section)
                            if !book.aisle.isEmpty {
                                LocationPill(label: "Aisle", value: book.aisle)
                            }
                        }

                        if let callNumber = book.callNumber, !callNumber.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "number")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Call #: \(callNumber)")
                                    .font(Theme.Fonts.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Divider()

                    // Details
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Details", systemImage: "info.circle")
                            .font(Theme.Fonts.headline)

                        DetailRow(label: "Genre", value: book.genre)
                        DetailRow(label: "ISBN", value: book.isbn)
                        if let collection = book.collectionName, !collection.isEmpty {
                            DetailRow(label: "Collection", value: collection)
                        }
                    }
                }
                .padding(20)
                .background(AdaptiveColors.surface(dk))
                .cornerRadius(16)
                .shadow(color: AdaptiveColors.cardShadow(dk), radius: 8, x: 0, y: 4)
                .padding(.horizontal, Theme.Layout.paddingLarge)

                // View Full Details button
                NavigationLink {
                    BookDetailView(book: book)
                        .environmentObject(settings)
                } label: {
                    Text("View Full Details")
                        .font(Theme.Fonts.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.Colors.primary)
                        .cornerRadius(Theme.Layout.cornerRadius)
                }
                .padding(.horizontal, Theme.Layout.paddingLarge)

                Spacer().frame(height: 20)
            }
        }
        .background(AdaptiveColors.background(dk).ignoresSafeArea())
    }

    // MARK: - Not Found View

    private var resultNotFoundView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Theme.Colors.error.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: "book.closed.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Theme.Colors.error.opacity(0.6))
            }

            Text("Book Not Found")
                .font(Theme.Fonts.title)

            Text("ISBN: \(scannedISBN ?? "")")
                .font(Theme.Fonts.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(UIColor.tertiarySystemFill))
                .cornerRadius(8)

            Text("This book isn't in the Leontyne Price Library catalog. It may be a different edition or not yet cataloged.")
                .font(Theme.Fonts.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                resetScanner()
            } label: {
                Text("Try Another Scan")
                    .font(Theme.Fonts.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.Colors.primary)
                    .cornerRadius(Theme.Layout.cornerRadius)
            }
            .padding(.horizontal, Theme.Layout.paddingLarge)

            Spacer()
        }
        .background(AdaptiveColors.background(dk).ignoresSafeArea())
    }

    // MARK: - Helpers

    private func handleScan(_ isbn: String) {
        scannedISBN = isbn
        let results = bookService.findByISBN(isbn)

        if results.isEmpty {
            scanState = .notFound
        } else {
            matchedBooks = results
            scanState = .found
        }
    }

    private func resetScanner() {
        scannedISBN = nil
        matchedBooks = []
        scanState = .scanning
    }
}

// MARK: - Viewfinder Corners

private struct ViewfinderCorners: View {
    var body: some View {
        ZStack {
            // Top-left
            CornerShape()
                .stroke(Theme.Colors.accent, lineWidth: 4)
                .frame(width: 30, height: 30)
                .position(x: 15, y: 15)

            // Top-right
            CornerShape()
                .stroke(Theme.Colors.accent, lineWidth: 4)
                .frame(width: 30, height: 30)
                .rotationEffect(.degrees(90))
                .position(x: 265, y: 15)

            // Bottom-left
            CornerShape()
                .stroke(Theme.Colors.accent, lineWidth: 4)
                .frame(width: 30, height: 30)
                .rotationEffect(.degrees(-90))
                .position(x: 15, y: 145)

            // Bottom-right
            CornerShape()
                .stroke(Theme.Colors.accent, lineWidth: 4)
                .frame(width: 30, height: 30)
                .rotationEffect(.degrees(180))
                .position(x: 265, y: 145)
        }
    }
}

private struct CornerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + rect.height))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width, y: rect.minY))
        return path
    }
}

// MARK: - Location Pill

private struct LocationPill: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(.subheadline, weight: .bold))
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 60)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(UIColor.tertiarySystemFill))
        .cornerRadius(10)
    }
}

// MARK: - Detail Row

private struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(Theme.Fonts.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(Theme.Fonts.subheadline)
        }
    }
}

#Preview {
    ISBNScannerView()
        .environmentObject(BookService.shared)
        .environmentObject(AppSettings())
}
