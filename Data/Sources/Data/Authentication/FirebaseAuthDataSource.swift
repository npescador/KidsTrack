import FirebaseAuth
import FirebaseCore
import Foundation
import Shared

public protocol FirebaseAuthDataSourceProtocol: Sendable {
    func login(email: String, password: String) async throws -> AuthUser
    func register(email: String, password: String) async throws -> AuthUser
    func sendPasswordReset(email: String) async throws
    func logout() async throws
    func observeAuthState() -> AsyncStream<AuthState>
}

public final class FirebaseAuthDataSource: FirebaseAuthDataSourceProtocol, @unchecked Sendable {
    private let auth: Auth

    public init(auth: Auth = Auth.auth()) {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        self.auth = auth
    }

    public func login(email: String, password: String) async throws -> AuthUser {
        try await signIn(email: email, password: password)
    }

    public func register(email: String, password: String) async throws -> AuthUser {
        try await createUser(email: email, password: password)
    }

    public func sendPasswordReset(email: String) async throws {
        let auth = self.auth
        try await wrapAsync { continuation in
            auth.sendPasswordReset(withEmail: email) { error in
                if let error {
                    continuation.resume(throwing: Self.map(error))
                } else {
                    continuation.resume()
                }
            }
        }
    }

    public func logout() async throws {
        do {
            try auth.signOut()
        } catch {
            throw Self.map(error)
        }
    }

    public func observeAuthState() -> AsyncStream<AuthState> {
        AsyncStream { [weak self] continuation in
            guard let self else {
                continuation.finish()
                return
            }

            let auth = self.auth
            let handle = AuthListenerHandle(
                auth.addStateDidChangeListener { _, user in
                    if let user {
                        continuation.yield(.authenticated(.init(id: user.uid, email: user.email ?? "")))
                    } else {
                        continuation.yield(.unauthenticated)
                    }
                }
            )

            continuation.onTermination = { [auth, handle] _ in
                auth.removeStateDidChangeListener(handle.value)
            }
        }
    }
}

private final class AuthListenerHandle: @unchecked Sendable {
    let value: NSObjectProtocol

    init(_ value: NSObjectProtocol) {
        self.value = value
    }
}

private extension FirebaseAuthDataSource {
    func signIn(email: String, password: String) async throws -> AuthUser {
        let auth = self.auth
        return try await wrapAsync { continuation in
            auth.signIn(withEmail: email, password: password) { result, error in
                if let error {
                    continuation.resume(throwing: Self.map(error))
                } else if let result {
                    let user = AuthUser(id: result.user.uid, email: result.user.email ?? email)
                    continuation.resume(returning: user)
                } else {
                    continuation.resume(throwing: AuthError.unknown(message: "Empty response"))
                }
            }
        }
    }

    func createUser(email: String, password: String) async throws -> AuthUser {
        let auth = self.auth
        return try await wrapAsync { continuation in
            auth.createUser(withEmail: email, password: password) { result, error in
                if let error {
                    continuation.resume(throwing: Self.map(error))
                } else if let result {
                    let user = AuthUser(id: result.user.uid, email: result.user.email ?? email)
                    continuation.resume(returning: user)
                } else {
                    continuation.resume(throwing: AuthError.unknown(message: "Empty response"))
                }
            }
        }
    }

    func wrapAsync<T>(
        _ operation: @escaping (CheckedContinuation<T, Error>) -> Void
    ) async throws -> T {
        try await withCheckedThrowingContinuation(operation)
    }

    func wrapAsync(
        _ operation: @escaping (CheckedContinuation<Void, Error>) -> Void
    ) async throws {
        try await withCheckedThrowingContinuation(operation)
    }

    static func map(_ error: Error) -> AuthError {
        let nsError = error as NSError
        guard let code = AuthErrorCode(rawValue: nsError.code) else {
            return .unknown(message: error.localizedDescription)
        }

        switch code {
        case .networkError:
            return .network
        case .wrongPassword, .invalidEmail:
            return .invalidCredentials
        case .userNotFound:
            return .userNotFound
        case .emailAlreadyInUse:
            return .userAlreadyExists
        case .userDisabled:
            return .sessionExpired
        default:
            return .unknown(message: error.localizedDescription)
        }
    }
}
