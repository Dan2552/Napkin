//
//  ShowViewController.swift
//  Pods
//
//  Created by Dan on 25/09/2016.
//
//

import UIKit
import Luncheon
import Placemat

open class ShowViewController: EditViewController {
    override open func subject() -> Lunch! {
        return nil
    }
    
    open override func viewDidLoad() {
        tableView = setupTableView(style: .plain)
        super.viewDidLoad()
        
        title = "\(String.nameFor(object: subject()).titleize()) Details"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(editWasTapped)
        )
        
        tableView?.tableFooterView = UIView()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        reload()
        super.viewDidAppear(animated)
    }
    
    override open func useDefaultEditModalButtons() -> Bool {
        return false
    }

    open func editWasTapped() {
        
    }
}
