////
////  BearcatLibLogo.swift
////  BearcatLib
////
////  Created by Joseph Musenge on 3/12/26.
////

// PURPOSE: App logo — A hyper-modern, minimalist geometric design representing "MyBearcatLib" with leaning books on a shelf inside a premium iOS squircle

import SwiftUI

struct BearcatLibLogo: View {
    var size: CGFloat = 80
    var showTitle: Bool = false
    
    var body: some View {
        VStack(spacing: size * 0.15) {
            
            // MARK: - Premium iOS App Icon Shape
            ZStack {
                // Background Squircle (Apple's continuous curve style)
                RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Theme.Colors.primaryLight, Theme.Colors.primaryDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    // Deep, soft shadow for 3D depth
                    .shadow(color: Theme.Colors.primary.opacity(0.35), radius: size * 0.15, x: 0, y: size * 0.1)
                
                // MARK: - The "MyBearcatLib" Geometric Books
                HStack(alignment: .bottom, spacing: size * 0.08) {
                    // Left Book (Clean White)
                    RoundedRectangle(cornerRadius: size * 0.04)
                        .fill(Color.white)
                        .frame(width: size * 0.14, height: size * 0.45)
                    
                    // Middle Book (Rust College Gold Accent)
                    RoundedRectangle(cornerRadius: size * 0.04)
                        .fill(Theme.Colors.accent)
                        .frame(width: size * 0.14, height: size * 0.55)
                    
                    // Right Book (Leaning, translucent white)
                    RoundedRectangle(cornerRadius: size * 0.04)
                        .fill(Color.white.opacity(0.6))
                        .frame(width: size * 0.14, height: size * 0.48)
                        .rotationEffect(.degrees(16), anchor: .bottomLeading)
                        .offset(x: -size * 0.03) // Pull it in so it rests on the middle book
                }
                .offset(y: size * 0.05) // Push down slightly to balance the composition
                
                // MARK: - Digital "Sync" Dot
                Circle()
                    .fill(Theme.Colors.accent)
                    .frame(width: size * 0.12, height: size * 0.12)
                    .offset(x: size * 0.22, y: -size * 0.22)
            }
            
            // MARK: - Typography Lockup
            if showTitle {
                VStack(spacing: size * 0.03) {
                    Text("MyBearcatLib")
                        .font(Font.custom("AvenirNext-Bold", size: size * 0.35))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text("LEONTYNE PRICE LIBRARY")
                        .font(Font.custom("AvenirNext-Bold", size: size * 0.12))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .tracking(2.0) // Extremely modern, wide letter spacing
                }
                .padding(.top, size * 0.05)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Theme.Colors.background.ignoresSafeArea()
        
        VStack(spacing: 60) {
            // Large size for the Login Screen
            BearcatLibLogo(size: 110, showTitle: true)
            
            // Small size for internal app headers/menus
            BearcatLibLogo(size: 50, showTitle: false)
        }
    }
}
