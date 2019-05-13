//
//  QuizQARequest.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 2.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import Alamofire

struct Answer: Decodable {
    let id: UUID
    let text: String
}

struct Question: Decodable {
    let id: UUID
    var answer_id: UUID?
    let correct_answer_id: UUID
    let text: String
    let answers: [Answer]

    init(id: UUID, answer_id: UUID? = nil, correct_answer_id: UUID, text: String, answers: [Answer]) {
        self.id = id
        self.answer_id = answer_id
        self.correct_answer_id = correct_answer_id
        self.text = text
        self.answers = answers
    }


    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let correct_answer_id = try container.decode(UUID.self, forKey: .correct_answer_id)
        let text = try container.decode(String.self, forKey: .text)
        let answers = try container.decode([Answer].self, forKey: .answers)

        self.init(id: id, correct_answer_id: correct_answer_id, text: text, answers: answers)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case correct_answer_id
        case text
        case answers
    }
}

struct QuizQAParameters: Encodable {
    let id: UUID?

    init(id: UUID? = nil) {
        self.id = id
    }
}

struct QuizQAResponse: Decodable {
    let id: UUID
    let questions: [Question]
}


struct QuizQAGetRequest: NetworkRequest {

    var encodableParameters: QuizQAParameters

    init(parameters: QuizQAParameters) {
        encodableParameters = parameters
    }

    var urlPath: String {
        if let locale = NSLocale.current.languageCode {
            guard let identifier = encodableParameters.id else {
                return "/quizes-\(locale)"
            }
            return "/quizes-\(locale)/\(identifier)"
        }
        return "/quizes-en"
    }

    var httpMethod: HTTPMethod {
        return .get
    }
}
