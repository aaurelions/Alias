import SwiftUI
import Combine

// MARK: - Navigation Destination

enum NavigationDestination: Hashable {
    case home
    case newGame
    case turnStartConfirm
    case gameplay
    case turnResults
    case winner
}

// MARK: - Navigation Router

@MainActor
final class NavigationRouter: ObservableObject {
    @Published var path = NavigationPath()

    func navigate(to destination: NavigationDestination) {
        path.append(destination)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func replace(with destination: NavigationDestination) {
        path = NavigationPath()
        path.append(destination)
    }
}
