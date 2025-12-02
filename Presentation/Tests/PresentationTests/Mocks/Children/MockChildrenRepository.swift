import Domain
import Shared

final class MockChildrenRepository: ChildrenRepositoryProtocol, @unchecked Sendable {
    enum Mode {
        case succeed(Child)
        case fail(Error)
    }

    var mode: Mode
    private(set) var receivedRequest: CreateChildRequest?
    private(set) var callCount = 0

    init(mode: Mode) {
        self.mode = mode
    }

    func createChild(_ request: CreateChildRequest) async throws -> Child {
        callCount += 1
        receivedRequest = request
        switch mode {
        case .succeed(let child):
            return child
        case .fail(let error):
            throw error
        }
    }
}
