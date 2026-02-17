//
//  Theme.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 2/17/26.
//

// File defines the app's visual identity — colors,fonts, and reusable style constants.

import SwiftUI

// MARK: App Theme
enum Theme {
    
    // MARK: Colors
    enum Colors {
        // Primary brand colors — Rust College Royal Blue
        static let primary = Color(hex: "1A3C8B")       // Royal blue — main brand color
        static let primaryLight = Color(hex: "2E5FBF")   // Lighter blue for hover/active states
        static let primaryDark = Color(hex: "0F2557")    // Deep navy for headers/emphasis
        
        // Accent colors — warm gold/amber to complement royal blue
        static let accent = Color(hex: "D4952A")         // Rich gold — calls to action, highlights
        static let accentLight = Color(hex: "F0B95A")    // Soft amber — secondary highlights
        
        // Neutral colors
        static let background = Color(hex: "F7F8FC")     // Very light blue-tinted white
        static let surface = Color(hex: "FFFFFF")         // Pure white for cards
        static let surfaceSecondary = Color(hex: "EDF0F7") // Light blue-gray for subtle contrast
        
        // Text colors
        static let textPrimary = Color(hex: "1A1A2E")    // Near-black with blue undertone
        static let textSecondary = Color(hex: "6B7294")   // Blue-gray for secondary text
        static let textOnPrimary = Color(hex: "FFFFFF")   // White text on blue backgrounds
        
        // Status colors
        static let success = Color(hex: "22C55E")         // Green — available
        static let warning = Color(hex: "F59E0B")         // Amber — due soon
        static let error = Color(hex: "EF4444")           // Red — overdue
        
        // Availability badge colors
        static let availableBg = Color(hex: "DCFCE7")     // Light green background
        static let availableText = Color(hex: "166534")    // Dark green text
        static let checkedOutBg = Color(hex: "FEE2E2")    // Light red background
        static let checkedOutText = Color(hex: "991B1B")   // Dark red text
    }
    
    // MARK: Fonts
    enum Fonts {
        static let largeTitle = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title = Font.system(size: 22, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 16, weight: .semibold, design: .default)
        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let subheadline = Font.system(size: 14, weight: .regular, design: .default)
        static let caption = Font.system(size: 12, weight: .medium, design: .default)
    }
    
    // MARK: Layout
    enum Layout {
        static let paddingSmall: CGFloat = 8
        static let paddingMedium: CGFloat = 16
        static let paddingLarge: CGFloat = 24
        static let cornerRadius: CGFloat = 12
        static let cornerRadiusSmall: CGFloat = 8
        static let cardShadowRadius: CGFloat = 8
    }
}

// MARK: Color Extension for Hex Strings

/// This extension lets us create SwiftUI Colors from hex strings like "1A3C8B"
extension Color {
    init(hex: String) {
        // Remove the # if someone includes it
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        
        // Parse the hex string into a number
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        // Extract red, green, blue components
        let r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (most common: "1A3C8B")
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (with alpha: "FF1A3C8B")
            (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        
        // Create the color (values need to be 0.0 to 1.0, so divide by 255)
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}
