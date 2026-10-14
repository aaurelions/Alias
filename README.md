# Alias

Alias is a SwiftUI party word game for iPhone and iPad. Players take turns explaining words to each other, scoring points for guessed words and losing points for skips. The app includes built-in dictionaries and can generate custom dictionaries with any OpenAI-compatible LLM API.

## Screenshots

| Home | New Game | Turn Start | Gameplay |
| --- | --- | --- | --- |
| <img src="docs/screenshots/1.PNG" width="180" alt="Alias home screen"> | <img src="docs/screenshots/2.PNG" width="180" alt="Alias new game screen"> | <img src="docs/screenshots/3.PNG" width="180" alt="Alias gameplay screen"> | <img src="docs/screenshots/4.PNG" width="180" alt="Alias results screen"> |

## Features

- Localized UI in English, Ukrainian, and Russian.
- Built-in Easy, Medium, and Hard dictionaries.
- AI-generated custom dictionaries through any OpenAI-compatible API (OpenAI, OpenRouter, Groq, Ollama, LM Studio, …), with player-configurable base URL, API key and model.
- Streaming generation progress with visible word-count updates.
- Configurable round time, points to win, scoring, penalties, and last-word bonus.
- SwiftUI navigation flow: Home -> New Game -> Turn Start -> Gameplay -> Results -> Winner.
- Sound and haptic feedback toggles.

## Requirements

- Xcode 26 or newer.
- iOS 26 SDK or compatible simulator/device.
- Optional: access to an OpenAI-compatible Chat Completions API for AI dictionary generation.

## AI Dictionary Setup

Nothing about the provider is hardcoded. Open **Settings** on the home screen and fill in the **AI Dictionaries** card:

| Field | Example | Environment fallback |
| --- | --- | --- |
| Base URL | `https://api.openai.com/v1`, `https://openrouter.ai/api/v1`, `http://localhost:11434/v1` | `OPENAI_BASE_URL` |
| API Key | `sk-…` | `OPENAI_API_KEY` |
| Model | `gpt-4.1-mini` | `OPENAI_MODEL` |

The base URL is the API root; the app calls `<base URL>/chat/completions` (a full `…/chat/completions` URL also works). The API key is saved in the Keychain on the device; the base URL and model are saved in `UserDefaults`. The card shows whether the configuration is complete and flags malformed URLs.

For local development you can set the `OPENAI_*` variables in the Xcode scheme environment; each one is used only when the matching field in Settings is empty. Players upgrading from 1.1 keep their OpenRouter key and model: they are migrated once with OpenRouter's base URL filled in.

Generation streams a standard Chat Completions request (`model`, `messages`, `response_format` with a strict JSON schema, `stream`) and sends no provider-specific fields, so the model must support structured outputs. Words are parsed incrementally as they arrive, de-duplicated, and the dialog shows live progress. The list size is `max(300, players × 100)`; a result with fewer than half of the requested words is rejected with a readable error. Generated dictionaries live in memory for the current game setup and are never written to disk.

## Release Hygiene

The repository ignores Xcode user data, build products, local environment files, and common secret files. Do not commit private API keys, local `.xcuserstate` files, `.DS_Store`, or provisioning/signing artifacts.

## Project Structure

- `Alias/App`: app entry point, root view, and `AppRouter` (typed navigation path).
- `Alias/Game`: `GameSession`, the observable game state machine (turn order, scoring, undo of the last turn).
- `Alias/Models`: value types for players, settings, turns, dictionaries, and languages.
- `Alias/Services`: OpenAI-compatible LLM client and dictionary generator, settings and Keychain storage, feedback, built-in word lists.
- `Alias/Features`: one folder per screen (Splash, Home, Settings, NewGame, TurnStart, Gameplay, TurnResults, Winner).
- `Alias/Shared`: reusable SwiftUI components and preview support.
- `Alias/Core`: localization accessors, theme, and constants.
- `Alias/Resources`: assets, fonts, and localization files.
- `AliasTests`: Swift Testing suites.

## Navigation

Home is the root of the `NavigationStack`. New Game is pushed on top of it, and each in-game screen replaces the screen above New Game, so the stack is always `[newGame, current]` during a game:

```text
Home → New Game → Turn Start → Gameplay → Turn Results → Turn Start … → Winner
```

- Back on the first Turn Start returns to New Game with the setup intact.
- Back on a later Turn Start reopens the previous turn's results (`GameSession.returnToLastTurn()`), including across a round boundary, without double-scoring.
- Leaving Gameplay through the home button or Winner → Home clears the stack; Winner → Again restarts with the same players.

## Build

```sh
xcodebuild build -project "Alias.xcodeproj" -scheme "Alias" -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Test

```sh
xcodebuild test -project "Alias.xcodeproj" -scheme "Alias" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AliasTests
```

`LLMLiveTests` calls a real API and runs only when all three settings are passed to the test runner:

```sh
TEST_RUNNER_OPENAI_BASE_URL=https://api.openai.com/v1 TEST_RUNNER_OPENAI_API_KEY=sk-... TEST_RUNNER_OPENAI_MODEL=gpt-4.1-mini \
  xcodebuild test -project "Alias.xcodeproj" -scheme "Alias" -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:AliasTests/LLMLiveTests
```

If the simulator service is unhealthy, reboot the selected simulator and rerun the command.

## Localization

Localization lives in:

- `Alias/Resources/Localization/en.lproj/Localizable.strings`
- `Alias/Resources/Localization/uk.lproj/Localizable.strings`
- `Alias/Resources/Localization/ru.lproj/Localizable.strings`

When adding user-visible text, add a key to all three files and expose it through `L` in `Core/Localization/L.swift`. Never pass literal English to `Text`, labels, or accessibility modifiers; use a format key (for example `"turn_start.round_number" = "Round %d"`) instead of concatenating strings.

`L` reads the language from `AppSettings.language`, which is `@Observable`, so any view that uses `L` refreshes in place when the player changes language. `RootView` also sets `\.locale` so numbers, times and lists follow the in-app language. Services stay UI-agnostic: they throw typed errors, and the presentation layer maps them to text (`L.Dictionary.Create.Failure.message(for:)`).

## UI Conventions

- Present modals with system APIs: `.sheet` + `themedSheet()` for panels and forms (the sheet fits its content, scrolls when needed, and the system handles keyboard avoidance), and `.alert` for confirmations. Do not build modals out of `ZStack` overlays.
- Use `screenBackground(_:)` for screen backgrounds. It fills and clips the image outside the layout, so keyboards and content changes never move it.
- Use `Button` (with a `ButtonStyle` for press effects) rather than `onTapGesture`, so controls work with VoiceOver and other assistive input.
