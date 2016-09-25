import Foundation

class SimpleArrayStoredModel: NSObject {
    static var collection = [SimpleArrayStoredModel]()
    let uuid = NSUUID().UUIDString
    
    class func all() -> [SimpleArrayStoredModel] {
        return collection
    }
    
    func instanceClass() -> SimpleArrayStoredModel.Type {
        return object_getClass(self) as! SimpleArrayStoredModel.Type
    }
    
    /// A callback is used here to help demonstrate the usage with an asynronous save.
    func save(callback: ()->()) {
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
