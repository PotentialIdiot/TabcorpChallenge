//
//  Launch.swift
//  TabcorpChallenge
//
//  Created by Weng hou Chan on 10/11/19.
//  Copyright © 2019 TABCORP. All rights reserved.
//

import Foundation

struct Launch {
    // identifier
    let flightNumber: Int
    let rocketId: String
    
    // general info
    let missionName: String
    let date: Date
    let succeeded: Bool?
    
    // payloads
    let payloads: String
    
    // site
    let site: String
    
    // rocket
    let rocket: String
}

extension Launch: Decodable {
    enum CodingKeys: String, CodingKey, CaseIterable {
        // identifier
        case flightNumber = "flight_number"

        // general
        case missionName = "mission_name"
        case date = "launch_date_utc"
        case succeeded = "launch_success"
        
        // rocket/payload
        case rocket
        
        enum RocketKeys: String, CodingKey {
            case rocketId = "rocket_id"
            case rocketName = "rocket_name"
            case secondStage = "second_stage"
            
            enum SecondStageKeys: String, CodingKey {
                case payloads
                
                enum PayloadKeys: String, CodingKey {
                    case payloadName = "payload_id"
                }
            }
        }
        
        // site
        case launchSite = "launch_site"
        
        enum SiteKeys: String, CodingKey {
            case siteName = "site_name_long"
        }
    }
    
    init(from decoder: Decoder) throws {
        // general
        let container = try decoder.container(keyedBy: CodingKeys.self)
        flightNumber = try container.decode(Int.self, forKey: .flightNumber)
        missionName = try container.decode(String.self, forKey: .missionName)
        date = try container.decode(Date.self, forKey: .date)
        succeeded = try container.decodeIfPresent(Bool.self, forKey: .succeeded)
        
        // site
        let siteContainer = try container.nestedContainer(keyedBy: CodingKeys.SiteKeys.self, forKey: .launchSite)
        site = try siteContainer.decode(String.self, forKey: .siteName)
        
        // rocket
        let rocketContainer = try container.nestedContainer(keyedBy: CodingKeys.RocketKeys.self, forKey: .rocket)
        rocket = try rocketContainer.decode(String.self, forKey: .rocketName)
        rocketId = try rocketContainer.decode(String.self, forKey: .rocketId)
        let secondStageContainer = try rocketContainer.nestedContainer(keyedBy: CodingKeys.RocketKeys.SecondStageKeys.self, forKey: .secondStage)
        
        // payloads
        var payloadsContainer = try secondStageContainer.nestedUnkeyedContainer(forKey: .payloads)
        var payloads = ""
        while !payloadsContainer.isAtEnd {
            let payloadContainer = try payloadsContainer.nestedContainer(keyedBy: CodingKeys.RocketKeys.SecondStageKeys.PayloadKeys.self)
            let payloadName = try payloadContainer.decode(String.self, forKey: .payloadName)
            payloads += payloads == "" ? payloadName : ", \(payloadName)"
        }
        self.payloads = payloads
    }
}
