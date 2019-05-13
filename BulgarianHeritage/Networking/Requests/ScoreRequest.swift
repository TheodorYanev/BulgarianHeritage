//
//  ScoreRequest.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 3.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import Alamofire

struct ScoreParameters: Encodable {
    let username: String
    let score: Int
    let quizId: UUID
    let id: UUID
}

struct ScoreResponse: Decodable {
    let username: String
    let score: Int
    let quizIdentifier: UUID
    let identifier: UUID

    enum CodingKeys: String, CodingKey {
        case username
        case score
        case quizIdentifier = "quizId"
        case identifier = "id"
    }
}

struct AllScoresGetRequest: NetworkRequest {

    init() { }

    var urlPath: String {
        return "/scores"
    }
    var httpMethod: HTTPMethod {
        return .get
    }
}


struct ScorePostRequest: NetworkRequest {

    var encodableParameters: ScoreParameters

    init(parameters: ScoreParameters) {
        encodableParameters = parameters
    }

    var headers: HTTPHeaders? {
        return ["Content-Type": "application/json"]
    }

    var urlPath: String {
        return "/scores"
    }

    var httpMethod: HTTPMethod {
        return .post
    }

    var parameters: Parameters? {
        return parameters(from: encodableParameters)
    }
}




