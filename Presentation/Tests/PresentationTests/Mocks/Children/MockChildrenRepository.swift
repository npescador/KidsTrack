import Domain
import Shared

final class MockChildrenRepository: ChildrenRepositoryProtocol, @unchecked Sendable {
    enum Mode {
        case succeed(Child)
        case fail(Error)
    }

    var mode: Mode
    private(set) var receivedCreateRequest: CreateChildRequest?
    private(set) var receivedUpdateRequest: UpdateChildRequest?
    private(set) var callCount = 0

    init(mode: Mode) {
        self.mode = mode
    }

    func createChild(_ request: CreateChildRequest) async throws -> Child {
        callCount += 1
        receivedCreateRequest = request
        switch mode {
        case .succeed(let child):
            return child
        case .fail(let error):
            throw error
        }
    }

    func updateChild(_ request: UpdateChildRequest) async throws -> Child {
        callCount += 1
        receivedUpdateRequest = request
        switch mode {
        case .succeed(let child):
            return child
        case .fail(let error):
            throw error
        }
    }
}
