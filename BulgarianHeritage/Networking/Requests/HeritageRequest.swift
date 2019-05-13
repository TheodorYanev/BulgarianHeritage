//
//  HeritageRequest.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 3.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import Alamofire

struct Location {
    let latitude: Double
    let longitude: Double
}

struct Heritage {
    let id: Int
    let title: String
    let info: String
    let imageURL: String
    let location: Location?
}

extension Heritage: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let title = try container.decode(String.self, forKey: .title)
        let info = try container.decode(String.self, forKey: .info)
        let imageURL = try container.decode(String.self, forKey: .imageURL)
        let latitude = try? container.decode(Double.self, forKey: .latitude)
        let longitude = try? container.decode(Double.self, forKey: .longitude)
        var location: Location? = nil
        if let latitude = latitude, let longitude = longitude {
            location = Location(latitude: latitude, longitude: longitude)
        }

        self.init(id: id, title: title, info: info, imageURL: imageURL, location: location)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case info = "text"
        case imageURL
        case latitude
        case longitude
    }
}

struct HeritagesResponse: Decodable {
    let culturalHeritages: [Heritage]
    let naturalHeritages: [Heritage]
    let intangibleHeritages: [Heritage]
}

struct AllHeritagesGetRequest: NetworkRequest {

    init() { }

    var urlPath: String {
        guard let locale = NSLocale.current.languageCode else {
            return "/heritages-en"
        }
        return "/heritages-\(locale)"
    }
    var httpMethod: HTTPMethod {
        return .get
    }
}
