//
//  BookRowView.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 2/16/26.
//

import SwiftUI

struct BookRowView: View {
    let book: Book
    
    var body: some View {
        HStack(spacing: 12) {
            // Book cover placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.2))
                .frame(width: 50, height: 70)
                .overlay(
                    Image(systemName: "book.closed.fill")
                        .foregroundColor(.blue)
                )
            
            // Book info
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text(book.locationDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Availability badge
            Text(book.isAvailable ? "Available" : "Checked Out")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(book.isAvailable ? .green : .red)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(book.isAvailable ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                )
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    BookRowView(book: Book(
        title: "Introduction to Algorithms",
        author: "Thomas H. Cormen",
        isbn: "978-0262033848",
        genre: "Computer Science",
        floor: 2,
        section: "CS",
        aisle: "A3",
        shelf: "S12"
    ))
    .padding()
}

