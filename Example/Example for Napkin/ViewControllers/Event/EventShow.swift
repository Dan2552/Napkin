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
        Navigation(viewController: self).show(edit, modally: true)
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
            Navigation(viewController: self).show(UIViewController())
        }
        detail("URL")
        detail("notes", type: .Text)
    }
    
    private func eventDescription() -> String {
        var description = formattedEventDateAndTime()
        if !event.location.isEmpty {
            description = "\(event.location)\n\n\(description)"
        }
        return description
    }
    
    private func formattedEventDateAndTime() -> String {
        return "\(formattedDate())\n\(formattedTimes())"
    }
    
    private func formattedDate() -> String {
        let date = valueFor("starts") as! NSDate
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE, d MMM yyyy"
        let formatted = formatter.stringFromDate(date)
        return "\(formatted)"
    }
    
    private func formattedTimes() -> String {
        let starts = valueFor("starts") as! NSDate
        let ends = valueFor("ends") as! NSDate
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let formattedStart = formatter.stringFromDate(starts)
        let formattedEnd = formatter.stringFromDate(ends)
        
        return "from \(formattedStart) to \(formattedEnd)"
    }
    
    private func customViewExample() -> UIView {
        let custom = UIView(frame: CGRect(x: 8, y: 8, width: 304, height: 150))
        custom.backgroundColor = UIColor.redColor()
        return custom
    }
    
    private func formattedEditedBy() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "E d MMM, HH:mm"
        let formattedUpdatedAt = formatter.stringFromDate(event.updatedAt)
        return "\(event.author)\n\(formattedUpdatedAt)"
    }
}