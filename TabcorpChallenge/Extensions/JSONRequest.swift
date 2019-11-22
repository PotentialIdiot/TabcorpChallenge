//
//  JSONRequest.swift
//  TabcorpChallenge
//
//  Created by Weng hou Chan on 22/11/19.
//  Copyright © 2019 TABCORP. All rights reserved.
//

import Foundation

// MARK : - Compose a filter url string from data Model parameters
func generateJSONParameters<T>(_ : T.Type) -> String
    where T: CaseIterable & RawRepresentable, T.RawValue == String, T.AllCases == [T] {
        var urlString = "filter="
        for key in T.allCases {
            guard let lastKey = T.allCases.last else {
                // this error should never occur. Hence, if it does, should stop the app in debugging mode
                assertionFailure("JSON parameter array empty")
                // return empty string without filter in production mode
                return ""
            }
            if key != lastKey {
                urlString.append(key.rawValue + ",")
            } else {
                urlString.append(key.rawValue)
            }
    }
    return urlString
}
