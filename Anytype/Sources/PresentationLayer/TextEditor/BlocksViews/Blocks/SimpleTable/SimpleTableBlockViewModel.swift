import BlocksModels
import Combine
import UIKit
import AnytypeCore

struct SimpleTableBlockViewModel: BlockViewModelProtocol {

    let info: BlockInformation

    var hashable: AnyHashable {
        info.id as AnyHashable
    }

    private let dependenciesBuilder: SimpleTableDependenciesBuilder

    init(
        info: BlockInformation,
        simpleTableDependenciesBuilder: SimpleTableDependenciesBuilder
    ) {
        self.info = info
        self.dependenciesBuilder = simpleTableDependenciesBuilder
    }

    func makeContentConfiguration(maxWidth: CGFloat) -> UIContentConfiguration {
        SimpleTableBlockContentConfiguration(
            info: info,
            dependenciesBuilder: dependenciesBuilder
        ).cellBlockConfiguration(indentationSettings: nil, dragConfiguration: nil)
    }

    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}


func measureTime(for problem: String, closure: () -> ()) {
    let start = CFAbsoluteTimeGetCurrent()
    closure()
    let diff = CFAbsoluteTimeGetCurrent() - start
    print("Took \(diff) seconds for \(problem)")
}
