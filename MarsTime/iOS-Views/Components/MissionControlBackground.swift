// MissionControlBackground.swift
// Mars Clock System - iOS Background Component
// NASA/JPL Flight Software Standard

import SwiftUI

struct MissionControlBackground: View {
    var body: some View {
        ZStack {
            // Base color
            Color.black.ignoresSafeArea()

            // Subtle grid
            GeometryReader { geometry in
                Path { path in
                    let spacing: CGFloat = 40
                    let width = geometry.size.width
                    let height = geometry.size.height

                    // Vertical lines
                    for x in stride(from: 0, through: width, by: spacing) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: height))
                    }

                    // Horizontal lines
                    for y in stride(from: 0, through: height, by: spacing) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                }
                .stroke(Color.white.opacity(0.02), lineWidth: 0.5)
            }

            // Vignette
            RadialGradient(
                colors: [.clear, .black.opacity(0.5)],
                center: .center,
                startRadius: 200,
                endRadius: 500
            )
            .ignoresSafeArea()
        }
    }
}
