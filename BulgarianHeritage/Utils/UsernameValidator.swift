//
//  UsernameValidator.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 26.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
private let usernameRegex = "\\w\\S{5,20}"

enum UsernameValidator: String {
    case noError
    case unsufficientLength = "insufficient length"
    case tooLongLength = "too long length"
    case invalidUsername = "invalid username"
    
    init(username: String?) {
        guard let username = username, username.count >= 6 else {
            self = .unsufficientLength
            return
        }
        
        guard username.count <= 20 else {
            self = .tooLongLength
            return
        }
        
        if username.matches(regex: usernameRegex) {
            self = .noError
        } else {
            self = .invalidUsername
        }
    }
    
    var isValid: Bool {
        return self == .noError
    }
}
