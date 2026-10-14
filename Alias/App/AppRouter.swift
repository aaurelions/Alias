import Observation

enum Route: Hashable {
    case newGame
    case turnStart
    case gameplay
    case turnResults
    case winner
}

/// Navigation state for the root `NavigationStack`.
///
/// Home is the root. New Game is pushed on top of it, and every in-game screen
/// replaces the one above New Game so the stack never grows during a game:
/// `[newGame, turnStart] → [newGame, gameplay] → [newGame, turnResults] → [newGame, turnStart | winner]`.
@Observable
final class AppRouter {
    var path: [Route] = []

    var currentRoute: Route? { path.last }

    func showNewGame() {
        path = [.newGame]
    }

    func startGame() {
        path = [.newGame, .turnStart]
    }

    func show(_ route: Route) {
        guard currentRoute != route else { return }
        path = [.newGame, route]
    }

    func back() {
        _ = path.popLast()
    }

    func goHome() {
        path = []
    }
}
