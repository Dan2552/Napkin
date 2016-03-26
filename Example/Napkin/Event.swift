import Luncheon

class Event: SimpleArrayStoredModel, Lunch {
    dynamic var title = ""
    dynamic var location = ""
    dynamic var allDay = false
    dynamic var starts = NSDate(timeIntervalSinceNow: 60*60*24)
    dynamic var ends = NSDate(timeIntervalSinceNow: 60*60*25)
    dynamic var repeatInterval = 0
    dynamic var alert = 0
    dynamic var showAs = 0
    dynamic var URL = ""
    dynamic var notes = ""
    dynamic var secret = ""
    dynamic var number = 0

    required override init() {
        super.init()
    }
}
