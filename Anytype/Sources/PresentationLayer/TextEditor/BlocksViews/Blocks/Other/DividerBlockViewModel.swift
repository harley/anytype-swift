import Services
import UIKit

struct DividerBlockViewModel: BlockViewModelProtocol {
    var hashable: AnyHashable { [ info ] as [AnyHashable] }
    
    let info: BlockInformation
    
    private let dividerContent: BlockDivider

    init(content: BlockDivider, info: BlockInformation) {
        self.dividerContent = content
        self.info = info
    }
    
    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        DividerBlockContentConfiguration(content: dividerContent)
            .cellBlockConfiguration(
                dragConfiguration: .init(id: info.id),
                styleConfiguration: .init(backgroundColor: info.backgroundColor?.backgroundColor.color)
            )
    }
    
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
