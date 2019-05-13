//
//  BaseNetworkClient.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 24.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import Alamofire

struct Configuration {
    var baseURL: String
    
    init(baseURL: String) {
        self.baseURL = baseURL
    }
}

class BaseNetworkClient {
    
    private var configuration: Configuration
    private var sessionManager: Alamofire.SessionManager
    
    init(configuration: Configuration) {
        self.configuration = configuration
        sessionManager = Alamofire.SessionManager()
    }
    
    // MARK: - Generic
    
    func start(request: NetworkRequest, completion: ((DataResponse<Data>, NetworkError?) -> Void)?) {
        let urlString = configuration.baseURL + request.urlPath
        
        sessionManager.request(urlString, method: request.httpMethod, parameters: request.parameters, encoding: request.encoding, headers: request.headers).validate().responseData { (response) in
            
            response.result.ifSuccess {
                completion?(response, nil)
            }
            
            response.result.ifFailure {
                let apiError = self.createNetworkError(from: response)
                completion?(response, apiError)
            }
        }
    }
    
    // MARK: - Private
    
    private func createNetworkError(from response: Any) -> NetworkError {
        var parsedError: NetworkError?
        var originalError: Error?
        var httpStatus: Int?
        
        if let response = response as? DataResponse<Data>, let errorData = response.data {
            parsedError = try? JSONDecoder().decode(NetworkError.self, from: errorData)
            
            httpStatus = response.response?.statusCode
            originalError = response.error
        }
        
        if let response = response as? DataResponse<Any>, let errorData = response.data {
            parsedError = try? JSONDecoder().decode(NetworkError.self, from: errorData)
            
            httpStatus = response.response?.statusCode
            originalError = response.error
        }

        var error = parsedError ?? NetworkError()
        
        error.originalError = originalError
        error.httpStatusCode = httpStatus ?? 0
        return error
    }
    
    // MARK: - Internal
    
    func decodableResult<T: Decodable>(from response: DataResponse<Data>?) -> NetworkResult<T> {
        guard let data = response?.data else {
            var networkError = NetworkError()
            networkError.message = "parsingFailed"
            return NetworkResult.failed(error: networkError)
        }
        
        do {
            let jsonArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [AnyObject]
            print(jsonArray)
            let result: T = try JSONDecoder().decode(T.self, from: data)
            return NetworkResult.successful(value: result)
        } catch let error {
            let networkError = NetworkError(error: error)
            return NetworkResult.failed(error: networkError)
        }
    }
}

