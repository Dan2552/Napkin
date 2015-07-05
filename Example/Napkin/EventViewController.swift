//
//  EventViewController.swift
//  Napkin
//
//  Created by Daniel Green on 05/07/2015.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import XLForm

class EventViewController: NapkinViewController {
    var event = Event()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view is loaded")
    }
    
    override func subject() -> AnyObject {
        return self.event
    }
    
    override func setupFields() {
        input("title")
        input("location")
        
        sectionSeparator()
        
        input("allDay")
        input("starts")
        input("ends")
        
        input("repeatInterval", collection: [
            0: "Never",
            1: "Every Day",
            2: "Every Week",
            3: "Every 2 Weeks",
            4: "Every Month",
            5: "Every Year"
        ])
        
        sectionSeparator()
        
        input("alert", collection: [
            0: "None",
            1: "At time of event",
            2: "5 minutes before",
            3: "15 minutes before",
            4: "30 minutes before",
            5: "1 hour before",
            6: "2 hours before",
            7: "1 day before",
            8: "2 days before"
        ])
        input("showAs", collection: [
            0: "None",
            1: "Free"
        ])
        
        sectionSeparator()
        
        input("URL")
        input("notes", type: .Text)
    }

}

enum InputType {
    case Text
}

class NapkinViewController: XLFormViewController {
    private var currentSection: XLFormSectionDescriptor?
    
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initializeForm()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeForm()
    }
    
    private func initializeForm() {
        let form = XLFormDescriptor(title: "TODO")
        self.form = form
        
        sectionSeparator()
        setupFields()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func subject() -> AnyObject? {
        return nil
    }
    
    func setupFields() {
        
    }
    
    func input(fieldName: String, collection: [Int: String]? = nil, type: InputType? = nil) {
        print("input")
        let row = XLFormRowDescriptor(tag: fieldName, rowType: XLFormRowDescriptorTypeText)
        row.cellConfigAtConfigure["textField.placeholder"] = fieldName
        row.required = true
        
        currentSection?.addFormRow(row)
    }
    
    func sectionSeparator() {
        print("separator")
        currentSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(currentSection)
    }
}