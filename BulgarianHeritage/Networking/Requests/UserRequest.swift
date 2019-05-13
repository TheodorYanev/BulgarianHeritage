//
//  UserRequest.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 24.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import Alamofire

struct UserParameters: Encodable {
    let username: String
    let password: String
}

struct UserResponse: Decodable, Equatable {
    var id: UUID
    var username: String
    var password: String
}

struct UserRequest: NetworkRequest {
    
    var encodableParameters: UserParameters
    
    init(parameters: UserParameters) {
        encodableParameters = parameters
    }
    
    var urlPath: String {
        return "/users/?username=\(encodableParameters.username)&password=\(encodableParameters.password)"
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
}
