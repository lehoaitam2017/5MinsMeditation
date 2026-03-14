//
//  ContentView.swift
//  5MinsMeditation
//
//  Created by Tam Le on 3/14/26.
//

import SwiftUI

struct ContentView: View {
    private enum SessionState {
        case idle
        case active
        case complete
    }

    private enum FocusMode: CaseIterable {
        case calmMind
        case breathFocus

        var title: String {
            switch self {
            case .calmMind:
                return "Calm Mind"
            case .breathFocus:
                return "Breath Focus"
            }
        }

        var subtitle: String {
            switch self {
            case .calmMind:
                return "Settle your attention"
            case .breathFocus:
                return "Follow the pulse"
            }
        }

        var icon: String {
            switch self {
            case .calmMind:
                return "moon.stars.fill"
            case .breathFocus:
                return "wind"
            }
        }

        var accent: Color {
            switch self {
            case .calmMind:
                return Palette.skyBlue
            case .breathFocus:
                return Palette.softRed
            }
        }

        var sessionLabel: String {
            switch self {
            case .calmMind:
                return "Quiet Reset"
            case .breathFocus:
                return "Guided Breath"
            }
        }

        var idleMessage: String {
            switch self {
            case .calmMind:
                return "A single quiet session. No menus, no clutter, just space to breathe."
            case .breathFocus:
                return "A guided breathing rhythm with soft red cues to anchor your attention."
            }
        }
    }

    private enum BreathingPhase {
        case inhale
        case hold
        case exhale

        var title: String {
            switch self {
            case .inhale:
                return "Breathe In"
            case .hold:
                return "Hold"
            case .exhale:
                return "Breathe Out"
            }
        }

        var detail: String {
            switch self {
            case .inhale:
                return "Expand softly"
            case .hold:
                return "Stay steady"
            case .exhale:
                return "Release slowly"
            }
        }

        var scale: CGFloat {
            switch self {
            case .inhale:
                return 1.06
            case .hold:
                return 1.02
            case .exhale:
                return 0.94
            }
        }

        var glowColor: Color {
            switch self {
            case .inhale, .hold:
                return Palette.softRed
            case .exhale:
                return Palette.skyBlue
            }
        }
    }

    private enum Palette {
        static let deepBlue = Color(red: 30 / 255, green: 58 / 255, blue: 95 / 255)
        static let skyBlue = Color(red: 74 / 255, green: 144 / 255, blue: 226 / 255)
        static let paleBlue = Color(red: 234 / 255, green: 244 / 255, blue: 1.0)
        static let softRed = Color(red: 232 / 255, green: 93 / 255, blue: 117 / 255)
        static let coral = Color(red: 242 / 255, green: 139 / 255, blue: 130 / 255)
        static let darkText = Color(red: 31 / 255, green: 41 / 255, blue: 55 / 255)
        static let lightGray = Color(red: 217 / 255, green: 226 / 255, blue: 236 / 255)
    }

    private let sessionDuration: TimeInterval = 5 * 60
    private let breathingCycle: TimeInterval = 12

    @State private var sessionState: SessionState = .idle
    @State private var remainingTime: TimeInterval = 5 * 60
    @State private var sessionProgress: Double = 0
    @State private var sessionStartDate: Date?
    @State private var completedSessions = 3
    @State private var hasAppeared = false
    @State private var selectedMode: FocusMode = .calmMind

    var body: some View {
        ZStack {
            backgroundGradient

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    header
                    timerSection
                    controlsSection
                    bottomCards
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 32)
            }
        }
        .task(id: sessionState) {
            guard sessionState == .active else { return }
            await runSessionTimer()
        }
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            remainingTime = sessionDuration
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Palette.paleBlue,
                Color.white,
                Palette.paleBlue.opacity(0.92),
                Palette.coral.opacity(0.18)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(Palette.skyBlue.opacity(0.16))
                .frame(width: 220, height: 220)
                .blur(radius: 12)
                .offset(x: 80, y: -40)
        }
        .overlay(alignment: .bottomLeading) {
            Circle()
                .fill(Palette.softRed.opacity(0.12))
                .frame(width: 240, height: 240)
                .blur(radius: 18)
                .offset(x: -100, y: 100)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            if sessionState == .active {
                HStack {
                    Button {
                        endSession()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Palette.deepBlue)
                            .frame(width: 42, height: 42)
                            .background(.white.opacity(0.9), in: Circle())
                            .shadow(color: Palette.deepBlue.opacity(0.08), radius: 14, y: 8)
                    }

                    Spacer()

                    Text("Meditation in progress")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Palette.deepBlue)

                    Spacer()

                    Color.clear
                        .frame(width: 42, height: 42)
                }
            } else {
                Text(sessionState == .complete ? "Session Complete" : "5-Minute Timer")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Palette.darkText)

                Text(headerSubtitle)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Palette.darkText.opacity(0.65))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }

    private var timerSection: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.72))
                    .frame(width: 286, height: 286)
                    .shadow(color: Palette.deepBlue.opacity(0.08), radius: 30, y: 18)

                Circle()
                    .stroke(Palette.lightGray.opacity(0.8), lineWidth: 16)
                    .frame(width: 250, height: 250)

                Circle()
                    .trim(from: 0, to: max(0.02, sessionState == .complete ? 1 : 1 - sessionProgress))
                    .stroke(
                        AngularGradient(
                            colors: progressRingColors,
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 250, height: 250)

                if sessionState == .active && showsBreathingOrb {
                    Circle()
                        .fill(breathingOrbColor.opacity(breathingOrbOpacity))
                        .frame(width: 188, height: 188)
                        .blur(radius: selectedMode == .breathFocus ? 10 : 18)
                        .scaleEffect(breathingOrbScale)
                        .animation(.easeInOut(duration: breathingAnimationDuration), value: currentBreathingPhase)
                }

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .white,
                                .white.opacity(0.98),
                                Palette.paleBlue.opacity(0.8)
                            ],
                            center: .center,
                            startRadius: 12,
                            endRadius: 140
                        )
                    )
                    .frame(width: 208, height: 208)

                VStack(spacing: 10) {
                    if sessionState == .complete {
                        Image(systemName: "checkmark")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(Palette.softRed)
                            .padding(.bottom, 4)
                    }

                    Text(timeString(for: displayedTime))
                        .font(.system(size: sessionState == .active ? 54 : 58, weight: .bold, design: .rounded))
                        .foregroundStyle(Palette.darkText)
                        .monospacedDigit()

                    Text(timerSubtitle)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(timerSubtitleColor)

                    if sessionState == .active && showsBreathingDetail {
                        Text(currentBreathingPhase.detail)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Palette.darkText.opacity(0.48))
                    }
                }
            }

            if sessionState == .idle {
                Text(selectedMode.idleMessage)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Palette.darkText.opacity(0.58))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(.white.opacity(0.35))
        )
    }

    private var controlsSection: some View {
        VStack(spacing: 14) {
            switch sessionState {
            case .idle:
                Button {
                    startSession()
                } label: {
                    Label("Start Meditation", systemImage: "play.fill")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [Palette.skyBlue, Palette.deepBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: Capsule()
                        )
                        .shadow(color: Palette.skyBlue.opacity(0.28), radius: 18, y: 10)
                }

                Button {
                    selectedMode = .breathFocus
                } label: {
                    Text(selectedMode == .breathFocus ? "Breathing Mode Active" : "Breathing Mode")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(selectedMode == .breathFocus ? Palette.softRed : Palette.deepBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.white.opacity(0.85), in: Capsule())
                        .overlay {
                            Capsule()
                                .stroke((selectedMode == .breathFocus ? Palette.softRed : Palette.skyBlue).opacity(0.22), lineWidth: 1.5)
                        }
                }
            case .active:
                HStack(spacing: 14) {
                    Button {
                        pauseOrResumeSession()
                    } label: {
                        Label(isPaused ? "Resume" : "Pause", systemImage: isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(Palette.deepBlue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.white.opacity(0.9), in: Capsule())
                    }

                    Button {
                        endSession()
                    } label: {
                        Label("End Session", systemImage: "xmark")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Palette.softRed, in: Capsule())
                    }
                }
            case .complete:
                Button {
                    startSession()
                } label: {
                    Text("Meditate Again")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [Palette.skyBlue, Palette.deepBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: Capsule()
                        )
                }

                Button {
                    resetToIdle()
                } label: {
                    Text("Done")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Palette.deepBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.white.opacity(0.88), in: Capsule())
                }
            }
        }
    }

    private var bottomCards: some View {
        Group {
            switch sessionState {
            case .complete:
                VStack(spacing: 14) {
                    statCard(title: "Time completed", value: "5:00", accent: Palette.skyBlue)
                    statCard(title: "Session type", value: selectedMode.sessionLabel, accent: Palette.softRed)
                    statCard(title: "Streak", value: "\(completedSessions) days", accent: Palette.coral)
                }
            default:
                HStack(spacing: 12) {
                    featureCard(for: .calmMind)
                    featureCard(for: .breathFocus)
                }
            }
        }
    }

    private var headerSubtitle: String {
        switch sessionState {
        case .idle:
            switch selectedMode {
            case .calmMind:
                return "Breathe in. Let go."
            case .breathFocus:
                return "Match the breath cue and stay with the rhythm."
            }
        case .active:
            switch selectedMode {
            case .calmMind:
                return "Stay soft and steady."
            case .breathFocus:
                return currentBreathingPhase.title
            }
        case .complete:
            return "You gave yourself five peaceful minutes."
        }
    }

    private var timerSubtitle: String {
        switch sessionState {
        case .idle:
            switch selectedMode {
            case .calmMind:
                return "Ready to begin"
            case .breathFocus:
                return "Breathing mode selected"
            }
        case .active:
            switch selectedMode {
            case .calmMind:
                return "Quiet session in progress"
            case .breathFocus:
                return currentBreathingPhase.title
            }
        case .complete:
            return "Session complete"
        }
    }

    private var timerSubtitleColor: Color {
        switch sessionState {
        case .idle:
            return Palette.darkText.opacity(0.58)
        case .active:
            return selectedMode == .breathFocus ? currentBreathingPhase.glowColor : Palette.skyBlue
        case .complete:
            return Palette.softRed
        }
    }

    private var displayedTime: TimeInterval {
        sessionState == .complete ? sessionDuration : remainingTime
    }

    private var currentBreathingPhase: BreathingPhase {
        let elapsed = max(0, sessionDuration - remainingTime)
        let cyclePosition = elapsed.truncatingRemainder(dividingBy: breathingCycle)

        switch cyclePosition {
        case 0..<4:
            return .inhale
        case 4..<6:
            return .hold
        default:
            return .exhale
        }
    }

    private var breathingAnimationDuration: Double {
        if selectedMode == .calmMind {
            return 8
        }

        switch currentBreathingPhase {
        case .inhale:
            return 4
        case .hold:
            return 2
        case .exhale:
            return 6
        }
    }

    private var isPaused: Bool {
        sessionState == .active && sessionStartDate == nil
    }

    private var showsBreathingOrb: Bool {
        selectedMode == .breathFocus || selectedMode == .calmMind
    }

    private var showsBreathingDetail: Bool {
        selectedMode == .breathFocus
    }

    private var breathingOrbScale: CGFloat {
        if selectedMode == .calmMind {
            return 1.01 + (sessionProgress * 0.04)
        }

        return currentBreathingPhase.scale
    }

    private var breathingOrbOpacity: Double {
        selectedMode == .breathFocus ? 0.18 : 0.12
    }

    private var breathingOrbColor: Color {
        selectedMode == .breathFocus ? currentBreathingPhase.glowColor : Palette.skyBlue
    }

    private var progressRingColors: [Color] {
        switch sessionState {
        case .complete:
            return [Palette.skyBlue, Palette.softRed, Palette.coral, Palette.skyBlue]
        case .active:
            switch selectedMode {
            case .calmMind:
                return [Palette.skyBlue, Palette.deepBlue, Palette.skyBlue]
            case .breathFocus:
                return [Palette.softRed, Palette.coral, Palette.skyBlue]
            }
        case .idle:
            switch selectedMode {
            case .calmMind:
                return [Palette.skyBlue, Palette.deepBlue]
            case .breathFocus:
                return [Palette.softRed, Palette.skyBlue]
            }
        }
    }

    private func featureCard(for mode: FocusMode) -> some View {
        let isSelected = selectedMode == mode

        return Button {
            handleModeTap(mode)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: mode.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(mode.accent)

                Circle()
                    .fill(mode.accent)
                    .frame(width: 8, height: 8)

                Text(mode.title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Palette.darkText)

                Text(mode.subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Palette.darkText.opacity(0.55))
            }
            .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white.opacity(isSelected ? 0.98 : 0.92))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(mode.accent.opacity(isSelected ? 0.75 : 0.12), lineWidth: isSelected ? 2 : 1)
            }
            .shadow(color: mode.accent.opacity(isSelected ? 0.16 : 0.08), radius: 18, y: 10)
        }
        .buttonStyle(.plain)
    }

    private func statCard(title: String, value: String, accent: Color) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Palette.darkText.opacity(0.55))

                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Palette.darkText)
            }

            Spacer()

            Circle()
                .fill(accent.opacity(0.18))
                .frame(width: 40, height: 40)
                .overlay {
                    Circle()
                        .fill(accent)
                        .frame(width: 12, height: 12)
                }
        }
        .padding(20)
        .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: accent.opacity(0.08), radius: 18, y: 10)
    }

    private func startSession() {
        sessionProgress = 0
        remainingTime = sessionDuration
        sessionStartDate = Date()
        sessionState = .active
    }

    private func pauseOrResumeSession() {
        if let sessionStartDate {
            remainingTime = max(0, sessionDuration - Date().timeIntervalSince(sessionStartDate))
            self.sessionStartDate = nil
        } else {
            sessionStartDate = Date().addingTimeInterval(-(sessionDuration - remainingTime))
        }
    }

    private func endSession() {
        resetToIdle()
    }

    private func resetToIdle() {
        sessionState = .idle
        sessionStartDate = nil
        remainingTime = sessionDuration
        sessionProgress = 0
    }

    @MainActor
    private func completeSession() {
        sessionState = .complete
        sessionStartDate = nil
        remainingTime = 0
        sessionProgress = 1
        completedSessions += 1
    }

    private func runSessionTimer() async {
        while sessionState == .active {
            if Task.isCancelled {
                return
            }

            guard let sessionStartDate else {
                try? await Task.sleep(for: .milliseconds(200))
                continue
            }

            let elapsed = Date().timeIntervalSince(sessionStartDate)
            let remaining = max(0, sessionDuration - elapsed)

            await MainActor.run {
                remainingTime = remaining
                sessionProgress = min(1, elapsed / sessionDuration)
            }

            if remaining <= 0 {
                completeSession()
                return
            }

            try? await Task.sleep(for: .milliseconds(200))
        }
    }

    private func timeString(for time: TimeInterval) -> String {
        let totalSeconds = max(0, Int(time.rounded(.down)))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func handleModeTap(_ mode: FocusMode) {
        selectedMode = mode
    }
}

#Preview {
    ContentView()
}
struct MeditationBrandIcon: View {
    let size: CGFloat

    private let deepBlue = Color(red: 30 / 255, green: 58 / 255, blue: 95 / 255)
    private let skyBlue = Color(red: 74 / 255, green: 144 / 255, blue: 226 / 255)
    private let paleBlue = Color(red: 234 / 255, green: 244 / 255, blue: 1.0)
    private let softRed = Color(red: 232 / 255, green: 93 / 255, blue: 117 / 255)
    private let coral = Color(red: 242 / 255, green: 139 / 255, blue: 130 / 255)

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [skyBlue, softRed, coral, skyBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: size * 0.09
                )
                .background(
                    Circle()
                        .fill(.white.opacity(0.16))
                )

            Circle()
                .fill(
                    RadialGradient(
                        colors: [paleBlue.opacity(0.95), .white.opacity(0.8)],
                        center: .center,
                        startRadius: 6,
                        endRadius: size * 0.45
                    )
                )
                .padding(size * 0.18)

            Circle()
                .fill(softRed.opacity(0.16))
                .frame(width: size * 0.36, height: size * 0.36)
                .blur(radius: size * 0.03)
                .offset(y: size * 0.02)

            HStack(spacing: size * 0.05) {
                Capsule()
                    .fill(skyBlue)
                    .frame(width: size * 0.12, height: size * 0.28)
                    .rotationEffect(.degrees(-32))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [softRed, coral],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size * 0.14, height: size * 0.34)

                Capsule()
                    .fill(skyBlue)
                    .frame(width: size * 0.12, height: size * 0.28)
                    .rotationEffect(.degrees(32))
            }
            .offset(y: -size * 0.03)

            Capsule()
                .fill(deepBlue.opacity(0.75))
                .frame(width: size * 0.24, height: size * 0.03)
                .offset(y: size * 0.19)
        }
        .frame(width: size, height: size)
        .shadow(color: skyBlue.opacity(0.18), radius: size * 0.16, y: size * 0.08)
    }
}
