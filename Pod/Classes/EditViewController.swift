import Luncheon
import Eureka
import Placemat

public class EditViewController: FormViewController {
    private var currentSection: Section?
    private var collections = [String : [Int: String]]()
    public var new: Bool = true
    
    private var overrideHeight = [NSIndexPath: CGFloat]()
    
    public required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    internal func initializeForm() {
        sectionSeparator()
        setupFields()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        if useDefaultEditModalButtons() && isModal {
            
            let verb = new ? "Add" : "Edit"
            title = "\(verb) \(String.nameFor(subject()).titleize())"
            
            navigationItem.leftBarButtonItem = BlockBarButtonItem(barButtonSystemItem: .Cancel) {
                self.cancelWasTapped()
            }
            
            navigationItem.rightBarButtonItem = BlockBarButtonItem(barButtonSystemItem: .Save) {
                self.setValuesToSubject()
                self.saveWasTapped()
            }
        }
        initializeForm()
    }

    public func useDefaultEditModalButtons() -> Bool {
        return true
    }

    public func saveWasTapped() {
        Navigation(viewController: self).dismiss()
    }
    
    public func cancelWasTapped() {
        Navigation(viewController: self).dismiss()
    }
    
    public func subject() -> Lunch! {
        return nil
    }
    
    public func setupFields() {
        
    }
    
    func subjectClass() -> AnyObject.Type {
        return object_getClass(subject()) as AnyObject.Type
    }

    private func propertyType(fieldName: String) -> PropertyType {
        return ClassInspector.propertyTypes(subjectClass())[fieldName] ?? PropertyType.Other
    }
    
    public override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let override = overrideHeight[indexPath] {
            return override
        }

        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    public func detail(fieldName: String = "",
                       collection: [Int: String]? = nil,
                       type: InputType? = nil,
                       label: String = "",
                       detail: String? = nil,
                       customView: UIView? = nil,
                       action: (()->())? = nil) {
        var label = label
        var detail = detail
        
        let modelField = !fieldName.isEmpty
        
        var modelValue: AnyObject? = nil
        if modelField {
            modelValue = valueFor(fieldName)
        }
        
        let indexPath = NSIndexPath(forRow: self.currentSection!.endIndex, inSection: self.currentSection!.index!)
        
        if let custom = customView {
            overrideHeight[indexPath] = custom.frame.height + (custom.frame.origin.y * 2)
            
            custom.autoresizingMask = UIViewAutoresizing.FlexibleWidth
            
            let row = LabelRow().cellSetup { cell, _ in cell.addSubview(custom) }
            
            currentSection?.append(row)
            return
        }

        if (detail ?? "").isEmpty {
            if let value = valueFor(fieldName) {
                detail = "\(value)"
            }
        }
        
        if (detail ?? "").isEmpty && label.isEmpty && customView == nil {
            return
        }
        
        if label.isEmpty {
            label = labelFor(fieldName)
        }

        let row = LabelRow() {
            $0.title = label
            $0.value = detail
            $0.cellStyle = .Subtitle
        }.cellUpdate { cell, _ in
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.textColor = UIColor.grayColor()
            if action != nil {
                cell.accessoryType = .DisclosureIndicator
            }
            
        }

        if let detail = detail {
            overrideHeight[indexPath] = heightOfLabelCell(label, detail: detail)
        }
        
        if let action = action {
            row.onCellSelection { _, _ in action() }
        }
        
        currentSection?.append(row)
    }
    
    private func heightOfLabelCell(label: String, detail: String) -> CGFloat {
        let measure = LabelCell(style: .Subtitle, reuseIdentifier: nil)
        measure.textLabel?.text = label
        measure.detailTextLabel?.text = detail
        let layoutMargins = measure.contentView.layoutMargins
        let labelHeight = heightOfLabel(measure.textLabel!, layoutMargins: layoutMargins)
        let detailHeight = heightOfLabel(measure.detailTextLabel!, layoutMargins: layoutMargins)
        
        let topMargin = layoutMargins.top
        let bottomMargin = layoutMargins.bottom
        
        return topMargin + labelHeight + detailHeight + bottomMargin
    }
    
    private func heightOfLabel(label: UILabel, layoutMargins: UIEdgeInsets) -> CGFloat {
        guard let text = label.text else { return 0 }
        
        let size = CGSize(width: tableView!.frame.width - layoutMargins.left - layoutMargins.right, height: 1000)
        let rect = text.boundingRectWithSize(size, options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: label.font], context: nil)
        return rect.size.height
    }

    public func input(fieldName: String = "",
                      collection: [Int: String]? = nil,
                      type: InputType? = nil,
                      label: String = "",
                      detail: String? = nil,
                      action: (()->())? = nil) {
        var type = type
        var label = label
        let modelField = !fieldName.isEmpty
        
        var modelValue: AnyObject? = nil
        if modelField {
           modelValue = valueFor(fieldName)
        }

        if label.isEmpty {
            label = labelFor(fieldName)
        }

        if type == nil {
            type = inputTypeFor(fieldName, collection: collection, customAction: action)
        }
  
        var row: BaseRow

        switch type! {
        case .Password:
            let passwordRow = PasswordRow()
            row = passwordRow

            passwordRow.placeholder = label
            if let value = modelValue as? String {
                passwordRow.value = value
            }
        case .Collection:
            var pushRow = PushRow<String>()
            row = pushRow
            
            if let collection = collection {
                if let action = action {
                    pushRow = PushRow<String>().onChange { _ in action() }
                    row = pushRow
                }
                
                collections[fieldName] = collection

                pushRow.options = collection.sort { $0.0 < $1.0 }.map { $1 }
                if let modelValue = modelValue as? Int {
                    pushRow.value = collection.filter { $0.0 == modelValue }.first?.1
                }
                pushRow.value = pushRow.value ?? collection.first?.1
            } else if let action = action {
                let pushRow = CustomActionPushRow<String>()
                row = pushRow
                if let modelValue = modelValue as? String {
                    pushRow.value = modelValue
                }
                pushRow.onCellSelection { _, _ in action() }
            }
        case .Switch:
            let switchRow = SwitchRow()
            row = switchRow
            if let value = modelValue as? Bool {
                switchRow.value = value
            }
        case .DateInLine:
            let dateInLineRow = DateTimeInlineRow()
            row = dateInLineRow

            if let value = modelValue as? NSDate {
                dateInLineRow.value = value
            }
        case .URL:
            let urlRow = URLRow()
            row = urlRow

            urlRow.placeholder = label

            if let value = modelValue as? String {
                urlRow.value = NSURL(string: value)
            }
        case .Text:
            let textAreaRow = TextAreaRow()
            row = textAreaRow

            textAreaRow.placeholder = label

            if let value = modelValue as? String {
                textAreaRow.value = value
            }
        case .Int:
            let numberRow = IntRow()
            row = numberRow

            if let value = modelValue as? Int {
                numberRow.value = value
            }
        default:
            let textRow = TextRow()
            row = textRow

            textRow.placeholder = label

            if let value = modelValue as? String {
                textRow.value = value
            }
        }

        if !isStringAlike(type) {
            row.title = label
        }

        if modelField {
            row.tag = fieldName
        } else {
            row.tag = label
        }

        currentSection?.append(row)
    }

    public func sectionSeparator(header: String = "", footer: String = "") {
        currentSection = Section(header: header, footer: footer)
        form +++ currentSection!
    }
    
    public func button(title: String, action: ()->()) {
        let button = ButtonRow(title)
        button.title = title
        button.onCellSelection { _, _ in action() }
        currentSection?.append(button)
    }
    
    public func setValuesToSubject() {
        for (fieldName, value) in form.values() {
            guard var v = value as? AnyObject? else { continue }

            if let collection = collections[fieldName] {
                v = collection.filter { $1 == (v as! String) }.first?.0
            }

            subject()?.local.assignAttribute(fieldName, withValue: v)
        }
    }
    
    private func isStringAlike(type: InputType?) -> Bool {
        guard let type = type else { return false }
        
        return type == .String
            || type == .URL
            || type == .Email
            || type == .Password
            || type == .Text
    }
    
    public func valueFor(fieldName: String) -> AnyObject? {
        guard subject().local.properties().contains(fieldName) else { return nil }
        return subject()?.valueForKey(fieldName)
    }
    
    public func labelFor(fieldName: String) -> String {
        return fieldName.underscoreCase().titleize()
    }
    
    private func inputTypeFor(fieldName: String, collection: [Int: String]? = nil, customAction: (()->())? = nil) -> InputType {
        let type: InputType
        let fieldType = propertyType(fieldName)
        if collection != nil || customAction != nil {
            type = .Collection
        } else {
            switch fieldType {
            case .Date:
                type = .DateInLine
            case .Bool:
                type = .Switch
            case .Int:
                type = .Int
            default:
                type = .String
            }
        }
        return type
    }
}