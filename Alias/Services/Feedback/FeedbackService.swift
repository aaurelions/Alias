import AudioToolbox
import UIKit

/// Plays system sounds and haptics, honoring the user's sound and vibration settings.
final class FeedbackService {
    static let shared = FeedbackService(settings: .shared)

    enum Haptic {
        case light, medium, heavy, success, warning
    }

    private enum Sound: SystemSoundID {
        case tink = 1103
        case swish = 1053
        case click = 1104
        case fanfare = 1256
        case warning = 1106
        case victory = 1329
    }

    private let settings: AppSettings

    init(settings: AppSettings) {
        self.settings = settings
    }

    func wordGuessed() {
        play(.tink)
        haptic(.success)
    }

    func wordSkipped() {
        play(.swish)
        haptic(.light)
    }

    func buttonTap() {
        play(.click)
        haptic(.light)
    }

    func lastWordGuessed() {
        play(.fanfare)
        haptic(.heavy)
    }

    func timeWarning() {
        play(.warning)
        haptic(.warning)
    }

    func gameWon() {
        play(.victory)
        haptic(.heavy)
    }

    func haptic(_ haptic: Haptic) {
        guard settings.vibrationEnabled else { return }
        switch haptic {
        case .light: UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium: UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy: UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .success: UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning: UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
    }

    private func play(_ sound: Sound) {
        guard settings.soundEnabled else { return }
        AudioServicesPlaySystemSound(sound.rawValue)
    }
}
