import UIKit

class EventTableViewController: UITableViewController {
    var events = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        
        cell.textLabel?.text = events[indexPath.row].title

        return cell
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? EventViewController {
            destination.event = events[tableView.indexPathForSelectedRow!.row]
        }
    }

}
