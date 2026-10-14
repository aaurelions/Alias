import SwiftUI

struct GameplayScreen: View {
    private enum Phase {
        case playing
        case lastWord
        case choosingBonusPlayer
        case outOfWords
        case finished
    }

    private static let explodeAfter: TimeInterval = 10
    private static let pawAfter: TimeInterval = 17.5
    private static let reassembleAfter: TimeInterval = 20
    private static let warningAt: TimeInterval = 10
    private static let swipeThreshold: CGFloat = 50

    @Environment(AppRouter.self) private var router
    @Environment(GameSession.self) private var session
    @Environment(\.scenePhase) private var scenePhase

    @State private var phase = Phase.playing
    @State private var currentWord = ""
    @State private var timeRemaining: TimeInterval = 0
    @State private var wordDisplayTime: TimeInterval = 0
    @State private var hasStarted = false
    @State private var isPaused = false
    @State private var isExitConfirmationPresented = false
    @State private var flashColor: Color?
    @State private var dragOffset: CGFloat = 0
    @State private var hasSwipedOnce = false
    @State private var shouldExplodeLetters = false
    @State private var letterAnimationSeed = 0
    @State private var isPawVisible = false

    private var totalTime: TimeInterval { TimeInterval(session.settings.roundTime) }

    private var isInteractionBlocked: Bool {
        isPaused || isExitConfirmationPresented || phase == .choosingBonusPlayer || phase == .outOfWords
    }

    private var bonusCandidates: [Player] {
        session.players.filter { $0.id != session.currentPairing?.explainerID }.map(\.player)
    }

    var body: some View {
        ZStack {
            if let flashColor {
                flashColor
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            GeometryReader { geometry in
                VStack(spacing: 0) {
                    topBar
                    progressBar(width: geometry.size.width - 40)

                    Spacer()

                    if !hasSwipedOnce {
                        SwipeHint(systemImage: "arrow.up.circle.fill", text: L.Gameplay.swipeUpGuessed, color: Theme.current.accentSuccess)
                            .padding(.bottom, 20)
                    }

                    AnimatedWordDisplay(
                        word: currentWord,
                        shouldExplode: shouldExplodeLetters,
                        dragOffset: dragOffset,
                        animationSeed: letterAnimationSeed
                    )
                    .padding(.horizontal, 40)

                    if phase == .playing && !hasSwipedOnce {
                        SwipeHint(systemImage: "arrow.down.circle.fill", text: L.Gameplay.swipeDownSkipped, color: Theme.current.accentDestructive, isTextFirst: true)
                            .padding(.top, 20)
                    }

                    Spacer()

                    HStack(spacing: 40) {
                        Button { resolve(isGuessed: false) } label: {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(Theme.current.accentDestructive)
                        }
                        .accessibilityLabel(L.Gameplay.swipeDownSkipped)

                        Button { resolve(isGuessed: true) } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(Theme.current.accentSuccess)
                        }
                        .accessibilityLabel(L.Gameplay.swipeUpGuessed)
                    }
                    .padding(.bottom, 40)
                }
                .blur(radius: isInteractionBlocked ? 10 : 0)
                .disabled(isInteractionBlocked)
            }

            overlays

            if isPawVisible {
                PawAnimation()
            }
        }
        .contentShape(.rect)
        .gesture(swipeGesture)
        .background(DarkBackgroundView(backgroundImage: "GameplayScreenBg"))
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active { isPaused = true }
        }
        .task { await runTurn() }
    }

    // MARK: - Subviews

    private var topBar: some View {
        HStack {
            Button {
                isExitConfirmationPresented = true
            } label: {
                Image(systemName: "house.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Theme.current.interactivePrimary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(L.home)

            Spacer()

            if phase == .playing {
                Text(Duration.seconds(timeRemaining.rounded(.up)), format: .time(pattern: .minuteSecond))
                    .font(Theme.Typography.heading1(size: 36))
                    .foregroundStyle(timeRemaining <= Self.warningAt ? Theme.current.accentDestructive : Theme.current.textPrimary)
                    .monospacedDigit()
            } else {
                Text(L.Gameplay.bonusTime)
                    .font(Theme.Typography.heading1(size: 32))
                    .foregroundStyle(Theme.current.accentHighlight)
                    .shadow(radius: 5)
            }

            Spacer()

            Button {
                withAnimation { isPaused.toggle() }
            } label: {
                Image(systemName: isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Theme.current.interactivePrimary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(isPaused ? L.Accessibility.play : L.Accessibility.pause)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }

    private func progressBar(width: CGFloat) -> some View {
        let gradient = LinearGradient(
            colors: [Theme.current.accentDestructive, Theme.current.accentSuccess],
            startPoint: .leading,
            endPoint: .trailing
        )
        let progress = totalTime > 0 ? max(0, min(1, timeRemaining / totalTime)) : 0

        return ZStack(alignment: .leading) {
            gradient
                .frame(height: 4)
                .opacity(0.3)

            gradient
                .frame(width: max(0, width * progress), height: 4)
                .animation(.linear(duration: 0.1), value: timeRemaining)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    @ViewBuilder
    private var overlays: some View {
        if isPaused {
            ZStack {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { isPaused = false } }

                Button {
                    withAnimation { isPaused = false }
                } label: {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(Theme.current.interactivePrimary)
                }
                .accessibilityLabel(L.Accessibility.play)
            }
        }

        if isExitConfirmationPresented {
            ExitConfirmationPopup(isPresented: $isExitConfirmationPresented) {
                router.goHome()
            }
        }

        if phase == .choosingBonusPlayer {
            LastWordBonusSheet(players: bonusCandidates, bonusPoints: session.settings.lastWordBonusPoints) { player in
                finishTurn(bonusPlayerID: player.id)
            }
        }

        if phase == .outOfWords {
            NoMoreWordsOverlay {
                finishTurn(bonusPlayerID: nil)
            }
        }
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 30)
            .onChanged { value in
                guard phase == .playing, !isInteractionBlocked else { return }
                dragOffset = value.translation.height
            }
            .onEnded { value in
                defer { withAnimation(.spring(response: 0.3)) { dragOffset = 0 } }
                guard !isInteractionBlocked else { return }
                if value.translation.height < -Self.swipeThreshold {
                    resolve(isGuessed: true)
                } else if value.translation.height > Self.swipeThreshold {
                    resolve(isGuessed: false)
                }
            }
    }

    // MARK: - Turn Flow

    private func runTurn() async {
        if !hasStarted {
            hasStarted = true
            timeRemaining = totalTime
            showNextWord()
        }

        let clock = ContinuousClock()
        var lastTick = clock.now
        while !Task.isCancelled {
            try? await clock.sleep(for: .milliseconds(100))
            let now = clock.now
            let elapsed = (now - lastTick) / .seconds(1)
            lastTick = now
            if !isPaused { tick(elapsed) }
        }
    }

    private func tick(_ elapsed: TimeInterval) {
        switch phase {
        case .playing:
            let previousTime = timeRemaining
            timeRemaining = max(0, timeRemaining - elapsed)
            if previousTime > Self.warningAt && timeRemaining <= Self.warningAt {
                FeedbackService.shared.timeWarning()
            }
            if timeRemaining == 0 {
                phase = .lastWord
                FeedbackService.shared.haptic(.heavy)
            }
        case .lastWord:
            break
        case .choosingBonusPlayer, .outOfWords, .finished:
            return
        }
        advanceWordAnimation(by: elapsed)
    }

    /// Letters scatter after a word has been shown for a while, a paw tries to catch them, then they reassemble.
    private func advanceWordAnimation(by elapsed: TimeInterval) {
        let previous = wordDisplayTime
        wordDisplayTime += elapsed

        func crossed(_ threshold: TimeInterval) -> Bool {
            previous < threshold && wordDisplayTime >= threshold
        }

        if crossed(Self.explodeAfter) {
            letterAnimationSeed = Int.random(in: 0 ... 10_000)
            withAnimation(.linear(duration: 10)) { shouldExplodeLetters = true }
        }
        if crossed(Self.pawAfter) {
            withAnimation(.easeOut(duration: 0.5)) { isPawVisible = true }
        }
        if crossed(Self.reassembleAfter) {
            withAnimation(.linear(duration: 10)) { shouldExplodeLetters = false }
        }
    }

    private func resolve(isGuessed: Bool) {
        guard !currentWord.isEmpty, !isInteractionBlocked else { return }

        switch phase {
        case .playing:
            hasSwipedOnce = true
            flash(isGuessed ? Theme.current.accentSuccess : Theme.current.accentDestructive)
            if isGuessed {
                FeedbackService.shared.wordGuessed()
            } else {
                FeedbackService.shared.wordSkipped()
            }
            session.record(currentWord, isGuessed: isGuessed)
            showNextWord()

        case .lastWord:
            flash(isGuessed ? Theme.current.accentSuccess : Theme.current.accentDestructive)
            session.record(currentWord, isGuessed: isGuessed, isLastWord: true)
            if isGuessed {
                FeedbackService.shared.lastWordGuessed()
            }
            if isGuessed && session.settings.lastWordBonusEnabled && !bonusCandidates.isEmpty {
                phase = .choosingBonusPlayer
            } else {
                finishTurn(bonusPlayerID: nil)
            }

        case .choosingBonusPlayer, .outOfWords, .finished:
            break
        }
    }

    private func showNextWord() {
        wordDisplayTime = 0
        shouldExplodeLetters = false
        isPawVisible = false

        if let word = session.nextWord() {
            currentWord = word
        } else {
            currentWord = ""
            phase = .outOfWords
        }
    }

    private func finishTurn(bonusPlayerID: UUID?) {
        guard phase != .finished else { return }
        phase = .finished
        session.completeTurn(bonusPlayerID: bonusPlayerID)
        router.show(.turnResults)
    }

    private func flash(_ color: Color) {
        withAnimation(.easeOut(duration: 0.2)) {
            flashColor = color
        } completion: {
            withAnimation(.easeIn(duration: 0.2)) { flashColor = nil }
        }
    }
}

// MARK: - Swipe Hint

private struct SwipeHint: View {
    let systemImage: String
    let text: String
    let color: Color
    var isTextFirst = false

    var body: some View {
        VStack(spacing: 8) {
            if isTextFirst { label }
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundStyle(color.opacity(0.5))
                .shadow(radius: 1)
            if !isTextFirst { label }
        }
    }

    private var label: some View {
        Text(text)
            .font(Theme.Typography.body(size: 14))
            .foregroundStyle(Theme.current.textSecondary.opacity(0.5))
            .shadow(radius: 1)
    }
}

// MARK: - Exit Confirmation Popup

private struct ExitConfirmationPopup: View {
    @Binding var isPresented: Bool
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isPresented = false
                    }
                }

            VStack(spacing: 24) {
                Text(L.Gameplay.exitTitle)
                    .font(Theme.Typography.heading1(size: 28))
                    .foregroundStyle(Theme.current.textPrimary)

                Text(L.Gameplay.exitMessage)
                    .font(Theme.Typography.body(size: 16))
                    .foregroundStyle(Theme.current.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                HStack(spacing: 16) {
                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Text(L.cancel)
                            .font(Theme.Typography.body(size: 18))
                            .foregroundStyle(Theme.current.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.current.surfacePrimary.opacity(0.3))
                            .clipShape(.rect(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Theme.current.borderPrimary.opacity(0.6), lineWidth: 1)
                            )
                    }

                    Button(action: onConfirm) {
                        Text(L.exit)
                            .font(Theme.Typography.body(size: 18))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.current.accentDestructive)
                            .clipShape(.rect(cornerRadius: 12))
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Theme.current.borderPrimary.opacity(0.6), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Animated Word Display

private struct AnimatedWordDisplay: View {
    let word: String
    let shouldExplode: Bool
    let dragOffset: CGFloat
    let animationSeed: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(word.enumerated()), id: \.offset) { index, character in
                Text(String(character))
                    .font(Theme.Typography.logo(size: 48))
                    .foregroundStyle(Theme.current.textPrimary)
                    .offset(
                        x: shouldExplode ? randomOffset(for: index).x : 0,
                        y: shouldExplode ? randomOffset(for: index).y : 0
                    )
            }
        }
        .scaleEffect(shouldExplode ? 1.0 : 1.0 + abs(dragOffset) * 0.001)
        .offset(y: shouldExplode ? 0 : dragOffset * 0.3)
        .rotation3DEffect(
            .degrees(shouldExplode ? 0 : Double(dragOffset) * 0.05),
            axis: (x: 1, y: 0, z: 0)
        )
        .multilineTextAlignment(.center)
    }

    private func randomOffset(for index: Int) -> CGPoint {
        let seed = Double(index * 73 + word.count * 17 + animationSeed)
        let angle = seed.truncatingRemainder(dividingBy: 360)
        let distance: CGFloat = 10

        let radians = angle * .pi / 180
        let x = cos(radians) * distance
        let y = sin(radians) * distance

        return CGPoint(x: x, y: y)
    }
}

// MARK: - No More Words Overlay

private struct NoMoreWordsOverlay: View {
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Theme.current.accentHighlight)

                Text(L.Gameplay.noMoreWords)
                    .font(Theme.Typography.heading1(size: 28))
                    .foregroundStyle(Theme.current.textPrimary)

                Text(L.Gameplay.poolExhausted)
                    .font(Theme.Typography.body(size: 16))
                    .foregroundStyle(Theme.current.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Button(action: onDismiss) {
                    Text(L.continue)
                        .font(Theme.Typography.body(size: 18))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.current.interactivePrimary)
                        .clipShape(.rect(cornerRadius: 12))
                }
                .padding(.horizontal, 20)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Theme.current.borderPrimary.opacity(0.6), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Paw Animation

private struct PawAnimation: View {
    @State private var pawOffset: CGFloat = 300
    @State private var pawRotation: Double = 10
    @State private var pawScale: CGFloat = 1

    var body: some View {
        Image("Paw")
            .resizable()
            .scaledToFit()
            .frame(width: 200)
            .scaleEffect(pawScale, anchor: .leading)
            .rotationEffect(.degrees(pawRotation), anchor: .trailing)
            .offset(x: pawOffset)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            .allowsHitTesting(false)
            .task { await play() }
    }

    private func play() async {
        withAnimation(.easeOut(duration: 0.5)) {
            pawOffset = .random(in: 20 ... 30)
        }

        for _ in 0 ..< 6 {
            withAnimation(.easeOut(duration: 0.2)) {
                pawScale = 1.2
                pawRotation = .random(in: -30 ... 30)
            } completion: {
                withAnimation(.easeIn(duration: 0.2)) { pawScale = 1 }
            }
            guard await (try? Task.sleep(for: .milliseconds(400))) != nil else { return }
        }

        withAnimation(.easeIn(duration: 0.5)) {
            pawOffset = 300
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        GameplayScreen()
    }
    .previewEnvironment()
}
