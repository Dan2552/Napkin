import Foundation

class SimpleArrayStoredModel: NSObject {
    static var collection = [SimpleArrayStoredModel]()
    let uuid = UUID().uuidString
    
    class func all() -> [SimpleArrayStoredModel] {
        return collection
    }
    
    func instanceClass() -> SimpleArrayStoredModel.Type {
        return object_getClass(self) as! SimpleArrayStoredModel.Type
    }
    
    /// A callback is used here to help demonstrate the usage with an asynronous save.
    func save(_ callback: ()->()) {
        for o in instanceClass().collection {
            if o.uuid == self.uuid {
                callback()
                return
            }
        }
        instanceClass().collection.append(self)
        callback()
    }
}
