//
//  SimpleArrayStoredModel.swift
//  Napkin
//
//  Created by Daniel Green on 22/07/2015.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

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
    
    func save() {
        for o in instanceClass().collection {
            if o.uuid == self.uuid { return }
        }
        instanceClass().collection.append(self)
    }
}
