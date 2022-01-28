import Foundation
import UIKit

//@see https://www.figma.com/file/3lljgCRXYLiUeefJSxN1aC/Components?node-id=123%3A981
enum ObjectIconImageUsecase: Equatable {
    case openedObject
    case openedObjectNavigationBar
    
    case editorSearch // slash menu + mention
    case editorSearchExpandedIcons
    
    case dashboardList
    case dashboardProfile
    case dashboardSearch
    case mention(ObjectIconImageMentionType)
    case editorAccessorySearch
    
    case setRow
}

extension ObjectIconImageUsecase {
    var backgroundColor: UIColor {
        switch self {
        case .openedObjectNavigationBar, .mention, .setRow:
            return .clear
        default:
            return .strokeTransperent
        }
    }
}
