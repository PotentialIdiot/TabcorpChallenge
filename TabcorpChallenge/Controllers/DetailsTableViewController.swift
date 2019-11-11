//
//  DetailsTableViewController.swift
//  TabcorpChallenge
//
//  Created by Weng hou Chan on 10/11/19.
//  Copyright © 2019 TABCORP. All rights reserved.
//

import UIKit
import SafariServices
import RxSwift

class DetailsTableViewController: UITableViewController {
    // Launch general info
    @IBOutlet weak var launchName: UILabel!
    @IBOutlet weak var launchDate: UILabel!
    @IBOutlet weak var launchStatus: UILabel!
    
    // payload
    @IBOutlet weak var launchPayloads: UILabel!
    
    // site
    @IBOutlet weak var launchSitename: UILabel!
    
    // Rocket general info
    @IBOutlet weak var rocketName: UILabel!
    @IBOutlet weak var rocketCountry: UILabel!
    @IBOutlet weak var rocketCompany: UILabel!
    @IBOutlet weak var rocketDescription: UILabel!
    
    // wikipedia
    @IBOutlet weak var wikipediaButton: UIButton!
    
    var launchFlightNumber: Int!
    var launch: Launch!
    var rocket: Rocket!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wikipediaButton.isEnabled = false
        
        fetchLaunch()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.tableView(tableView, numberOfRowsInSection: 0)
    }

    @IBAction func moreInfoTapped(_ sender: Any) {
        let svc = SFSafariViewController(url: rocket.wikipedia)
        present(svc, animated: true, completion: nil)
    }
}

extension DetailsTableViewController {
    
    private func fetchLaunch() {
        
        let url = URL(string: Constants.base_api + Constants.api_launches + String(launchFlightNumber))!
        let resource = Resource<Launch>(url: url)
        
        URLRequest.load(resource: resource)
            .subscribe(onNext: { [weak self] result in
                if let result = result {
                    self?.launch = result
                    self?.fetchRocket(by: result.rocketId)
                    DispatchQueue.main.async {
                        self?.set(result)
                        self?.tableView.reloadData()
                    }
                }
            }).disposed(by: disposeBag)
        
    }
    
    func set(_ launch: Launch) {
        launchName.text = launch.missionName
        launchDate.text = launch.date.formatted
        launchStatus.text = launch.succeeded?.formatted ?? "Unknown"
        launchPayloads.text = launch.payloads
        launchSitename.text = launch.site
    }
    
    private func fetchRocket(by id: String) {
        
        let url = URL(string: Constants.base_api + Constants.api_rockets + id)!
        let resource = Resource<Rocket>(url: url)
        
        URLRequest.load(resource: resource)
            .subscribe(onNext: { [weak self] result in
                if let result = result {
                    self?.rocket = result
                    DispatchQueue.main.async {
                        self?.set(result)
                        self?.tableView.reloadData()
                        self?.wikipediaButton.isEnabled = true
                    }
                }
            }).disposed(by: disposeBag)
        
    }
    
    func set(_ rocket: Rocket) {
        rocketName.text = rocket.rocketName
        rocketCountry.text = rocket.country
        rocketCompany.text = rocket.company
        rocketDescription.text = rocket.description
    }
}
