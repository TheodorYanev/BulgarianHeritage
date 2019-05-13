//
//  RegisterRequest.swift
//  Pods
//
//   Created by Teodor Evgeniev Yanev on 24.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import Alamofire

struct UserRegistrationParameters: Encodable {
    let id: UUID
    let username: String
    let password: String
    
    public init(username: String, password: String, id: UUID) {
        self.username = username
        self.password = password
        self.id = id
    }
}

struct RegisterRequest: NetworkRequest {

    var encodableParameters: UserRegistrationParameters

    init(parameters: UserRegistrationParameters) {
        encodableParameters = parameters
    }

    var urlPath: String {
        return "/users"
    }

    var httpMethod: HTTPMethod {
        return .post
    }

    var parameters: Parameters? {
        return parameters(from: encodableParameters)
    }
    
    var headers: HTTPHeaders? {
        return ["Content-Type": "application/json"]
    }
}
