import Shared

struct MockUserSessionProvider: UserSessionProviding {
    var currentUser: AuthUser?
}
