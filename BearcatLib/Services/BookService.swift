//
//  BookService.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 3/25/26.
//

import Foundation
import Combine
import FirebaseFirestore

class BookService: ObservableObject {

    // MARK: - Singleton
    static let shared = BookService()

    // MARK: - Published State
    @Published var allBooks: [Book] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private
    private let db = Firestore.firestore()
    private let collectionName = "books"
    private var listener: ListenerRegistration?

    private init() {}

    // MARK: - Listener Lifecycle

    /// Start listening to the books collection. Call once after authentication.
    func startListening() {
        guard listener == nil else { return }
        isLoading = true
        errorMessage = nil

        listener = db.collection(collectionName)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Failed to load books: \(error.localizedDescription)"
                    print("BookService error: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    self.errorMessage = "No books found."
                    return
                }

                self.allBooks = documents.compactMap { doc in
                    self.parseBook(from: doc)
                }

                print("BookService: loaded \(self.allBooks.count) books")
            }
    }

    /// Stop listening. Call on sign-out.
    func stopListening() {
        listener?.remove()
        listener = nil
        allBooks = []
    }

    // MARK: - Document Parsing

    /// Manually maps a Firestore document to a Book.
    /// This approach avoids needing @DocumentID on the Book model,
    /// keeping full backward compatibility with SampleData.
    private func parseBook(from doc: QueryDocumentSnapshot) -> Book? {
        let data = doc.data()

        guard let title = data["title"] as? String else { return nil }

        let author = data["author"] as? String ?? "Unknown Author"
        let isbn = data["isbn"] as? String ?? ""
        let genre = data["genre"] as? String ?? "General"
        let description = data["description"] as? String ?? "\(title) by \(author)"
        let floor = data["floor"] as? Int ?? 1
        let section = data["section"] as? String ?? ""
        let aisle = data["aisle"] as? String ?? ""
        let shelf = data["shelf"] as? String ?? ""
        let isAvailable = data["isAvailable"] as? Bool ?? true
        let callNumber = data["callNumber"] as? String
        let collectionName = data["collectionName"] as? String
        let branchName = data["branchName"] as? String
        let resourceId = data["resourceId"] as? Int
        let barcode = data["barcode"] as? String
        let status = data["status"] as? String
        let lastUpdated = data["lastUpdated"] as? String
        let source = data["source"] as? String

        // Parse dueDate string into a Date object
        var dueDate: Date? = nil
        if let dueDateStr = data["dueDate"] as? String, !dueDateStr.isEmpty {
            let isoFormatter = ISO8601DateFormatter()
            dueDate = isoFormatter.date(from: dueDateStr)
        }

        return Book(
            title: title,
            author: author,
            isbn: isbn,
            genre: genre,
            description: description,
            floor: floor,
            section: section,
            aisle: aisle,
            shelf: shelf,
            isAvailable: isAvailable,
            dueDate: dueDate,
            firestoreId: doc.documentID,
            resourceId: resourceId,
            barcode: barcode,
            callNumber: callNumber,
            collectionName: collectionName,
            branchName: branchName,
            status: status,
            lastUpdated: lastUpdated,
            source: source
        )
    }

    // MARK: - Computed Filters

    /// All unique genres from the catalog, sorted alphabetically.
    var genres: [String] {
        Array(Set(allBooks.map { $0.genre })).sorted()
    }

    /// Only books currently available.
    var availableBooks: [Book] {
        allBooks.filter { $0.isAvailable }
    }

    /// Only books currently checked out.
    var checkedOutBooks: [Book] {
        allBooks.filter { !$0.isAvailable }
    }

    // MARK: - Search & Filter

    /// Filter by genre and search text.
    func filter(genre: String, searchText: String = "") -> [Book] {
        var results = allBooks

        if genre != "All" {
            results = results.filter { $0.genre == genre }
        }

        if !searchText.isEmpty {
            let lowered = searchText.lowercased()
            results = results.filter { book in
                book.title.lowercased().contains(lowered) ||
                book.author.lowercased().contains(lowered) ||
                book.isbn.lowercased().contains(lowered)
            }
        }

        return results
    }

    /// Fetch a single book by Firestore document ID.
    func fetchBook(id: String, completion: @escaping (Book?) -> Void) {
        db.collection(collectionName).document(id).getDocument { [weak self] snapshot, error in
            guard let self = self, let snapshot = snapshot, snapshot.exists else {
                completion(nil)
                return
            }
            // Re-use the same parsing logic
            let data = snapshot.data() ?? [:]
            let fakeDoc = snapshot
            // For single-doc fetch, parse manually
            let title = data["title"] as? String ?? ""
            let author = data["author"] as? String ?? "Unknown Author"
            let isbn = data["isbn"] as? String ?? ""
            let genre = data["genre"] as? String ?? "General"
            let description = data["description"] as? String ?? ""
            let floor = data["floor"] as? Int ?? 1
            let section = data["section"] as? String ?? ""
            let aisle = data["aisle"] as? String ?? ""
            let shelf = data["shelf"] as? String ?? ""
            let isAvailable = data["isAvailable"] as? Bool ?? true
            let callNumber = data["callNumber"] as? String
            let resourceId = data["resourceId"] as? Int

            let book = Book(
                title: title,
                author: author,
                isbn: isbn,
                genre: genre,
                description: description,
                floor: floor,
                section: section,
                aisle: aisle,
                shelf: shelf,
                isAvailable: isAvailable,
                firestoreId: snapshot.documentID,
                resourceId: resourceId,
                callNumber: callNumber
            )
            completion(book)
        }
    }
}
