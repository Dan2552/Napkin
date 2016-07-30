import Luncheon
import Eureka

public class NapkinViewController: FormViewController {
    private var currentSection: Section?
    private var collections = [String : [Int: String]]()
    public required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initializeForm() {
        sectionSeparator()
        setupFields()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if useDefaultModalButtons() && isModal {
            title = "Add \(subject()!.dynamicType.className().titleize())"
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(cancelWasTapped))
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(preSaveWasTapped))
        }
        initializeForm()
    }
    
    public func useDefaultModalButtons() -> Bool {
        return true
    }
    
    func preSaveWasTapped() {
        setValuesToSubject()
        saveWasTapped()
    }
    
    public func saveWasTapped() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func cancelWasTapped() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func prepareForDismiss(saveWasTapped: Bool) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func subject() -> Lunch? {
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

    public func input(fieldName: String, collection: [Int: String]? = nil, var type: InputType? = nil, var label: String = "") {
        let modelValue = subject()!.valueForKey(fieldName)

        // If the label wasn't given, we can infer from the actual model field name
        if label.isEmpty {
            label = fieldName.underscoreCase().titleize()
        }

        // If the type hasn't been passed in, we can infer the type from the model itself
        if type == nil {
            let fieldType = propertyType(fieldName)
            if collection != nil {
                type = .Collection
            } else {
                switch fieldType {
                case .NSDate:
                    type = .DateInLine
                case .BOOL:
                    type = .Switch
                case .Integer:
                    type = .Integer
                default:
                    type = .String
                }
            }
        }

        let row: BaseRow

        switch type! {
        case .Password:
            let passwordRow = PasswordRow()
            row = passwordRow

            passwordRow.placeholder = label
            if let value = modelValue as? String {
                passwordRow.value = value
            }
        case .Collection:
            let pushRow = PushRow<String>()
            row = pushRow

            if let collection = collection {
                collections[fieldName] = collection

                pushRow.options = collection.sort { $0.0 < $1.0 }.map { $1 }
                if let modelValue = modelValue as? Int {
                    pushRow.value = collection.filter { $0.0 == modelValue }.first?.1
                }
                pushRow.value = pushRow.value ?? collection.first?.1
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
        case .Integer:
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

        row.tag = fieldName

        currentSection?.append(row)
    }

    private func isStringAlike(type: InputType?) -> Bool {
        guard let type = type else { return false }

        return type == .String
            || type == .URL
            || type == .Email
            || type == .Password
            || type == .Text
    }

    public func sectionSeparator() {
        currentSection = Section()
        form +++ currentSection!
    }
    
    public func button(title: String, action: ()->()) {
        let button = ButtonRow(title)
        button.title = title
        button.onCellSelection { cell, row in action() }

        currentSection?.append(button)
    }

    public func setValuesToSubject() {
        for (fieldName, value) in form.values() {
            guard var v = value as? AnyObject? else { continue }

            if let collection = collections[fieldName] {
                v = collection.filter { $1 == (v as! String) }.first?.0
            }

            subject()?.assignAttribute(fieldName, withValue: v)
        }
    }
}