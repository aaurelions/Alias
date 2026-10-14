@testable import Alias
import Testing

@MainActor
struct GameSettingsTests {
    @Test func defaultsAreAmongThePickerOptions() {
        let settings = GameSettings()
        #expect(GameSettings.roundTimeOptions.contains(settings.roundTime))
        #expect(GameSettings.pointsToWinOptions.contains(settings.pointsToWin))
    }

    @Test func defaultPointsFitTheStepperBounds() {
        let settings = GameSettings()
        let positive = 0 ... GameSettings.maximumPoints
        let penalty = -GameSettings.maximumPoints ... 0
        #expect(positive.contains(settings.guesserPoints))
        #expect(positive.contains(settings.explainerPoints))
        #expect(positive.contains(settings.lastWordBonusPoints))
        #expect(penalty.contains(settings.guesserPenalty))
        #expect(penalty.contains(settings.explainerPenalty))
    }
}
