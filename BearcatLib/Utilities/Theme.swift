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
        
        // Dark mode variants
        static let backgroundDark = Color(hex: "111318")
        static let surfaceDark = Color(hex: "1C1E26")
        static let surfaceSecondaryDark = Color(hex: "252833")
        static let textPrimaryDark = Color(hex: "E8EAF0")
        static let textSecondaryDark = Color(hex: "8B90AD")
        static let availableBgDark = Color(hex: "14532D")
        static let availableTextDark = Color(hex: "86EFAC")
        static let checkedOutBgDark = Color(hex: "7F1D1D")
        static let checkedOutTextDark = Color(hex: "FCA5A5")
    }
    
    // MARK: Fonts
    enum Fonts {
        // Upgraded to Avenir Next for a premium, geometric UI look
        static let largeTitle = Font.custom("AvenirNext-Bold", size: 32)
        static let title = Font.custom("AvenirNext-Bold", size: 24)
        static let title2 = Font.custom("AvenirNext-DemiBold", size: 20)
        static let headline = Font.custom("AvenirNext-DemiBold", size: 16)
        static let body = Font.custom("AvenirNext-Regular", size: 16)
        static let subheadline = Font.custom("AvenirNext-Medium", size: 14)
        static let caption = Font.custom("AvenirNext-Medium", size: 12)
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
    
    // MARK: - Adaptive Color Helper
    enum AdaptiveColors {
        static func background(_ isDark: Bool) -> Color {
            isDark ? Theme.Colors.backgroundDark : Theme.Colors.background
        }
        static func surface(_ isDark: Bool) -> Color {
            isDark ? Theme.Colors.surfaceDark : Theme.Colors.surface
        }
        static func surfaceSecondary(_ isDark: Bool) -> Color {
            isDark ? Theme.Colors.surfaceSecondaryDark : Theme.Colors.surfaceSecondary
        }
        static func textPrimary(_ isDark: Bool) -> Color {
            isDark ? Theme.Colors.textPrimaryDark : Theme.Colors.textPrimary
        }
        static func textSecondary(_ isDark: Bool) -> Color {
            isDark ? Theme.Colors.textSecondaryDark : Theme.Colors.textSecondary
        }
        static func availableBg(_ isDark: Bool) -> Color {
            isDark ? Theme.Colors.availableBgDark : Theme.Colors.availableBg
        }
        static func availableText(_ isDark: Bool) -> Color {
            isDark ? Theme.Colors.availableTextDark : Theme.Colors.availableText
        }
        static func checkedOutBg(_ isDark: Bool) -> Color {
            isDark ? Theme.Colors.checkedOutBgDark : Theme.Colors.checkedOutBg
        }
        static func checkedOutText(_ isDark: Bool) -> Color {
            isDark ? Theme.Colors.checkedOutTextDark : Theme.Colors.checkedOutText
        }
        static func cardShadow(_ isDark: Bool) -> Color {
            isDark ? Color.clear : Theme.Colors.textPrimary.opacity(0.04)
        }
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
