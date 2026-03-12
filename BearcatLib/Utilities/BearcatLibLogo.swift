//
//  BearcatLibLogo.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 3/12/26.
//

// PURPOSE: App logo — shield shape inspired by Rust College Bearcat badge with book icon

import SwiftUI

// MARK: - Shield Shape

struct ShieldShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let r: CGFloat = w * 0.1 // top corner radius

        var path = Path()

        // Top-left corner
        path.move(to: CGPoint(x: r, y: 0))

        // Top edge
        path.addLine(to: CGPoint(x: w - r, y: 0))

        // Top-right rounded corner
        path.addQuadCurve(
            to: CGPoint(x: w, y: r),
            control: CGPoint(x: w, y: 0)
        )

        // Right side going down
        path.addLine(to: CGPoint(x: w, y: h * 0.5))

        // Right curve sweeping down to bottom point
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control1: CGPoint(x: w, y: h * 0.68),
            control2: CGPoint(x: w * 0.7, y: h * 0.9)
        )

        // Left curve sweeping up from bottom point
        path.addCurve(
            to: CGPoint(x: 0, y: h * 0.5),
            control1: CGPoint(x: w * 0.3, y: h * 0.9),
            control2: CGPoint(x: 0, y: h * 0.68)
        )

        // Left side going up
        path.addLine(to: CGPoint(x: 0, y: r))

        // Top-left rounded corner
        path.addQuadCurve(
            to: CGPoint(x: r, y: 0),
            control: CGPoint(x: 0, y: 0)
        )

        path.closeSubpath()
        return path
    }
}

// MARK: - Logo Component

struct BearcatLibLogo: View {
    var size: CGFloat = 80

    var body: some View {
        ZStack {
            // Shield fill
            ShieldShape()
                .fill(
                    LinearGradient(
                        colors: [Theme.Colors.primaryLight, Theme.Colors.primaryDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size * 1.15)

            // Subtle inner border
            ShieldShape()
                .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                .frame(width: size - 6, height: size * 1.15 - 6)

            // Book icon — references the open book on the Rust College seal
            Image(systemName: "book.fill")
                .font(.system(size: size * 0.33, weight: .medium))
                .foregroundColor(.white)
                .offset(y: -size * 0.02)

            // Small gold accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(Theme.Colors.accent)
                .frame(width: size * 0.3, height: 3)
                .offset(y: size * 0.32)
        }
        .shadow(color: Theme.Colors.primary.opacity(0.25), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 32) {
        BearcatLibLogo(size: 80)

        BearcatLibLogo(size: 60)

        // Full branding lockup
        VStack(spacing: 12) {
            BearcatLibLogo(size: 80)
            Text("BearcatLib")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(Theme.Colors.primary)
            Text("Leontyne Price Library")
                .font(Theme.Fonts.subheadline)
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
    .padding()
}
