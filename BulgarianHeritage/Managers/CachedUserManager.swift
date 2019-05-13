//
//  CachedUserManager.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 8.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation

struct User {
    var username: String
    var password: String
}

extension User {

    enum Keys: String {
        case username
        case password
    }

    var serialized: [String: Any] {
        var serialized = [String: Any]()
        serialized[Keys.username.rawValue] = username
        serialized[Keys.password.rawValue] = password
        return serialized
    }

    init?(_ data: [String: Any]) {
        guard let username = data[Keys.username.rawValue] as? String else { return nil }
        guard let password = data[Keys.password.rawValue] as? String else { return nil }

        self.username = username
        self.password = password
    }
}

class CachedUserManager {

    private let lastLoggedUserKey = "lastLoggedUserKey"

    init() { }

    var user: User? {
        guard let userData = UserDefaults.standard.value(forKey: lastLoggedUserKey) as? [String: Any] else { return nil }
        guard let user = User(userData) else { return nil }
        return user
    }

    func saveUser(_ user: User) {
        UserDefaults.standard.set(user.serialized, forKey: lastLoggedUserKey)
        UserDefaults.standard.synchronize()
    }
    
    func deleteUser() {
        UserDefaults.standard.removeObject(forKey: lastLoggedUserKey)
        UserDefaults.standard.synchronize()
    }
}
