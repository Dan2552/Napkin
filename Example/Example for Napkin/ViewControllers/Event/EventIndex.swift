import UIKit
import Placemat

class EventIndexViewController: UITableViewController {
    var events = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = BlockBarButtonItem(barButtonSystemItem: .Add) {
            let edit = EventEditViewController()
            Navigation(viewController: self).show(edit, modally: true)
        }
        loadEvents()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loadEvents()
        tableView.reloadData()
    }
    
    func loadEvents() {
        events = Event.all() as! [Event]
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        cell.textLabel?.text = event(indexPath).title
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let show = EventShowViewController()
        show.event = event(indexPath)
        Navigation(viewController: self).show(show)
    }
    
    private func event(indexPath: NSIndexPath) -> Event {
        return events[indexPath.row]
    }
}
