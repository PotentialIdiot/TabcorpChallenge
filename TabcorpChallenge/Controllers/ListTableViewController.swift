//
//  ListTableViewController.swift
//  TabcorpChallenge
//
//  Created by Weng hou Chan on 10/11/19.
//  Copyright © 2019 TABCORP. All rights reserved.
//

import UIKit
import RxSwift

final class ListTableViewController: UITableViewController {
    
    let disposeBag = DisposeBag()
    
    // raw data
    private var launches = [Launch]()
    
    // processed data, used by table data source
    var launchesVMDict = [String: LaunchListViewModel]()
    var sectionHeaders = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup data
        fetchLaunches(completion: {
            self.processData(to: &self.launchesVMDict, &self.sectionHeaders)
        })
        
        // observe changes
        NotificationCenter.default.addObserver(self, selector: #selector(updateTable), name: .updateTable, object: nil)
    }
    
    @objc private func updateTable(_ value: Notification) {
        // update data
        processData(to: &launchesVMDict, &sectionHeaders)
        tableView.reloadData()
    }
    
    // MARK : - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow,
            // detail view controller
            let detailsViewController = segue.destination as? DetailsTableViewController {
            let key = sectionHeaders[indexPath.section]
            let flightNumber = launchesVMDict[key]!.launchAt(indexPath.row).launch.flightNumber
            // pass detail view the flightNumber identifier
            detailsViewController.launchFlightNumber = flightNumber
        }
    }

}


// MARK : - Data
private extension ListTableViewController {
    private func fetchLaunches(completion: @escaping ()->()) {
        
        let filterParams = generateJSONParameters(Launch.CodingKeys.self)
        let url = URL(string: Constants.base_api + Constants.api_launches + "?limit=10&" + filterParams)!
        let resource = Resource<[Launch]>(url: url)
        
        URLRequest.load(resource: resource)
            .subscribe(onNext: { [weak self] result in
                if let result = result {
                    self?.launches = result
                    
                    DispatchQueue.main.async {
                        completion()
                        self?.tableView.reloadData()
                    }
                }
            }).disposed(by: disposeBag)
        
    }

    private func processData(to launchesVMDict: inout [String: LaunchListViewModel],
                             _ sectionHeaders: inout [String]) {
        let filteredData: [Launch]                          = filter(launches)
        let groupedData: [String: [Launch]]                 = group(filteredData)
        let transformedData: [String:LaunchListViewModel]   = transform(groupedData)
        let sections: [String]                              = Array(groupedData.keys).sorted()
        
        launchesVMDict = transformedData
        sectionHeaders = sections
    }
}


// MARK : - Filters
extension ListTableViewController {
    private func filter(_ launches: [Launch]) -> [Launch] {
        let status = stateManager.statusFilter
        var filteredLaunches = [Launch]()
        switch status {
        case .success:
            filteredLaunches = launches.filter({ $0.succeeded == true })
        case .failure:
            filteredLaunches = launches.filter({ $0.succeeded == false })
        case .unknown:
            filteredLaunches = launches.filter({ $0.succeeded == nil })
        case .all:
            filteredLaunches = launches
        }
        return filteredLaunches
    }
    
    private func group(_ launches: [Launch]) -> [String: [Launch]] {
        // group launches by filter
        let orderBy = stateManager.orderFilter
        var groupedLaunches = [String: [Launch]]()
        switch orderBy {
        case .letter:
            groupedLaunches = Dictionary(grouping: launches, by: { String($0.missionName.uppercased().first!) })
        case .year:
            groupedLaunches = Dictionary(grouping: launches, by: {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy"
                return dateFormatter.string(from: $0.date)
            })
            
        }
        return groupedLaunches
    }
    
    private func transform(_ groupedLaunches: [String: [Launch]]) -> [String:LaunchListViewModel] {
        var result = [String: LaunchListViewModel]()
        for key in groupedLaunches.keys {
            result[key] = groupedLaunches[key].map { LaunchListViewModel($0) }
        }
        return result
    }
}
