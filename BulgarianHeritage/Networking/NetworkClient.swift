//
//  NetworkClient.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 2.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import Alamofire

//protocol IHeritagesService {
//    func getAllHeritages(completion: @escaping NetworkCallback<[HeritagesResponse]>)
//}

class NetworkClient: BaseNetworkClient {

    func getQuizQA(with parameters: QuizQAParameters, completion: @escaping NetworkCallback<[QuizQAResponse]>) {
        let request = QuizQAGetRequest(parameters: parameters)
        start(request: request) { (response, error) in
            if let error = error {
                completion(NetworkResult.failed(error: error))
            } else {
                completion(self.decodableResult(from: response))
            }
        }
    }

    func getAllScores(completion: @escaping NetworkCallback<[ScoreResponse]>) {
        let request = AllScoresGetRequest()
        start(request: request) { (response, error) in
            if let error = error {
                completion(.failed(error: error))
            } else {
                completion(self.decodableResult(from: response))
            }
        }
    }
    
    func postQuizScore(with parameters: ScoreParameters, completion: @escaping NetworkCallback<Bool>) {
        let request = ScorePostRequest(parameters: parameters)
        start(request: request) { (response, error) in
            if let error = error {
                completion(.failed(error: error))
            } else {
                completion(.successful(value: true))
            }
        }
    }

    func getAllHeritages(completion: @escaping NetworkCallback<[HeritagesResponse]>) {
        let request = AllHeritagesGetRequest()
        start(request: request) { (response, error) in
            if let error = error {
                completion(.failed(error: error))
            } else {
                completion(self.decodableResult(from: response))
            }
        }
    }
}
