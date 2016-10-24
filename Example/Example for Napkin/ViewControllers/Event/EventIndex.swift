import UIKit
import Placemat

class EventIndexViewController: UITableViewController {
    var events = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = BlockBarButtonItem(barButtonSystemItem: .add) {
            let edit = EventEditViewController()
            Navigation(viewController: self).show(target: edit, modally: true)
        }
        loadEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadEvents()
        tableView.reloadData()
    }
    
    func loadEvents() {
        events = Event.all() as! [Event]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = event(indexPath).title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let show = EventShowViewController()
        show.event = event(indexPath)
        Navigation(viewController: self).show(target: show)
    }
    
    fileprivate func event(_ indexPath: IndexPath) -> Event {
        return events[(indexPath as NSIndexPath).row]
    }
}
