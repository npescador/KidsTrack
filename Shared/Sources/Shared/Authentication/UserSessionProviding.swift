public protocol UserSessionProviding: Sendable {
    var currentUser: AuthUser? { get }
}
