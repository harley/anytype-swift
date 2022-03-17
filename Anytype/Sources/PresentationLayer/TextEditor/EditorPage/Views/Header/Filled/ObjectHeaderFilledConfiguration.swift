import UIKit

struct ObjectHeaderFilledConfiguration: UIContentConfiguration, Hashable {
        
    let state: ObjectHeaderFilledState
    let width: CGFloat
    var topAdjustedContentInset: CGFloat = 0
    
    func makeContentView() -> UIView & UIContentView {
        ObjectHeaderFilledContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}
