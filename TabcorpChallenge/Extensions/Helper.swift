//
//  Helper.swift
//  TabcorpChallenge
//
//  Created by Weng hou Chan on 12/11/19.
//  Copyright © 2019 TABCORP. All rights reserved.
//

import Foundation

extension Bool {
    var formatted: String {
        return self ? "Succeeded" : "Failed"
    }
}

extension DateFormatter {
    static let fullISO8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension Date {
    var formatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        return formatter.string(from: self)
    }
}
