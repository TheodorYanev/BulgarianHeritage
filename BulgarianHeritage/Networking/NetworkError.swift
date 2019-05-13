//
//  NetworkError.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 24.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation

struct NetworkError: Decodable {
    public var originalError: Error?
    public var httpStatusCode: Int?
    
    public var error: String?
    public var message: String?
    public var status: Int?
    
    enum CodingKeys: String, CodingKey {
        case error
        case message
        case status
    }
    
    init(error: Error? = nil) {
        originalError = error
    }
}
