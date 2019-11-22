//
//  ListDataSource.swift
//  TabcorpChallenge
//
//  Created by Weng hou Chan on 22/11/19.
//  Copyright © 2019 TABCORP. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

extension ListTableViewController {
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(sectionHeaders[section])
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionHeaders.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = sectionHeaders[section]
        return launchesVMDict[key]?.launchesVM.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LaunchCell", for: indexPath) as! LaunchCell
        
        // Configure the cell...
        let key = sectionHeaders[indexPath.section]
        let launchVM = launchesVMDict[key]!.launchAt(indexPath.row)
        
        launchVM.mission.asDriver(onErrorJustReturn: "")
            .drive(cell.missionLabel.rx.text)
            .disposed(by: disposeBag)
        
        launchVM.date.asDriver(onErrorJustReturn: "")
            .drive(cell.dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        launchVM.status.asDriver(onErrorJustReturn: "")
            .drive(cell.statusLabel.rx.text)
            .disposed(by: disposeBag)
        
        return cell
    }
}
