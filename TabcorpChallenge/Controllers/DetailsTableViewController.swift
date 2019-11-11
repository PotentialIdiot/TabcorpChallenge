//
//  DetailsTableViewController.swift
//  TabcorpChallenge
//
//  Created by Weng hou Chan on 10/11/19.
//  Copyright © 2019 TABCORP. All rights reserved.
//

import UIKit

class DetailsTableViewController: UITableViewController {
    @IBOutlet weak var launchName: UILabel!
    @IBOutlet weak var launchDate: UILabel!
    @IBOutlet weak var launchStatus: UILabel!
    
    @IBOutlet weak var launchPayloads: UILabel!
    
    @IBOutlet weak var launchSitename: UILabel!
    
    @IBOutlet weak var rocketName: UILabel!
    @IBOutlet weak var rocketCountry: UILabel!
    @IBOutlet weak var rocketCompany: UILabel!
    @IBOutlet weak var rocketDescription: UILabel!
    
    var launchFlightNumber: Int!
    var launch: Launch!
    var rocket: Rocket!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchLaunch()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.tableView(tableView, numberOfRowsInSection: 0)
    }

    // maybe hide button until description is populated
    @IBAction func moreInfoTapped(_ sender: Any) {
        UIApplication.shared.open(rocket.wikipedia)
    }
}

extension DetailsTableViewController {
    func fetchLaunch() {
        let url = URL(string: "https://api.spacexdata.com/v3/launches")!
            .appendingPathComponent("\(launchFlightNumber!)")
        let request = NetworkRequest(url: url)
        request.execute { [weak self] (data) in
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.fullISO8601)
                if let launch = try? decoder.decode(Launch.self, from: data) {
                    self?.set(launch)
                    self?.launch = launch
                    self?.fetchRocket()
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    func set(_ launch: Launch) {
        launchName.text = launch.missionName
        launchDate.text = launch.date.description
        launchStatus.text = launch.succeeded?.formatted ?? "Unknown"
        
        launchPayloads.text = launch.payloads
        launchSitename.text = launch.site
    }
    
    func fetchRocket() {
        let url = URL(string: "https://api.spacexdata.com/v3/rockets")!
            .appendingPathComponent("\(launch.rocketId)")
        let request = NetworkRequest(url: url)
        request.execute { [weak self] (data) in
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(DateFormatter.fullISO8601)
                if let rocket = try? decoder.decode(Rocket.self, from: data) {
                    self?.setRocket(rocket)
                    self?.rocket = rocket
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    func setRocket(_ rocket: Rocket) {
        rocketName.text = rocket.rocketName
        rocketCountry.text = rocket.country
        rocketCompany.text = rocket.company
        rocketDescription.text = rocket.description
    }
}
