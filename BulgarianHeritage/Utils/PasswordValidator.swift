//
//  PasswordValidator.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 26.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
private let passwordRegex = "\\S{6,20}"

enum PasswordValidator: String {
    case noError
    case unsufficientLength = "insufficient length"
    case tooLongLength = "too long length"
    case invalidPassword = "invalid password"
    
    init(password: String?) {
        guard let password = password, password.count >= 6 else {
            self = .unsufficientLength
            return
        }
        
        guard password.count <= 20 else {
            self = .tooLongLength
            return
        }
        
        if password.matches(regex: passwordRegex) {
            self = .noError
        } else {
            self = .invalidPassword
        }
    }
    
    var isValid: Bool {
        return self == .noError
    }
}
