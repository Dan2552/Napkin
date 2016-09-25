//
//  CustomActionPushRow.swift
//  Pods
//
//  Created by Dan on 02/09/2016.
//
//

import Eureka

public final class CustomActionPushRow<T: Equatable> : SelectorRow<T, PushSelectorCell<T>, SelectorViewController<T>>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = nil
    }
}