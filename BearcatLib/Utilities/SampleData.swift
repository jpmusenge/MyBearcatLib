//
//  SampleData.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 2/17/26.
//

// PURPOSE: Realistic mock data so the app looks populated during

import Foundation

enum SampleData {
    
    /// A collection of books for the Leontyne Price Library
    static let books: [Book] = [
        
        // Computer Science
        Book(
            title: "Introduction to Algorithms",
            author: "Thomas H. Cormen",
            isbn: "978-0262033848",
            genre: "Computer Science",
            description: "A comprehensive textbook covering a broad range of algorithms in depth, yet makes their design and analysis accessible to all levels of readers.",
            floor: 2,
            section: "CS",
            aisle: "A3",
            shelf: "S12",
            isAvailable: true
        ),
        Book(
            title: "Clean Code",
            author: "Robert C. Martin",
            isbn: "978-0132350884",
            genre: "Computer Science",
            description: "A handbook of agile software craftsmanship. Even bad code can function. But if code isn't clean, it can bring a development organization to its knees.",
            floor: 2,
            section: "CS",
            aisle: "A3",
            shelf: "S14",
            isAvailable: false,
            dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())
        ),
        Book(
            title: "Computer Networking: A Top-Down Approach",
            author: "James Kurose",
            isbn: "978-0133594140",
            genre: "Computer Science",
            description: "Builds on the successful top-down approach, beginning with the application layer and encouraging a hands-on experience with protocols and networking concepts.",
            floor: 2,
            section: "CS",
            aisle: "A4",
            shelf: "S8",
            isAvailable: true
        ),
        Book(
            title: "Operating System Concepts",
            author: "Abraham Silberschatz",
            isbn: "978-1119800361",
            genre: "Computer Science",
            description: "Covers all core OS concepts including process management, memory, storage, and security. The standard textbook for operating systems courses.",
            floor: 2,
            section: "CS",
            aisle: "A3",
            shelf: "S15",
            isAvailable: true
        ),
        
        // Mathematics
        Book(
            title: "Calculus: Early Transcendentals",
            author: "James Stewart",
            isbn: "978-1285741550",
            genre: "Mathematics",
            description: "Widely renowned for its mathematical precision and accuracy, clarity of exposition, and outstanding examples and problem sets.",
            floor: 2,
            section: "MATH",
            aisle: "A1",
            shelf: "S5",
            isAvailable: true
        ),
        Book(
            title: "Discrete Mathematics and Its Applications",
            author: "Kenneth Rosen",
            isbn: "978-0073383095",
            genre: "Mathematics",
            description: "A focused introduction to the primary themes in discrete mathematics: mathematical reasoning, combinatorial analysis, discrete structures, and algorithmic thinking.",
            floor: 2,
            section: "MATH",
            aisle: "A1",
            shelf: "S8",
            isAvailable: false,
            dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())
        ),
        
        // Literature
        Book(
            title: "The Souls of Black Folk",
            author: "W.E.B. Du Bois",
            isbn: "978-0486280417",
            genre: "Literature",
            description: "A foundational work in the history of sociology and a cornerstone of African-American literature. Du Bois examines the \"double consciousness\" of Black Americans.",
            floor: 1,
            section: "LIT",
            aisle: "B1",
            shelf: "S3",
            isAvailable: true
        ),
        Book(
            title: "Beloved",
            author: "Toni Morrison",
            isbn: "978-1400033416",
            genre: "Literature",
            description: "Winner of the Pulitzer Prize. A spellbinding and dazzlingly innovative portrait of a woman haunted by the past.",
            floor: 1,
            section: "LIT",
            aisle: "B2",
            shelf: "S7",
            isAvailable: false,
            dueDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()) // Overdue!
        ),
        Book(
            title: "The Color Purple",
            author: "Alice Walker",
            isbn: "978-0156028356",
            genre: "Literature",
            description: "Winner of the Pulitzer Prize and the National Book Award. A novel about a young African-American woman growing up in the rural South.",
            floor: 1,
            section: "LIT",
            aisle: "B2",
            shelf: "S9",
            isAvailable: true
        ),
        
        // Other Subjects
        Book(
            title: "A People's History of the United States",
            author: "Howard Zinn",
            isbn: "978-0062397348",
            genre: "History",
            description: "Tells America's story from the point of view of its women, factory workers, African Americans, Native Americans, and working poor.",
            floor: 1,
            section: "HIST",
            aisle: "C2",
            shelf: "S4",
            isAvailable: true
        ),
        Book(
            title: "Thinking, Fast and Slow",
            author: "Daniel Kahneman",
            isbn: "978-0374533557",
            genre: "Psychology",
            description: "Nobel laureate Daniel Kahneman takes us on a groundbreaking tour of the mind and explains the two systems that drive the way we think.",
            floor: 1,
            section: "PSYCH",
            aisle: "D1",
            shelf: "S3",
            isAvailable: true
        ),
        Book(
            title: "Principles of Economics",
            author: "N. Gregory Mankiw",
            isbn: "978-0357038314",
            genre: "Business",
            description: "The most popular and widely used economics textbook, providing current and relevant coverage of economic concepts.",
            floor: 1,
            section: "BUS",
            aisle: "E2",
            shelf: "S6",
            isAvailable: false,
            dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())
        ),
    ]
    
    // MARK: Computed Helpers
    // All unique genres from the sample books, sorted alphabetically
    static var genres: [String] {
        Array(Set(books.map { $0.genre })).sorted()
    }
    
    /// Only books that are currently available
    static var availableBooks: [Book] {
        books.filter { $0.isAvailable }
    }
    
    /// Only books that are checked out
    static var checkedOutBooks: [Book] {
        books.filter { !$0.isAvailable }
    }
}
