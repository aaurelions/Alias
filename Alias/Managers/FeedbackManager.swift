import Foundation
import AVFoundation
import UIKit

/// Manages sound effects and haptic feedback
@MainActor
final class FeedbackManager {
    static let shared = FeedbackManager()

    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private let settingsManager = SettingsManager.shared

    // MARK: - Audio Setup

    private init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            return
        }
    }

    // MARK: - Sound Effects

    enum SoundEffect: String {
        case wordGuessed = "word_guessed"
        case wordSkipped = "word_skipped"
        case buttonTap = "button_tap"
        case turnComplete = "turn_complete"
        case bonusWord = "bonus_word"
        case timeWarning = "time_warning"
        case gameWon = "game_won"
    }

    /// Plays a sound effect if sound is enabled
    func playSound(_ effect: SoundEffect) {
        guard settingsManager.soundEnabled else { return }

        switch effect {
        case .wordGuessed:
            AudioServicesPlaySystemSound(1103) // Tink sound
        case .wordSkipped:
            AudioServicesPlaySystemSound(1053) // Swish sound
        case .buttonTap:
            AudioServicesPlaySystemSound(1104) // Click sound
        case .turnComplete:
            AudioServicesPlaySystemSound(1255) // Fanfare sound
        case .bonusWord:
            AudioServicesPlaySystemSound(1256) // Celebration sound
        case .timeWarning:
            AudioServicesPlaySystemSound(1106) // Warning sound
        case .gameWon:
            AudioServicesPlaySystemSound(1329) // Victory sound
        }
    }

    // MARK: - Haptic Feedback

    enum HapticStyle {
        case light
        case medium
        case heavy
        case success
        case warning
        case error
        case selection
    }

    /// Triggers haptic feedback if vibration is enabled
    func triggerHaptic(_ style: HapticStyle) {
        guard settingsManager.vibrationEnabled else { return }

        switch style {
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()

        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()

        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()

        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

        case .warning:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)

        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)

        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }

    /// Combined feedback for word actions
    func wordGuessedFeedback() {
        playSound(.wordGuessed)
        triggerHaptic(.success)
    }

    func wordSkippedFeedback() {
        playSound(.wordSkipped)
        triggerHaptic(.light)
    }

    func buttonTapFeedback() {
        playSound(.buttonTap)
        triggerHaptic(.light)
    }

    func bonusWordFeedback() {
        playSound(.bonusWord)
        triggerHaptic(.heavy)
    }

    func timeWarningFeedback() {
        playSound(.timeWarning)
        triggerHaptic(.warning)
    }

    func turnCompleteFeedback() {
        playSound(.turnComplete)
        triggerHaptic(.medium)
    }

    func gameWonFeedback() {
        playSound(.gameWon)
        triggerHaptic(.heavy)
    }
}
