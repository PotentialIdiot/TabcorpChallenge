//
//  URLRequest+Extensions.swift
//  TabcorpChallenge
//
//  Created by Weng hou Chan on 10/11/19.
//  Copyright © 2019 TABCORP. All rights reserved.
//

import Foundation
import RxSwift

struct Resource<T: Decodable> {
    let url: URL
}

extension URLRequest {
    
    static func load<T>(resource: Resource<T>) -> Observable<T?> {
        
        return Observable.from([resource.url])
            .flatMap { url -> Observable<Data> in
                let request = URLRequest(url: url)
                return URLSession.shared.rx.data(request: request)
            }.map { data -> T? in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.fullISO8601)
                return try decoder.decode(T.self, from: data)
        }
    }
}
