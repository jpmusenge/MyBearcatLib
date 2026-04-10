//
//  BookCardView.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 2/17/26.
//

// PURPOSE: A card component that displays one book in the grid
import Foundation
import SwiftUI

struct BookCardView: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // MARK: - Book Cover
            ZStack(alignment: .topTrailing) {
                // Book Cover — real image or gradient fallback
                bookCoverContent

                // Availability Badge
                if book.isAvailable {
                    Text("Available")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Theme.Colors.availableText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Theme.Colors.availableBg)
                        .clipShape(Capsule())
                        .padding(8)
                } else {
                    Text("Checked Out")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Theme.Colors.checkedOutText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Theme.Colors.checkedOutBg)
                        .clipShape(Capsule())
                        .padding(8)
                }
            }
            .frame(width: 140, height: 210) // Standard 2:3 physical book aspect ratio
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Theme.Colors.textPrimary.opacity(0.08), radius: 8, x: 0, y: 4)
            
            // MARK: - Book Details
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(Theme.Fonts.headline)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    // Fixed height ensures the cards align perfectly in horizontal carousels
                    .frame(height: 42, alignment: .topLeading)
                
                Text(book.author)
                    .font(Theme.Fonts.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .lineLimit(1)
                
                // Location badge directly addressing student pain points
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 10, weight: .bold))
                    Text("Flr \(book.floor), \(book.section)-\(book.aisle)")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(Theme.Colors.accent) // Rust College gold accent
                .padding(.top, 4)
            }
            .frame(width: 140, alignment: .leading)
        }
    }
    
    // MARK: - Book Cover

    @ViewBuilder
    private var bookCoverContent: some View {
        let isbn = book.isbn.replacingOccurrences(of: "-", with: "")
        if !isbn.isEmpty, let url = URL(string: "https://covers.openlibrary.org/b/isbn/\(isbn)-M.jpg") {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    fallbackCover
                case .empty:
                    fallbackCover
                @unknown default:
                    fallbackCover
                }
            }
        } else {
            fallbackCover
        }
    }

    private var fallbackCover: some View {
        ZStack {
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
                    .font(.system(size: 65, weight: .bold, design: .serif))
                    .foregroundColor(.white.opacity(0.25))
                Spacer()
            }
            .frame(maxWidth: .infinity)

            Image(systemName: genreIcon(for: book.genre))
                .font(.system(size: 28, weight: .light))
                .foregroundColor(.white.opacity(0.4))
                .padding(14)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
    }

    // MARK: - Helpers
    private func gradientColors(for genre: String) -> [Color] {
        // Soft gradients that look like premium book covers
        switch genre {
        case "Computer Science": return [Color(hex: "3B5BDB"), Color(hex: "5C7CFA")]
        case "Mathematics":      return [Color(hex: "D6336C"), Color(hex: "F06595")]
        case "Literature":       return [Color(hex: "0C8599"), Color(hex: "22B8CF")]
        case "History":          return [Color(hex: "099268"), Color(hex: "20C997")]
        case "Science":          return [Color(hex: "E8590C"), Color(hex: "FD7E14")]
        case "Business":         return [Color(hex: "7048E8"), Color(hex: "9775FA")]
        case "Psychology":       return [Color(hex: "F08C00"), Color(hex: "FCC419")]
        default:                 return [Theme.Colors.primary, Theme.Colors.primaryLight]
        }
    }
    
    private func genreIcon(for genre: String) -> String {
        switch genre {
        case "Computer Science": return "laptopcomputer"
        case "Mathematics":      return "x.squareroot"
        case "Literature":       return "books.vertical.fill"
        case "History":          return "building.columns.fill"
        case "Science":          return "atom"
        case "Business":         return "chart.bar.fill"
        case "Psychology":       return "brain.head.profile"
        default:                 return "book.closed.fill"
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(alignment: .top, spacing: 20) {
            // First book in Sample Data (Available)
            BookCardView(book: SampleData.books[0])
            
            // Second book in Sample Data (Checked Out)
            BookCardView(book: SampleData.books[1])
            
            // Third book
            BookCardView(book: SampleData.books[2])
        }
        .padding(24)
    }
    // Set the background to your theme's background so the card shadows pop
    .background(Theme.Colors.background)
}
