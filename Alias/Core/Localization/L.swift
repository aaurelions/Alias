import Foundation

/// Typed access to `Localizable.strings` in the language chosen in the app settings.
nonisolated enum L {
    // MARK: - Common

    static var cancel: String { localized("common.cancel") }
    static var close: String { localized("common.close") }
    static var save: String { localized("common.save") }
    static var `continue`: String { localized("common.continue") }
    static var exit: String { localized("common.exit") }
    static var home: String { localized("common.home") }
    static var again: String { localized("common.again") }

    // MARK: - Home

    enum Home {
        static var newGame: String { localized("home.new_game") }
        static var settings: String { localized("home.settings") }

        enum Accessibility {
            static var startGame: String { localized("home.accessibility.start_game") }
            static var openSettings: String { localized("home.accessibility.open_settings") }
        }
    }

    // MARK: - New Game

    enum NewGame {
        static var title: String { localized("new_game.title") }
        static var startGame: String { localized("new_game.start_game") }
        static var addPlayer: String { localized("new_game.add_player") }
    }

    // MARK: - Player

    enum Player {
        enum Edit {
            static var title: String { localized("player.edit.title") }
            static var nameLabel: String { localized("player.edit.name_label") }
            static var chooseIcon: String { localized("player.edit.choose_icon") }
        }

        static func defaultName(_ number: Int) -> String {
            String(format: localized("player.default_name"), number)
        }
    }

    // MARK: - Dictionary

    enum Dictionary {
        static var easy: String { localized("dictionary.easy") }
        static var medium: String { localized("dictionary.medium") }
        static var hard: String { localized("dictionary.hard") }
        static var custom: String { localized("dictionary.custom") }

        enum Create {
            static var title: String { localized("dictionary.create.title") }
            static var instruction: String { localized("dictionary.create.instruction") }
            static var generating: String { localized("dictionary.create.generating") }
            static var example: String { localized("dictionary.create.example") }
            static var generate: String { localized("dictionary.create.generate") }
            static var words: String { localized("dictionary.create.words") }
            static var failed: String { localized("dictionary.create.failed") }

            enum Failure {
                static var emptyTopic: String { localized("dictionary.create.error.empty_topic") }
                static var missingAPIKey: String { localized("dictionary.create.error.missing_api_key") }
                static var invalidResponse: String { localized("dictionary.create.error.invalid_response") }

                static func requestFailed(_ statusCode: Int, _ message: String) -> String {
                    let base = String(format: localized("dictionary.create.error.request_failed"), statusCode)
                    return message.isEmpty ? base : "\(base)\n\(message)"
                }

                static func tooFewWords(_ received: Int, _ required: Int) -> String {
                    String(format: localized("dictionary.create.error.too_few_words"), received, required)
                }
            }
        }
    }

    // MARK: - Settings

    enum Settings {
        static var language: String { localized("settings.language") }
        static var sound: String { localized("settings.sound") }
        static var vibration: String { localized("settings.vibration") }
        static var openRouter: String { localized("settings.openrouter") }
        static var openRouterAPIKey: String { localized("settings.openrouter_api_key") }
        static var openRouterAPIKeyPlaceholder: String { localized("settings.openrouter_api_key_placeholder") }
        static var openRouterModel: String { localized("settings.openrouter_model") }
        static var openRouterModelPlaceholder: String { localized("settings.openrouter_model_placeholder") }
        static var openRouterHelp: String { localized("settings.openrouter_help") }
        static var roundTime: String { localized("settings.round_time") }
        static var pointsToWin: String { localized("settings.points_to_win") }
        static var pointsForGuessed: String { localized("settings.points_for_guessed") }
        static var penaltyForSkipped: String { localized("settings.penalty_for_skipped") }
        static var lastWordBonus: String { localized("settings.last_word_bonus") }
        static var bonusPoints: String { localized("settings.bonus_points") }
        static var bonus: String { localized("settings.bonus") }
    }

    // MARK: - Turn Start

    enum TurnStart {
        static var letsGo: String { localized("turn_start.lets_go") }
        static var howToPlay: String { localized("turn_start.how_to_play") }
        static var instruction1: String { localized("turn_start.instruction_1") }
        static var instruction2: String { localized("turn_start.instruction_2") }
        static var instruction3: String { localized("turn_start.instruction_3") }
        static var instruction4: String { localized("turn_start.instruction_4") }
        static var round: String { localized("turn_start.round") }

        static func turnOf(_ current: Int, _ total: Int) -> String {
            String(format: localized("turn_start.turn_of"), current, total)
        }
    }

    // MARK: - Gameplay

    enum Gameplay {
        static var bonusTime: String { localized("gameplay.bonus_time") }
        static var swipeUpGuessed: String { localized("gameplay.swipe_up_guessed") }
        static var swipeDownSkipped: String { localized("gameplay.swipe_down_skipped") }
        static var exitTitle: String { localized("gameplay.exit_title") }
        static var exitMessage: String { localized("gameplay.exit_message") }
        static var lastWordBonus: String { localized("gameplay.last_word_bonus") }
        static var noMoreWords: String { localized("gameplay.no_more_words") }
        static var poolExhausted: String { localized("gameplay.pool_exhausted") }

        static func whoGetsPoints(_ points: Int) -> String {
            String(format: localized("gameplay.who_gets_points"), points)
        }
    }

    // MARK: - Turn Results

    enum TurnResults {
        static var words: String { localized("turn_results.words") }
        static var totalScores: String { localized("turn_results.total_scores") }
        static var tapToReveal: String { localized("turn_results.tap_to_reveal") }

        static func guessedSkipped(_ guessed: Int, _ skipped: Int) -> String {
            String(format: localized("turn_results.guessed_skipped"), guessed, skipped)
        }

        static func turnOf(_ current: Int, _ total: Int) -> String {
            String(format: localized("turn_results.turn_of"), current, total)
        }
    }

    // MARK: - Winner

    enum Winner {
        static var itsTie: String { localized("winner.its_a_tie") }
    }

    // MARK: - Role

    enum Role {
        static var guesser: String { localized("role.guesser") }
        static var explainer: String { localized("role.explainer") }
    }

    // MARK: - Accessibility

    enum Accessibility {
        static var next: String { localized("accessibility.next") }
        static var play: String { localized("accessibility.play") }
        static var pause: String { localized("accessibility.pause") }
    }

    private static func localized(_ key: String) -> String {
        let language = UserDefaults.standard.string(forKey: AppSettings.languageKey) ?? Language.english.rawValue
        let bundle = Bundle.main.path(forResource: language, ofType: "lproj").flatMap(Bundle.init(path:)) ?? .main
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}
