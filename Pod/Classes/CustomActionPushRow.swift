import Eureka

public final class CustomActionPushRow<T: Equatable>: SelectorRow<PushSelectorCell<T>, SelectorViewController<T>>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = nil
    }
}
