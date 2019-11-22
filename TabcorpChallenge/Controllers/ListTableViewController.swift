//
//  ListTableViewController.swift
//  TabcorpChallenge
//
//  Created by Weng hou Chan on 10/11/19.
//  Copyright © 2019 TABCORP. All rights reserved.
//

import UIKit
import RxSwift

enum SortFilter {
    case letter, year
}

final class ListTableViewController: UITableViewController {
    
    private let disposeBag = DisposeBag()

    private var launches = [Launch]()

    private var sectionHeaders = [String]()
    private var launchesVMDict = [String: LaunchListViewModel]()
    
    private var sortFilter: SortFilter = .letter
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchLaunches(completion: {
            self.processData()
        })
        NotificationCenter.default.addObserver(self, selector: #selector(updateTable), name: .updateTable, object: nil)
    }
    
    @objc private func updateTable(_ value: Notification) {
        processData()
        tableView.reloadData()
    }
    
}

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow,
            let detailsViewController = segue.destination as? DetailsTableViewController {
            let key = sectionHeaders[indexPath.section]
            let flightNumber = launchesVMDict[key]!.launchAt(indexPath.row).launch.flightNumber
            detailsViewController.launchFlightNumber = flightNumber
        }
    }

}

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
}

extension ListTableViewController {
    private func processData() {
        let filteredByStatus = filter(launches, by: stateManager.statusFilter)
        let sortedByOrder = sort(filteredByStatus, by: stateManager.orderFilter)
        launchesVMDict = sortedByOrder.0
        sectionHeaders = sortedByOrder.1
    }
}

extension ListTableViewController {
    private func filter(_ launches: [Launch], by status: LaunchStatus) -> [Launch] {
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
    
    private func sort(_ launches: [Launch], by order: OrderBy) -> ([String:LaunchListViewModel],[String]){
        // group launches by filter
        var groupedLaunches = [String: [Launch]]()
        switch order {
        case .letter:
            groupedLaunches = Dictionary(grouping: launches, by: { String($0.missionName.uppercased().first!) })
        case .year:
            groupedLaunches = Dictionary(grouping: launches, by: {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy"
                return dateFormatter.string(from: $0.date)
            })
            
        }
        
        // transform [launch] -> launchListViewModel
        var groupedLaunchesVM = [String: LaunchListViewModel]()
        for key in groupedLaunches.keys {
            groupedLaunchesVM[key] = groupedLaunches[key].map { LaunchListViewModel($0) }
        }
        
        let launchesVMDict = groupedLaunchesVM
        let sectionHeaders = Array(groupedLaunches.keys).sorted()
        
        return (launchesVMDict, sectionHeaders)
    }
}
