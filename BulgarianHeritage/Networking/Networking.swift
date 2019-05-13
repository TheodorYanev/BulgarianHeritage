//
//  Networking.swift
//  MEPNetworking
//
//  Created by Teodor Evgeniev Yanev on 24.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import Alamofire

public class Networking {

    private let configuration: Configuration

    let registration: RegistrationClient
    let registered: NetworkClient

    init(configuration: Configuration) {
        self.configuration = configuration
        self.registration = RegistrationClient(configuration: configuration)
        self.registered = NetworkClient(configuration: configuration)
    }
}
