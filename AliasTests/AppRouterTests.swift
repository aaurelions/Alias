@testable import Alias
import Testing

@MainActor
struct AppRouterTests {
    @Test func fullGameFlowKeepsStackShallow() {
        let router = AppRouter()

        router.showNewGame()
        #expect(router.path == [.newGame])

        router.startGame()
        #expect(router.path == [.newGame, .turnStart])

        for route in [Route.gameplay, .turnResults, .turnStart, .gameplay, .turnResults, .winner] {
            router.show(route)
            #expect(router.path == [.newGame, route])
        }

        router.startGame()
        #expect(router.path == [.newGame, .turnStart])

        router.goHome()
        #expect(router.path.isEmpty)
    }

    @Test func repeatedTransitionsAreIdempotent() {
        let router = AppRouter()

        router.showNewGame()
        router.showNewGame()
        router.startGame()
        router.startGame()
        router.show(.turnStart)

        #expect(router.path == [.newGame, .turnStart])
    }

    @Test func backFromFirstTurnReturnsToSetupThenHome() {
        let router = AppRouter()
        router.startGame()

        router.back()
        #expect(router.path == [.newGame])

        router.back()
        router.back()
        #expect(router.path.isEmpty)
    }
}
