//
//  NetworkRequest.swift
//  Pods
//
//   Created by Teodor Evgeniev Yanev on 24.04.19.
//   Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import Alamofire

protocol NetworkRequest {
    
    var urlPath: String { get }
    var httpMethod: HTTPMethod { get }
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }
    var headers: HTTPHeaders? { get }
}

extension NetworkRequest {
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var parameters: Parameters? {
        return nil
    }
    
    var encoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    func parameters<T: Encodable>(from encodable: T) -> Parameters? {
        guard let data = try? JSONEncoder().encode(encodable) else {
            return nil
        }
        
        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        return jsonObject as? [String: Any]
    }
}
