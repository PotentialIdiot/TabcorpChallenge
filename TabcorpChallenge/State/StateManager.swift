//
//  StateManager.swift
//  TabcorpChallenge
//
//  Created by Weng hou Chan on 22/11/19.
//  Copyright © 2019 TABCORP. All rights reserved.
//

import Foundation

class StateManager {
    var statusFilter: LaunchStatus {
        didSet {
            NotificationCenter.default.post(name: .updateTable, object: nil)
        }
    }
    var orderFilter: OrderBy {
        didSet {
            NotificationCenter.default.post(name: .updateTable, object: nil)
        }
    }
    
    init() {
        statusFilter = .all
        orderFilter = .letter
    }
}

extension Notification.Name {
    static let updateTable = Notification.Name("updateTable")
}

let stateManager = StateManager()
