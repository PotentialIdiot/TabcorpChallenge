//
//  LaunchViewModel.swift
//  TabcorpChallenge
//
//  Created by Weng hou Chan on 12/11/19.
//  Copyright © 2019 TABCORP. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct LaunchListViewModel {
    let launchesVM: [LaunchViewModel]
}

extension LaunchListViewModel {
    
    init(_ launches: [Launch]) {
        self.launchesVM = launches.compactMap(LaunchViewModel.init)
    }
    
}

extension LaunchListViewModel {
    
    func launchAt(_ index: Int) -> LaunchViewModel {
        return self.launchesVM[index]
    }
}

struct LaunchViewModel {
    
    let launch: Launch
    
    init(_ launch: Launch) {
        self.launch = launch
    }
    
}

extension LaunchViewModel {
    
    var mission: Observable<String> {
        return Observable<String>.just(launch.missionName)
    }
    
    var date: Observable<String> {
        return Observable<String>.just(launch.date.formatted)
    }
    
    var status: Observable<String> {
        return Observable<String>.just(launch.succeeded?.formatted ?? "Unknown")
    }
}
