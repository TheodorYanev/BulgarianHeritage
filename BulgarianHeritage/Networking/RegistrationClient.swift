//
//  RegistrationClient.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 24.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import Alamofire

class RegistrationClient: BaseNetworkClient {

    func checkUserExisting(for parameters: UserParameters, completion: @escaping NetworkCallback<[UserResponse]>) {
        let request = UserRequest(parameters: parameters)
        start(request: request) { (response, error) in
            if let error = error {
                completion(NetworkResult.failed(error: error))
            } else {
                completion(self.decodableResult(from: response))
            }
        }
    }
    
    func register(with parameters: UserRegistrationParameters, completion: @escaping NetworkCallback<Bool>)  {
        let request = RegisterRequest(parameters: parameters)
        start(request: request) { (response, error) in
            if let error = error {
                completion(NetworkResult.failed(error: error))
            } else {
                completion(.successful(value: true))
            }
        }
    }

}
