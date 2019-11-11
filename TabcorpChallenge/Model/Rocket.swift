//
//  Rocket.swift
//  TabcorpChallenge
//
//  Created by Weng hou Chan on 10/11/19.
//  Copyright © 2019 TABCORP. All rights reserved.
//

import Foundation

struct Rocket {
    let rocketName: String
    let country: String
    let company: String
    let description: String
    let wikipedia: URL
}

extension Rocket: Decodable {
    enum CodingKeys: String, CodingKey {
        case rocketName = "rocket_name"
        case country
        case company
        case description
        case wikipedia
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rocketName = try container.decode(String.self, forKey: .rocketName)
        country = try container.decode(String.self, forKey: .country)
        company = try container.decode(String.self, forKey: .company)
        description = try container.decode(String.self, forKey: .description)
        wikipedia = try container.decode(URL.self, forKey: .wikipedia)
    }
}
