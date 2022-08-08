public enum Feature: String, Codable {
    case rainbowViews = "Paint editor views 🌈"
    case showAlertOnAssert = "Show alerts on asserts\n(only in testflight dev)"
    case analytics = "Analytics Amplitude (only in development)"
    case middlewareLogs = "Show middleware logs in Xcode console"

    case clipboard = "Clipboard"
    case objectPreview = "Object preview"
    case createObjectInSet = "Create object in Set"
    case setSorts = "Set sorts"
    case setFilters = "Set filters"
    case floatingSetMenu = "Floating Set menu"
    // Author: m@anytype.io
    // Release: 0.17.0
    case relationDetails = "Relation details in read only mode"
    // Author: m@anytype.io
    // Release: 0.17.0
    case bookmarksFlow = "New bookmarks flow"
}

public final class FeatureFlags {
    public typealias Features = [Feature: Bool]
    
    public static var features: Features {
        FeatureFlagsStorage.featureFlags.merging(defaultValues, uniquingKeysWith: { (first, _) in first })
    }
    
    private static var isRelease: Bool {
        #if RELEASE
        true
        #else
        false
        #endif
    }
    
    private static let defaultValues: Features = [
        .rainbowViews: false,
        .showAlertOnAssert : true,
        .analytics : false,
        .middlewareLogs: false,
        .clipboard: true,
        .objectPreview: false,
        .createObjectInSet: true,
        .setSorts: true,
        .setFilters: false,
        .floatingSetMenu: false,
        .relationDetails: true,
        .bookmarksFlow: false
    ]
    
    public static func update(key: Feature, value: Bool) {
        var updatedFeatures = FeatureFlagsStorage.featureFlags
        updatedFeatures.updateValue(value, forKey: key)
        FeatureFlagsStorage.featureFlags = updatedFeatures
    }
}

public extension FeatureFlags {

    static var showAlertOnAssert: Bool {
        features[.showAlertOnAssert, default: true]
    }

    static var analytics: Bool {
        features[.analytics, default: false]
    }
    
    static var rainbowViews: Bool {
        features[.rainbowViews, default: false]
    }
    
    static var middlewareLogs: Bool {
        features[.middlewareLogs, default: false]
    }

    static var clipboard: Bool {
        features[.clipboard, default: true]
    }

    static var objectPreview: Bool {
        features[.objectPreview, default: false]
    }

    static var isCreateObjectInSetAvailable: Bool {
        features[.createObjectInSet, default: true]
    }
    
    static var isSetSortsAvailable: Bool {
        features[.setSorts, default: true]
    }
    
    static var isSetFiltersAvailable: Bool {
        features[.setFilters, default: false]
    }
        
    static var relationDetails: Bool {
        features[.relationDetails, default: true]
    }
    
    static var bookmarksFlow: Bool {
        features[.bookmarksFlow, default: false]
    }
}
