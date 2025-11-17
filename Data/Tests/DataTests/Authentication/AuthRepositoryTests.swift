import Data
import Domain
import Shared
import Testing

@Suite("Auth Repository")
struct AuthRepositoryTests {
    private let dataSource = MockFirebaseAuthDataSource()
    private var repository: AuthRepository { AuthRepository(dataSource: dataSource) }

    @Test("Login delegates to data source")
    func login() async throws {
        dataSource.loginResult = .success(.init(id: "uid", email: "test@test.com"))
        let user = try await repository.login(email: "test@test.com", password: "123456")
        #expect(user.id == "uid")
        #expect(dataSource.receivedEmail == "test@test.com")
    }

    @Test("Register forwards errors")
    func registerError() async {
        dataSource.loginResult = .failure(.userAlreadyExists)

        do {
            _ = try await repository.register(email: "dup@test.com", password: "pass")
            Issue.record("Expected duplicate user error")
        } catch {
            #expect(error as? AuthError == .userAlreadyExists)
        }
    }

    @Test("Password reset surfaces error")
    func reset() async {
        dataSource.resetError = .network

        do {
            try await repository.sendPasswordReset(email: "a@test.com")
            Issue.record("Expected network error")
        } catch {
            #expect(error as? AuthError == .network)
        }
    }

    @Test("Logout call is proxied")
    func logout() async throws {
        try await repository.logout()
        #expect(dataSource.didLogout)
    }

    @Test("Auth state stream is proxied")
    func authState() async {
        let stream = repository.observeAuthState()
        dataSource.stateContinuation?.yield(.authenticated(.init(id: "abc", email: "user@test.com")))

        if let value = await firstValue(from: stream) {
            #expect(value == .authenticated(.init(id: "abc", email: "user@test.com")))
        } else {
            Issue.record("Expected auth state value")
        }
    }
}

private func firstValue(from stream: AsyncStream<AuthState>) async -> AuthState? {
    for await value in stream {
        return value
    }
    return nil
}
