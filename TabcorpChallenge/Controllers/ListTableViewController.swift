//
//  GroupedTableViewController.swift
//  TabcorpChallenge
//
//  Created by Weng hou Chan on 10/11/19.
//  Copyright © 2019 TABCORP. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    var sectionHeaders = [String]()
    var launchesDict = [String: [Launch]]()
    
    var launches = [Launch]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://api.spacexdata.com/v3/launches?limit=10")!
        let request = NetworkRequest(url: url)
        request.execute { [weak self] (data) in
            if let data = data {
                self?.decode(data)
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(updateSuccessFilter), name: .updateSuccessFilter, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateSortFilter), name: .updateSortFilter, object: nil)
    }
    
    @objc func updateSuccessFilter(_ value: Notification) {
        var filteredLaunches = [Launch]()
        
        let value = value.object as! SuccessFilter
        switch value {
        case .Success:
            filteredLaunches = launches.filter({ $0.succeeded == true })
        case .Failure:
            filteredLaunches = launches.filter({ $0.succeeded == false })
        case .Unknown:
            filteredLaunches = launches.filter({ $0.succeeded == nil })
        case .None:
            filteredLaunches = launches
        }
        
        // dependency on filter launches func issue
        sort(filteredLaunches, by: .letter)
        tableView.reloadData()
    }
    
    @objc func updateSortFilter(_ value: Notification) {
        let value = value.object as! Int
        switch value {
        case 0:
            sort(launches, by: .letter)
            tableView.reloadData()
        case 1:
            sort(launches, by: .year)
            tableView.reloadData()
        default:
            assertionFailure("unhandled switch case")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow,
            let detailsViewController = segue.destination as? DetailsTableViewController {
            detailsViewController.launchFlightNumber = launchesDict[sectionHeaders[indexPath.section]]![indexPath.row].flightNumber
        }
    }
    
    enum SortFilter {
        case letter, year
    }
    
    func sort(_ launches: [Launch], by filter: SortFilter) {
        var groupedLaunches = [String: [Launch]]()
        switch filter {
        case .letter:
            groupedLaunches = Dictionary(grouping: launches, by: { String($0.missionName.uppercased().first!) })
        case .year:
            groupedLaunches = Dictionary(grouping: launches, by: { $0.date.description })
        }
        
        launchesDict = groupedLaunches
        sectionHeaders = Array(groupedLaunches.keys).sorted()
    }
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(sectionHeaders[section])
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionHeaders.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return launchesDict[sectionHeaders[section]]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LaunchCell", for: indexPath) as! LaunchCell

        // Configure the cell...
        let launchInfo = launchesDict[sectionHeaders[indexPath.section]]![indexPath.row]
        cell.missionLabel.text = launchInfo.missionName
        cell.dateLabel.text = launchInfo.date.description
        cell.statusLabel.text = launchInfo.succeeded?.formatted ?? "Unknown"

        return cell
    }

}

private extension ListTableViewController {
    func decode(_ data: Data) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.fullISO8601)
        do {
            launches = try decoder.decode([Launch].self, from: data)
            print(launches)
            sort(launches, by: .letter)
            tableView.reloadData()
        } catch {
            let title = "Oops, something went wrong"
            let message = "Please make sure you have the latest version of the app."
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: title, style: .default, handler: nil)
            alertController.addAction(dismissAction)
            show(alertController, sender: nil)
        }
    }
}

class LaunchCell: UITableViewCell {
    @IBOutlet weak var missionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
}

