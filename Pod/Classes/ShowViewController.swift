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

public class ShowViewController: EditViewController {
    override public func subject() -> Lunch! {
        return nil
    }
    
    public override func viewDidLoad() {
        tableView = setupTableView(style: .Plain)
        super.viewDidLoad()
        
        title = "\(String.nameFor(subject()).titleize()) Details"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Edit,
            target: self,
            action: #selector(editWasTapped)
        )
        
        tableView?.tableFooterView = UIView()
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView?.reloadData()
    }
    
    override public func useDefaultEditModalButtons() -> Bool {
        return false
    }

    public func editWasTapped() {
        
    }
}