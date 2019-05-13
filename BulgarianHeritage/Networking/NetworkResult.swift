//
//  NetworkResult.swift
//  MEPNetworking
//
//   Created by Teodor Evgeniev Yanev on 24.04.19.
//   Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation

typealias NetworkCallback<T> = (NetworkResult<T>) -> Void

enum NetworkResult<T> {
    case successful(value: T)
    case failed(error: NetworkError)
}
