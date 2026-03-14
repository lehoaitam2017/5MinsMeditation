//
//  _MinsMeditationApp.swift
//  5MinsMeditation
//
//  Created by Tam Le on 3/14/26.
//

import SwiftUI
import SwiftData

@main
struct _MinsMeditationApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}

private struct RootView: View {
    @State private var showsSplash = true

    var body: some View {
        ZStack {
            ContentView()
                .opacity(showsSplash ? 0 : 1)

            if showsSplash {
                SplashScreenView()
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
            }
        }
        .task {
            guard showsSplash else { return }
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.easeInOut(duration: 0.45)) {
                showsSplash = false
            }
        }
    }
}

private struct SplashScreenView: View {
    private let deepBlue = Color(red: 30 / 255, green: 58 / 255, blue: 95 / 255)
    private let skyBlue = Color(red: 74 / 255, green: 144 / 255, blue: 226 / 255)
    private let softRed = Color(red: 232 / 255, green: 93 / 255, blue: 117 / 255)
    private let coral = Color(red: 242 / 255, green: 139 / 255, blue: 130 / 255)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [deepBlue, skyBlue, softRed],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(coral.opacity(0.22))
                .frame(width: 260, height: 260)
                .blur(radius: 30)
                .offset(x: 110, y: -200)

            Circle()
                .fill(skyBlue.opacity(0.22))
                .frame(width: 220, height: 220)
                .blur(radius: 24)
                .offset(x: -120, y: 240)

            VStack(spacing: 22) {
                MeditationBrandIcon(size: 112)

                VStack(spacing: 10) {
                    Text("5-Minute Meditation Timer")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Breathe in. Let go.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.84))
                }
            }
            .padding(32)
        }
    }
}
