//
//  EventViewController.swift
//  Napkin
//
//  Created by Daniel Green on 05/07/2015.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import XLForm
import Luncheon

class EventViewController: NapkinViewController {
    var event = Event()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func subject() -> Lunch {
        return self.event
    }
    
    override func setupFields() {
        input("title")
        input("location")
        
        sectionSeparator()
        
        input("allDay", label: "All-day")
        input("starts")
        input("ends")
        
        input("repeatInterval", label: "Repeat", collection: [
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
            0: "Busy",
            1: "Free"
        ])
        
        sectionSeparator()
        
        input("URL", type: .URL)
        input("notes", type: .Text)
    }

}

// Swift requires that these be literal, but they match up with XLFormRowDescriptorType
enum InputType: String {
    case Text = "textView"
    case URL = "url"
}

//TODO: move this into another file
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
        let form = XLFormDescriptor(title: "Add \(subject()!.remote.subjectClassNameUnderscore().titleize())")
        self.form = form
        
        sectionSeparator()
        setupFields()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func subject() -> Lunch? {
        return nil
    }
    
    func setupFields() {
        
    }
    
    func subjectClass() -> AnyObject.Type {
        return object_getClass(subject()) as AnyObject.Type
    }
    
    func input(fieldName: String, collection: [Int: String]? = nil, type: InputType? = nil, required: Bool = false, var label: String = "") {
        let modelValue = subject()!.valueForKey(fieldName)
        
        if label.isEmpty {
            label = fieldName.underscoreCase().titleize()
        }
        
        var fieldType = ClassInspector.propertyTypes(subjectClass())[fieldName]
        if fieldType == nil {
            fieldType = PropertyType.Other
        }
        
        var rowType: String
        
        if type != nil {
            rowType = type!.rawValue
        } else {
            switch fieldType! {
            case .NSDate:
                rowType = XLFormRowDescriptorTypeDateTimeInline
            case .BOOL:
                rowType = XLFormRowDescriptorTypeBooleanSwitch
            default:
                rowType = XLFormRowDescriptorTypeText
            }
        }
        
        let row: XLFormRowDescriptor
        if let c = collection {
            rowType = XLFormRowDescriptorTypeSelectorPush
            row = XLFormRowDescriptor(tag: fieldName, rowType: rowType)
            var options = [XLFormOptionsObject]()
            
            let sortedKeys = Array(c.keys).sort(<)

            for key in sortedKeys {
                let option = XLFormOptionsObject(value: key, displayText: c[key])
                if key == modelValue as! Int {
                    row.value = option
                }
                options.append(option)
            }
            
            
            row.selectorTitle = label
            row.selectorOptions = options
            if modelValue == nil { row.value = options.first }
            
        } else {
            row = XLFormRowDescriptor(tag: fieldName, rowType: rowType)
            row.value = modelValue
        }
        
        if isRowTypeText(rowType) {
            row.cellConfigAtConfigure["textField.placeholder"] = label
        } else if rowType == XLFormRowDescriptorTypeTextView {
            row.cellConfigAtConfigure["textView.placeholder"] = "Notes"
        } else {
            row.title = label
        }
        
        row.required = required
        currentSection?.addFormRow(row)
    }
    
    private func isRowTypeText(rowType: String) -> Bool {
        return rowType == XLFormRowDescriptorTypeText
            || rowType == XLFormRowDescriptorTypeURL
            || rowType == XLFormRowDescriptorTypeEmail
            || rowType == XLFormRowDescriptorTypePassword
    }
    
    func sectionSeparator() {
        currentSection = XLFormSectionDescriptor.formSection()
        form.addFormSection(currentSection)
    }
}