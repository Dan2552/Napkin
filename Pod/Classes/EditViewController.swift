import Luncheon
import Eureka
import Placemat

open class EditViewController: FormViewController {
    fileprivate var currentSection: Section?
    fileprivate var collections = [String : [Int: String]]()
    open var new: Bool = true
    
    fileprivate var overrideHeight = [IndexPath: CGFloat]()
    
    public required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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

    open override func viewDidLoad() {
        super.viewDidLoad()
        if useDefaultEditModalButtons() && isModal {
            
            let verb = new ? "Add" : "Edit"
            title = "\(verb) \(String.nameFor(object: subject()).titleize())"
            
            navigationItem.leftBarButtonItem = BlockBarButtonItem(barButtonSystemItem: .cancel) {
                self.cancelWasTapped()
            }
            
            navigationItem.rightBarButtonItem = BlockBarButtonItem(barButtonSystemItem: .save) {
                self.setValuesToSubject()
                self.saveWasTapped()
            }
        }
        initializeForm()
    }

    open func useDefaultEditModalButtons() -> Bool {
        return true
    }

    open func saveWasTapped() {
        Navigation(viewController: self).dismiss()
    }
    
    open func cancelWasTapped() {
        Navigation(viewController: self).dismiss()
    }
    
    open func subject() -> Lunch! {
        return nil
    }
    
    open func setupFields() {
        
    }
    
    func subjectClass() -> AnyObject.Type {
        return object_getClass(subject()) as AnyObject.Type
    }

    fileprivate func propertyType(_ fieldName: String) -> PropertyType {
        return ClassInspector.propertyTypes(subjectClass())[fieldName] ?? PropertyType.other
    }
    
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let override = overrideHeight[indexPath] {
            return override
        }

        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    open func detail(_ fieldName: String = "",
                       type: InputType? = nil,
                       label: String = "",
                       detail: String? = nil,
                       customView: UIView? = nil,
                       collection: [Int: String]? = nil,
                       action: (()->())? = nil) {
        var label = label
        var detail = detail
        
        let modelField = !fieldName.isEmpty
        
        var modelValue: Any? = nil
        if modelField {
            modelValue = value(forField: fieldName)
        }
        
        let indexPath = IndexPath(row: currentSection!.endIndex, section: currentSection!.index!)
        
        if let custom = customView {
            overrideHeight[indexPath] = custom.frame.height + (custom.frame.origin.y * 2)
            
            custom.autoresizingMask = UIViewAutoresizing.flexibleWidth
            
            let row = LabelRow().cellSetup { cell, _ in cell.addSubview(custom) }
            
            currentSection?.append(row)
            return
        }

        if (detail ?? "").isEmpty {
            if let value = value(forField: fieldName) {
                detail = "\(value)"
            }
        }
        
        if (detail ?? "").isEmpty && label.isEmpty && customView == nil {
            return
        }
        
        if label.isEmpty {
            label = self.label(forField: fieldName)
        }

        let row = LabelRow() {
            $0.title = label
            $0.value = detail
            $0.cellStyle = .subtitle
        }.cellUpdate { cell, _ in
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.textColor = UIColor.gray
            if action != nil {
                cell.accessoryType = .disclosureIndicator
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
    
    fileprivate func heightOfLabelCell(_ label: String, detail: String) -> CGFloat {
        let measure = LabelCell(style: .subtitle, reuseIdentifier: nil)
        measure.textLabel?.text = label
        measure.detailTextLabel?.text = detail
        let layoutMargins = measure.contentView.layoutMargins
        let labelHeight = heightOfLabel(measure.textLabel!, layoutMargins: layoutMargins)
        let detailHeight = heightOfLabel(measure.detailTextLabel!, layoutMargins: layoutMargins)
        
        let topMargin = layoutMargins.top
        let bottomMargin = layoutMargins.bottom
        
        return topMargin + labelHeight + detailHeight + bottomMargin
    }
    
    fileprivate func heightOfLabel(_ label: UILabel, layoutMargins: UIEdgeInsets) -> CGFloat {
        guard let text = label.text else { return 0 }
        
        let size = CGSize(width: (tableView?.frame.width)! - layoutMargins.left - layoutMargins.right, height: 1000)
        let rect = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: label.font], context: nil)
        return rect.size.height
    }

    open func input(_ fieldName: String = "",
                      type: InputType? = nil,
                      label: String = "",
                      detail: String? = nil,
                      collection: [Int: String]? = nil,
                      action: (()->())? = nil) {
        var type = type
        var label = label
        let modelField = !fieldName.isEmpty
        
        var modelValue: Any? = nil
        if modelField {
            modelValue = value(forField: fieldName)
        }

        if label.isEmpty {
            label = self.label(forField: fieldName)
        }

        if type == nil {
            type = inputTypeFor(fieldName, collection: collection, customAction: action)
        }
  
        var row: BaseRow

        switch type! {
        case .password:
            let passwordRow = PasswordRow()
            row = passwordRow

            passwordRow.placeholder = label
            if let value = modelValue as? String {
                passwordRow.value = value
            }
        case .collection:
            var pushRow = PushRow<String>()
            row = pushRow
            
            if let collection = collection {
                if let action = action {
                    pushRow = PushRow<String>().onChange { _ in action() }
                    row = pushRow
                }
                
                collections[fieldName] = collection

                pushRow.options = collection.sorted { $0.0 < $1.0 }.map { $1 }
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
            
            pushRow.onPresent { form, selectorController in selectorController.enableDeselection = false }
        case .switch:
            let switchRow = SwitchRow()
            row = switchRow
            if let value = modelValue as? Bool {
                switchRow.value = value
            }
        case .dateInLine:
            let dateInLineRow = DateTimeInlineRow()
            row = dateInLineRow

            if let value = modelValue as? Date {
                dateInLineRow.value = value
            }
        case .url:
            let urlRow = URLRow()
            row = urlRow

            urlRow.placeholder = label

            if let value = modelValue as? String {
                urlRow.value = URL(string: value)
            }
        case .text:
            let textAreaRow = TextAreaRow()
            row = textAreaRow

            textAreaRow.placeholder = label

            if let value = modelValue as? String {
                textAreaRow.value = value
            }
        case .int:
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

    open func sectionSeparator(_ header: String = "", footer: String = "") {
        currentSection = Section(header: header, footer: footer)
        form +++ currentSection!
    }
    
    open func button(_ title: String, action: @escaping ()->()) {
        let button = ButtonRow(title)
        button.title = title
        button.onCellSelection { _, _ in action() }
        currentSection?.append(button)
    }
    
    open func setValuesToSubject() {
        for (fieldName, value) in form.values() {
            guard var v = value as? AnyObject? else { continue }

            if let collection = collections[fieldName] {
                v = collection.filter { $1 == (v as! String) }.first?.0 as AnyObject?
            }

            subject()?.local.assignAttribute(fieldName, withValue: v)
        }
    }
    
    fileprivate func isStringAlike(_ type: InputType?) -> Bool {
        guard let type = type else { return false }
        
        return type == .string
            || type == .url
            || type == .email
            || type == .password
            || type == .text
    }
    
    open func value(forField fieldName: String) -> Any? {
        guard subject().local.properties().contains(fieldName) else { return nil }
        return subject()?.value(forKey: fieldName)
    }
    
    open func label(forField fieldName: String) -> String {
        return fieldName.underscoreCased().titleize()
    }
    
    fileprivate func inputTypeFor(_ fieldName: String, collection: [Int: String]? = nil, customAction: (()->())? = nil) -> InputType {
        let type: InputType
        let fieldType = propertyType(fieldName)
        if collection != nil || customAction != nil {
            type = .collection
        } else {
            switch fieldType {
            case .date:
                type = .dateInLine
            case .bool:
                type = .switch
            case .int:
                type = .int
            default:
                type = .string
            }
        }
        return type
    }
    
    open func reload() {
        UIView.setAnimationsEnabled(false)
        form.removeAll()
        initializeForm()
        UIView.setAnimationsEnabled(true)
    }
}
