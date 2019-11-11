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

enum SuccessFilter: String {
    case success
    case failure
    case unknown
    case all
}

class MainViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var sortFilter: UISegmentedControl!
    
    override func viewDidLoad() {
        // setup sort filter
        sortFilter.rx.controlEvent(.valueChanged)
            .asObservable()
            .map { self.sortFilter.selectedSegmentIndex }
            .subscribe(onNext: { index in
                NotificationCenter.default.post(name: .updateSortFilter, object: index)
            }).disposed(by: disposeBag)
    }
    
    @IBAction func successFilterTapped(_ sender: Any) {
        let title = "Launch Status"
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: SuccessFilter.success.rawValue, style: .default, handler: { _ in
            NotificationCenter.default.post(name: .updateSuccessFilter, object: SuccessFilter.success)
        }))
        alert.addAction(UIAlertAction(title: SuccessFilter.failure.rawValue, style: .default, handler: { _ in
            NotificationCenter.default.post(name: .updateSuccessFilter, object: SuccessFilter.failure)
        }))
        alert.addAction(UIAlertAction(title: SuccessFilter.unknown.rawValue, style: .default, handler: { _ in
            NotificationCenter.default.post(name: .updateSuccessFilter, object: SuccessFilter.unknown)
        }))
        alert.addAction(UIAlertAction(title: SuccessFilter.all.rawValue, style: .default, handler: { _ in
            NotificationCenter.default.post(name: .updateSuccessFilter, object: SuccessFilter.all)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }

}

extension Notification.Name {
    static let updateSortFilter = Notification.Name("updateSortFilter")
    static let updateSuccessFilter = Notification.Name("updateSuccessFilter")
}
