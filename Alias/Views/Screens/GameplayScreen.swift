import SwiftUI
import Combine

// MARK: - Gameplay Screen

struct GameplayScreen: View {
    @Binding var navigationPath: NavigationPath
    @Environment(\.dismiss) var dismiss
    @StateObject private var gameManager = GameManager.shared
    private let feedbackManager = FeedbackManager.shared

    @State private var currentWord: String = ""
    @State private var timeRemaining: TimeInterval = 60
    @State private var isPaused = false
    @State private var showExitConfirmation = false
    @State private var flashColor: Color? = nil
    @State private var dragOffset: CGFloat = 0
    @State private var hasSwipedOnce = false
    @State private var isTimeUp = false
    @State private var isBonusTime = false
    @State private var showLastWordBonus = false
    @State private var wordDisplayTime: TimeInterval = 0
    @State private var shouldExplodeLetters = false
    @State private var showPaw = false
    @State private var letterAnimationSeed: Int = 0
    @State private var noMoreWordsAvailable = false
    @State private var hasCompletedTurn = false
    @State private var hasResolvedBonusWord = false

    private var totalTime: TimeInterval {
        TimeInterval(gameManager.settings.selectedRoundTime)
    }

    private var lastWordBonusEnabled: Bool {
        gameManager.settings.lastWordBonusEnabled
    }

    private var lastWordBonusPoints: Int {
        gameManager.settings.lastWordBonusPoints
    }

    private var players: [Player] {
        gameManager.players.map { $0.toPlayer() }
    }

    private var eligibleBonusPlayers: [Player] {
        // IMPORTANT: Exclude ONLY the explainer from bonus selection
        // All other players (including the guesser) can receive the bonus
        let explainerId = gameManager.currentExplainer?.id
        return players.filter { $0.id != explainerId }
    }

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Flash overlay
            if let flashColor = flashColor {
                flashColor
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Top Bar
                    HStack {
                        // Home Button
                        Button(action: {
                            showExitConfirmation = true
                        }) {
                            Image(systemName: "house.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Theme.current.interactivePrimary)
                                .frame(width: 44, height: 44)
                        }

                        Spacer()

                        // Timer
                        VStack(spacing: 4) {
                            if isBonusTime {
                                Text(L.Gameplay.bonusTime)
                                    .font(Theme.Typography.heading1(size: 32))
                                    .foregroundColor(Theme.current.accentHighlight)
                                    .shadow(radius: 5)
                            } else {
                                Text(timeString)
                                    .font(Theme.Typography.heading1(size: 36))
                                    .foregroundColor(timeRemaining <= 10 ? Theme.current.accentDestructive : Theme.current.textPrimary)
                                    .monospacedDigit()
                            }
                        }

                        Spacer()

                        // Pause Button
                        Button(action: {
                            withAnimation {
                                isPaused.toggle()
                            }
                        }) {
                            Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Theme.current.interactivePrimary)
                                .frame(width: 44, height: 44)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    // Progress Bar
                    ZStack(alignment: .leading) {
                        // Background Gradient (Full width)
                        LinearGradient(
                            colors: [Theme.current.accentDestructive, Theme.current.accentSuccess],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(height: 4)
                        .opacity(0.3)

                        // Progress Overlay
                        LinearGradient(
                            colors: [Theme.current.accentDestructive, Theme.current.accentSuccess],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: max(0, (geometry.size.width - 40) * progressPercentage), height: 4)
                        .animation(.linear(duration: 0.1), value: timeRemaining)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    Spacer()

                    if !hasSwipedOnce {
                        VStack(spacing: 8) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Theme.current.accentSuccess.opacity(0.5))
                                .shadow(radius: 1)

                            Text(L.Gameplay.swipeUpGuessed)
                                .font(Theme.Typography.body(size: 14))
                                .foregroundColor(Theme.current.textSecondary.opacity(0.5))
                                .shadow(radius: 1)
                        }
                        .padding(.bottom, 20)
                    }

                    // Word Display
                    AnimatedWordDisplay(
                        word: currentWord,
                        shouldExplode: shouldExplodeLetters,
                        dragOffset: dragOffset,
                        animationSeed: letterAnimationSeed
                    )
                    .padding(.horizontal, 40)

                    // Swipe Down Indicator
                    if !isBonusTime && !hasSwipedOnce {
                        VStack(spacing: 8) {
                            Text(L.Gameplay.swipeDownSkipped)
                                .font(Theme.Typography.body(size: 14))
                                .foregroundColor(Theme.current.textSecondary.opacity(0.5))
                                .shadow(radius: 1)

                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Theme.current.accentDestructive.opacity(0.5))
                                .shadow(radius: 1)
                        }
                        .padding(.top, 20)
                    }

                    Spacer()

                    // Bottom Action Buttons - only show if not in bonus time or if we still have actions available
                    if !isBonusTime {
                        HStack(spacing: 40) {
                            // Skipped Button
                            Button(action: {
                                skipWord()
                            }) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(Theme.current.accentDestructive)
                            }

                            // Guessed Button
                            Button(action: {
                                guessWord()
                            }) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(Theme.current.accentSuccess)
                            }
                        }
                        .padding(.bottom, 40)
                    } else {
                        // In bonus time, show buttons differently
                        HStack(spacing: 40) {
                            // Skipped Button
                            Button(action: {
                                handleBonusSkip()
                            }) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(Theme.current.accentDestructive)
                            }

                            // Guessed Button
                            Button(action: {
                                handleBonusGuess()
                            }) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(Theme.current.accentSuccess)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
                .blur(radius: isPaused || showExitConfirmation || showLastWordBonus ? 10 : 0)
                .disabled(isPaused || showExitConfirmation || showLastWordBonus)

            // Pause Overlay
            if isPaused {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                isPaused = false
                            }
                        }

                    Button(action: {
                        withAnimation {
                            isPaused = false
                        }
                    }) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(Theme.current.interactivePrimary)
                    }
                }
            }

            // Exit Confirmation Popup
            if showExitConfirmation {
                ExitConfirmationPopup(
                    isPresented: $showExitConfirmation,
                    onConfirm: {
                        navigationPath.removeLast(navigationPath.count)
                    }
                )
            }

            // Last Word Bonus Sheet
            if showLastWordBonus {
                LastWordBonusSheet(
                    isPresented: $showLastWordBonus,
                    players: eligibleBonusPlayers,
                    bonusPoints: lastWordBonusPoints,
                    onPlayerSelected: { player in
                        showLastWordBonus = false
                        completeTurnWithBonus(bonusPlayer: player)
                        navigateToResults()
                    }
                )
            }

            // Paw Animation
            if showPaw {
                PawAnimation()
            }

            // No More Words Overlay
            if noMoreWordsAvailable {
                NoMoreWordsOverlay(onDismiss: {
                    noMoreWordsAvailable = false
                    completeTurnWithoutBonus()
                    navigateToResults()
                })
            }

            }
        }
        .contentShape(Rectangle())
        .onAppear {
            // Initialize timer from settings
            timeRemaining = totalTime
            // Load first word
            loadNextWord()
        }
        .onReceive(timer) { _ in
            if !isPaused {
                // Continue tracking word display time even after game time is up
                wordDisplayTime += 0.1

                // Only decrease game timer if time remains
                if timeRemaining > 0 {
                    timeRemaining -= 0.1

                    // Warning at 10 seconds
                    if timeRemaining <= 10 && timeRemaining > 9.9 {
                        feedbackManager.timeWarningFeedback()
                    }

                    if timeRemaining <= 0 {
                        timeRemaining = 0
                        isTimeUp = true
                        isBonusTime = true
                        feedbackManager.triggerHaptic(.heavy)
                    }
                }

                // Trigger letter explosion after 10 seconds (once per word)
                if wordDisplayTime >= 10 && wordDisplayTime < 10.1 {
                    // Randomize letter directions
                    letterAnimationSeed = Int.random(in: 0...10000)

                    // 10-20s: Letters fly out
                    withAnimation(.linear(duration: 10.0)) {
                        shouldExplodeLetters = true
                    }

                    // 17.5s: Show paw (7.5 seconds after explosion starts)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 7.5) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            showPaw = !showExitConfirmation && !showLastWordBonus ? true : false;
                        }
                    }

                    // 20-30s: Letters return (starts at 10 seconds after explosion)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                        withAnimation(.linear(duration: 10.0)) {
                            shouldExplodeLetters = false
                        }
                    }
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 30)
                .onChanged { value in
                    if !isPaused && !showLastWordBonus && !isBonusTime {
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    if !isPaused && !showLastWordBonus {
                        if isBonusTime {
                            // In bonus time, handle swipes differently
                            if value.translation.height < -50 {
                                handleBonusGuess()
                            } else if value.translation.height > 50 {
                                handleBonusSkip()
                            }
                        } else {
                            if value.translation.height < -50 {
                                guessWord()
                            } else if value.translation.height > 50 {
                                skipWord()
                            }
                        }
                        withAnimation(.spring(response: 0.3)) {
                            dragOffset = 0
                        }
                    }
                }
        )
        .background(DarkBackgroundView(backgroundImage: "GameplayScreenBg"))
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    private var timeString: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var progressPercentage: CGFloat {
        let percentage = CGFloat(timeRemaining / totalTime)
        return max(0, min(1, percentage))
    }

    private func guessWord() {
        guard !currentWord.isEmpty, !hasCompletedTurn, !noMoreWordsAvailable, !isBonusTime else { return }

        hasSwipedOnce = true
        flashScreen(color: Theme.current.accentSuccess)

        // Play feedback
        feedbackManager.wordGuessedFeedback()

        // Record the word as guessed
        gameManager.recordWord(currentWord, isGuessed: true)

        loadNextWord()
    }

    private func skipWord() {
        guard !currentWord.isEmpty, !hasCompletedTurn, !noMoreWordsAvailable, !isBonusTime else { return }

        hasSwipedOnce = true
        flashScreen(color: Theme.current.accentDestructive)

        // Play feedback
        feedbackManager.wordSkippedFeedback()

        // Record the word as skipped
        gameManager.recordWord(currentWord, isGuessed: false)

        loadNextWord()
    }

    private func handleBonusGuess() {
        guard !currentWord.isEmpty, !hasCompletedTurn, !hasResolvedBonusWord else { return }
        hasResolvedBonusWord = true

        flashScreen(color: Theme.current.accentSuccess)

        // Play bonus feedback
        feedbackManager.bonusWordFeedback()

        // Record the last word as guessed (mark as bonus word)
        gameManager.recordWord(currentWord, isGuessed: true, isBonusWord: true)

        // Show bonus player selection if enabled
        if lastWordBonusEnabled {
            showLastWordBonus = true
        } else {
            completeTurnWithoutBonus()
            navigateToResults()
        }
    }

    private func handleBonusSkip() {
        guard !currentWord.isEmpty, !hasCompletedTurn, !hasResolvedBonusWord else { return }
        hasResolvedBonusWord = true

        flashScreen(color: Theme.current.accentDestructive)

        // Record the last word as skipped (mark as bonus word so no penalty is applied)
        gameManager.recordWord(currentWord, isGuessed: false, isBonusWord: true)

        // No penalty for skipping the last word, just end the turn
        completeTurnWithoutBonus()
        navigateToResults()
    }

    private func flashScreen(color: Color) {
        withAnimation(.easeOut(duration: 0.2)) {
            flashColor = color
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeIn(duration: 0.2)) {
                flashColor = nil
            }
        }
    }

    private func loadNextWord() {
        guard !hasCompletedTurn else { return }

        // Reset animation states
        wordDisplayTime = 0
        shouldExplodeLetters = false
        showPaw = false
        letterAnimationSeed = 0

        // Get next word from GameManager
        if let word = gameManager.getNextWord() {
            currentWord = word
        } else {
            // No more words available - show message and end turn
            currentWord = ""
            noMoreWordsAvailable = true
            // Don't enter bonus time, just end the turn
        }
    }

    private func completeTurnWithBonus(bonusPlayer: Player) {
        guard !hasCompletedTurn else { return }
        hasCompletedTurn = true
        gameManager.completeTurn(bonusPlayerId: bonusPlayer.id)
    }

    private func completeTurnWithoutBonus() {
        guard !hasCompletedTurn else { return }
        hasCompletedTurn = true
        gameManager.completeTurn(bonusPlayerId: nil)
    }

    private func navigateToResults() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
        navigationPath.append(NavigationDestination.turnResults)
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
                    .foregroundColor(Theme.current.textPrimary)

                Text(L.Gameplay.exitMessage)
                    .font(Theme.Typography.body(size: 16))
                    .foregroundColor(Theme.current.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                HStack(spacing: 16) {
                    // Cancel Button
                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Text(L.cancel)
                            .font(Theme.Typography.body(size: 18))
                            .foregroundColor(Theme.current.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.current.surfacePrimary.opacity(0.3))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Theme.current.borderPrimary.opacity(0.6), lineWidth: 1)
                            )
                    }

                    // Confirm Button
                    Button(action: {
                        onConfirm()
                    }) {
                        Text(L.exit)
                            .font(Theme.Typography.body(size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.current.accentDestructive)
                            .cornerRadius(12)
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

// MARK: - Last Word Bonus Sheet

private struct LastWordBonusSheet: View {
    @Binding var isPresented: Bool
    let players: [Player]
    let bonusPoints: Int
    let onPlayerSelected: (Player) -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    // Title
                    VStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Theme.current.accentHighlight)

                        Text(L.Gameplay.lastWordBonus)
                            .font(Theme.Typography.heading1(size: 28))
                            .foregroundColor(Theme.current.textPrimary)

                        Text(L.Gameplay.whoGetsPoints(bonusPoints))
                            .font(Theme.Typography.body(size: 16))
                            .foregroundColor(Theme.current.textSecondary)
                    }
                    .padding(.top, 30)

                    // Players List
                    VStack(spacing: 12) {
                        ForEach(players, id: \.name) { player in
                            Button(action: {
                                onPlayerSelected(player)
                            }) {
                                HStack(spacing: 16) {
                                    Text(player.emoji)
                                        .font(.system(size: 32))

                                    Text(player.name)
                                        .font(Theme.Typography.body(size: 20))
                                        .foregroundColor(Theme.current.textPrimary)

                                    Spacer()

                                    Text("+\(bonusPoints)")
                                        .font(Theme.Typography.heading1(size: 20))
                                        .foregroundColor(Theme.current.accentHighlight)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Theme.current.surfacePrimary.opacity(0.3))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Theme.current.borderPrimary.opacity(0.6), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Theme.current.borderPrimary.opacity(0.6), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
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
                    .foregroundColor(Theme.current.textPrimary)
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
        // Use animationSeed to create different random patterns each cycle
        let seed = Double(index * 73 + word.count * 17 + animationSeed)
        let angle = seed.truncatingRemainder(dividingBy: 360)
        let distance: CGFloat = 10 // Fixed distance of 10 points

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
                    .foregroundColor(Theme.current.accentHighlight)

                Text(L.Gameplay.noMoreWords)
                    .font(Theme.Typography.heading1(size: 28))
                    .foregroundColor(Theme.current.textPrimary)

                Text(L.Gameplay.poolExhausted)
                    .font(Theme.Typography.body(size: 16))
                    .foregroundColor(Theme.current.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Button(action: onDismiss) {
                    Text(L.continue)
                        .font(Theme.Typography.body(size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.current.interactivePrimary)
                        .cornerRadius(12)
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
    @State private var pawScale: CGFloat = 1.0
    @State private var catchCycle: Int = 0

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()

                Image("Paw")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .scaleEffect(x: pawScale, y: pawScale, anchor: .leading)
                    .rotationEffect(.degrees(pawRotation), anchor: .trailing)
                    .offset(x: pawOffset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                startPawAnimation(screenWidth: geometry.size.width)
            }
        }
        .allowsHitTesting(false)
    }

    private func startPawAnimation(screenWidth: CGFloat) {
        // Random offset between 20-30
        let randomTargetOffset = CGFloat.random(in: 20...30)

        // Slide in from right (0-0.5s)
        withAnimation(.easeOut(duration: 0.5)) {
            pawOffset = randomTargetOffset
        }

        // Start catching animation (0.5-5s)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            startCatchingAnimation()
        }

        // Slide back out to right at 2.5s (when paw disappears at 20s total)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeIn(duration: 0.5)) {
                pawOffset = 300
            }
        }
    }

    private func startCatchingAnimation() {
        // Animate for 5 seconds with different catch attempts
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
            catchCycle += 1

            // Random rotation angle
            let randomAngle = Double.random(in: -30...30)

            // Catch motion: scale up (extend), move, then back
            withAnimation(.easeOut(duration: 0.2)) {
                pawScale = 1.2
                pawRotation = randomAngle
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeIn(duration: 0.2)) {
                    pawScale = 1.0
                }
            }

            // Stop after 5 seconds (6 catch attempts)
            if catchCycle >= 6 {
                timer.invalidate()
            }
        }
    }
}

// MARK: - Preview

#Preview("Active Gameplay - 3 Players") {
    let _ = {
        let manager = GameManager.shared
        let testPlayers = [
            Player(emoji: "👨", name: "Alice"),
            Player(emoji: "👩", name: "Bob"),
            Player(emoji: "🧑", name: "Charlie")
        ]
        let testDict = WordDictionary(
            id: 1,
            emoji: "🟠",
            name: "Medium",
            wordCount: 90
        )
        let testSettings = GameSettings(
            selectedRoundTime: 45,
            selectedPointsToWin: 50,
            guesserPoints: 2,
            explainerPoints: 1,
            guesserPenalty: -1,
            explainerPenalty: -1,
            lastWordBonusEnabled: true,
            lastWordBonusPoints: 5
        )
        manager.startNewGame(players: testPlayers, dictionary: testDict, settings: testSettings)
    }()

    NavigationStack {
        GameplayScreen(navigationPath: .constant(NavigationPath()))
    }
}

#Preview("Quick Game - Bonus Disabled") {
    let _ = {
        let manager = GameManager.shared
        let testPlayers = [
            Player(emoji: "🎮", name: "Player1"),
            Player(emoji: "🎨", name: "Player2")
        ]
        let testDict = WordDictionary(
            id: 0,
            emoji: "🟢",
            name: "Easy",
            wordCount: 60
        )
        let testSettings = GameSettings(
            selectedRoundTime: 30,
            selectedPointsToWin: 20,
            guesserPoints: 3,
            explainerPoints: 2,
            guesserPenalty: -1,
            explainerPenalty: -1,
            lastWordBonusEnabled: false,
            lastWordBonusPoints: 0
        )
        manager.startNewGame(players: testPlayers, dictionary: testDict, settings: testSettings)
    }()

    NavigationStack {
        GameplayScreen(navigationPath: .constant(NavigationPath()))
    }
}

#Preview("Long Game - 4 Players") {
    let _ = {
        let manager = GameManager.shared
        let testPlayers = [
            Player(emoji: "🦄", name: "Unicorn"),
            Player(emoji: "🐉", name: "Dragon"),
            Player(emoji: "🦁", name: "Lion"),
            Player(emoji: "🐼", name: "Panda")
        ]
        let testDict = WordDictionary(
            id: 2,
            emoji: "🔴",
            name: "Hard",
            wordCount: 120
        )
        let testSettings = GameSettings(
            selectedRoundTime: 60,
            selectedPointsToWin: 100,
            guesserPoints: 6,
            explainerPoints: 4,
            guesserPenalty: -3,
            explainerPenalty: -2,
            lastWordBonusEnabled: true,
            lastWordBonusPoints: 10
        )
        manager.startNewGame(players: testPlayers, dictionary: testDict, settings: testSettings)
    }()

    NavigationStack {
        GameplayScreen(navigationPath: .constant(NavigationPath()))
    }
}
