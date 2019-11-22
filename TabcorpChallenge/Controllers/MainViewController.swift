//
//  MainViewController.swift
//  TabcorpChallenge
//
//  Created by Weng hou Chan on 11/11/19.
//  Copyright © 2019 TABCORP. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

enum LaunchStatus: String {
    case success
    case failure
    case unknown
    case all
}

enum OrderBy: Int {
    case letter = 0
    case year
    
    init(rawValue: Int) {
        switch rawValue {
        case OrderBy.letter.rawValue:
            self = OrderBy.letter
        case OrderBy.year.rawValue:
            self = OrderBy.year
        default:
            self = OrderBy.letter
        }
    }
}

class MainViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var sortFilter: UISegmentedControl!
    
    override func viewDidLoad() {
        // MARK: - Filter #2 - by Alphabets and Date
        setupSortFilter()
    }
    
    // MARK: - Filter #1 - by Launch Status
    @IBAction func launchStatusButtonTapped(_ sender: Any) {
        let selectionAlert = launchStatusSelectionAlert()
        self.present(selectionAlert, animated: true)
    }

}

extension MainViewController {
    private func setupSortFilter() {
        sortFilter.rx.controlEvent(.valueChanged)
            .asObservable()
            .map { self.sortFilter.selectedSegmentIndex }
            .subscribe(onNext: { index in
                stateManager.orderFilter = OrderBy.init(rawValue: index)
            }).disposed(by: disposeBag)
    }
    
    private func launchStatusSelectionAlert() -> UIAlertController {
        let title = "Launch Status"
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LaunchStatus.success.rawValue, style: .default, handler: { _ in
            stateManager.statusFilter = LaunchStatus.success
        }))
        alert.addAction(UIAlertAction(title: LaunchStatus.failure.rawValue, style: .default, handler: { _ in
            stateManager.statusFilter = LaunchStatus.failure
        }))
        alert.addAction(UIAlertAction(title: LaunchStatus.unknown.rawValue, style: .default, handler: { _ in
            stateManager.statusFilter = LaunchStatus.unknown
        }))
        alert.addAction(UIAlertAction(title: LaunchStatus.all.rawValue, style: .default, handler: { _ in
            stateManager.statusFilter = LaunchStatus.all
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        return alert
    }
}
