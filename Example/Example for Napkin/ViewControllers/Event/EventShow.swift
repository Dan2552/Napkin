import UIKit
import Napkin
import Luncheon
import Placemat

class EventShowViewController: ShowViewController {
    var event = Event()

    override func subject() -> Lunch! {
        return event
    }
    
    override func editWasTapped() {
        let edit = EventEditViewController()
        edit.event = event
        edit.new = false
        Navigation(viewController: self).show(target: edit, modally: true)
    }
    
    override func setupFields() {
        detail(label: event.title, detail: eventDescription())
        detail(customView: customViewExample())
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
        ]) {
            self.setValuesToSubject()
        }
        detail(label: "Edited by", detail: formattedEditedBy()) {
            Navigation(viewController: self).show(target: UIViewController())
        }
        detail("URL")
        detail("notes", type: .text)
    }
    
    fileprivate func eventDescription() -> String {
        var description = formattedEventDateAndTime()
        if !event.location.isEmpty {
            description = "\(event.location)\n\n\(description)"
        }
        return description
    }
    
    fileprivate func formattedEventDateAndTime() -> String {
        return "\(formattedDate())\n\(formattedTimes())"
    }
    
    fileprivate func formattedDate() -> String {
        let date = value(forField: "starts") as! Date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMM yyyy"
        let formatted = formatter.string(from: date)
        return "\(formatted)"
    }
    
    fileprivate func formattedTimes() -> String {
        let starts = value(forField: "starts") as! Date
        let ends = value(forField: "ends") as! Date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let formattedStart = formatter.string(from: starts)
        let formattedEnd = formatter.string(from: ends)
        
        return "from \(formattedStart) to \(formattedEnd)"
    }
    
    fileprivate func customViewExample() -> UIView {
        let custom = UIView(frame: CGRect(x: 8, y: 8, width: 304, height: 150))
        custom.backgroundColor = UIColor.red
        return custom
    }
    
    fileprivate func formattedEditedBy() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E d MMM, HH:mm"
        let formattedUpdatedAt = formatter.string(from: event.updatedAt as Date)
        return "\(event.author)\n\(formattedUpdatedAt)"
    }
}
