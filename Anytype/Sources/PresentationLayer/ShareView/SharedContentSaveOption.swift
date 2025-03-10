import Foundation
import Services

enum SharedContentSaveOption {
    enum SpaceDestination<T> {
        case space(space: SpaceView, destination: T)
    }
    
    enum URLDestinationOption {
        case asObject(named: String?)
        case target(ObjectDetails)
    }
    
    enum URLSavingOption {
        case bookmark(destination: URLDestinationOption)
        case text(target: ObjectDetails)
    }
    
    enum TextDestinationOption {
        case object(named: String?, linkedTo: ObjectDetails?)
        case textBlock(ObjectDetails)
    }
    
    case unavailable
    case url(url: URL, savingOption: SpaceDestination<URLSavingOption>)
    case text(string: NSAttributedString, destination: SpaceDestination<TextDestinationOption>)
}
