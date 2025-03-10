import AnytypeCore

public enum DataviewViewType: Hashable, CaseIterable {
    case table
    case gallery
    case list
    case kanban
    case calendar
    
    public var asMiddleware: DataviewTypeEnum {
        switch self {
        case .table:
            return .table
        case .list:
            return .list
        case .gallery:
            return .gallery
        case .kanban:
            return .kanban
        case .calendar:
            return .calendar
        }
    }
    
    public var hasGroups: Bool {
        switch self {
        case .kanban:
            return FeatureFlags.setKanbanView
        case .list, .gallery, .table, .calendar:
            return false
        }
    }
    
    public var stringValue: String {
        switch self {
        case .table: return "Grid"
        case .list: return "List"
        case .gallery: return "Gallery"
        case .kanban: return "Board"
        case .calendar: return "Calendar"
        }
    }
}

public extension DataviewTypeEnum {
    var asModel: DataviewViewType? {
        switch self {
        case .table: return .table
        case .list: return .list
        case .gallery: return .gallery
        case .kanban: return .kanban
        case .calendar: return .calendar
        case .UNRECOGNIZED: return nil
        }
    }
}
