import Fluent
import Vapor

struct AppleUserService {
  /// A deleted account is never restored. Release its Apple identifier and create
  /// a new user ID with ordinary permissions, retaining the tombstone for purging.
  func signIn(
    appleIdentifier: String, email: String?, fullName: String?, encryptedRefreshToken: String?,
    on database: any Database
  ) async throws -> User {
    do {
      return try await database.transaction { db in
        let existing = try await User.query(on: db).withDeleted()
          .filter(\.$appleUserIdentifier == appleIdentifier).first()
        let user: User
        if let existing, existing.deletedAt == nil {
          user = existing
        } else {
          if let existing {
            // Model.save excludes soft-deleted rows. Update the tombstone
            // explicitly without clearing its deletion timestamp or permissions.
            let oldID = try existing.requireID()
            try await User.query(on: db).withDeleted()
              .filter(\.$id == oldID)
              .filter(\.$deletedAt != nil)
              .set(\.$appleUserIdentifier, to: "deleted:\(oldID.uuidString)")
              .update()
          }
          user = User(appleUserIdentifier: appleIdentifier, role: .user)
        }
        return try await Self.update(
          user, email: email, fullName: fullName, encryptedRefreshToken: encryptedRefreshToken, on: db)
      }
    } catch let error where (error as? any DatabaseError)?.isConstraintFailure == true {
      // A simultaneous first sign-in may have created the new identity. The
      // failed transaction rolled back; adopt only the active winner's record.
      guard
        let user = try await User.query(on: database)
          .filter(\.$appleUserIdentifier == appleIdentifier).first()
      else { throw error }
      return try await Self.update(
        user, email: email, fullName: fullName, encryptedRefreshToken: encryptedRefreshToken, on: database)
    }
  }

  private static func update(
    _ user: User, email: String?, fullName: String?, encryptedRefreshToken: String?,
    on db: any Database
  ) async throws -> User {
    if let email { user.email = email }
    if let fullName { user.fullName = fullName }
    if let encryptedRefreshToken { user.appleRefreshToken = encryptedRefreshToken }
    try await user.save(on: db)
    return user
  }
}
