import BlocksModels

struct BlockBuilder {
    static func createInformation(info: BlockInformation) -> BlockInformation? {
        switch info.content {
        case .text:
            return createContentType(info: info).flatMap { content in
                BlockInformation.createNew(content: content)
            }
        default: return nil
        }
    }
    
    static func createNewLink(targetBlockId: BlockId) -> BlockInformation {
        BlockInformation.createNew(
            content: .link(
                BlockLink(targetBlockID: targetBlockId, style: .page, fields: [:])
            )
        )
    }

    static func createNewBlock(type: BlockContentType) -> BlockInformation? {
        createContentType(blockType: type).flatMap { content in
            var block = BlockInformation.createNew(content: content)
            
            if case .file(let blockFile) = content, case .image = blockFile.contentType {
                block.alignment = .center
            }

            return block
        }
    }
    
    static func createDefaultInformation() -> BlockInformation {
        return BlockInformation.createNew(content: .text(.empty()))
    }

    static func createDefaultInformation(block: BlockModelProtocol) -> BlockInformation? {
        switch block.information.content {
        case let .text(value):
            switch value.contentType {
            case .toggle: return BlockInformation.createNew(content: .text(.empty()))
            default: return nil
            }
        case .smartblock: return BlockInformation.createNew(content: .text(.empty()))
        default: return nil
        }
    }
    
    static func textStyle(info: BlockInformation) -> BlockText.Style? {
        switch info.content {
        case let .text(blockType):
            switch blockType.contentType {
            case .bulleted where blockType.text != "": return .bulleted
            case .checkbox where blockType.text != "": return .checkbox
            case .numbered where blockType.text != "": return .numbered
            case .toggle where UserSession.shared.isToggled(blockId: info.id) : return .text
            case .toggle where blockType.text != "": return .toggle
            default: return .text
            }
        default: return nil
        }
    }

    private static func createContentType(info: BlockInformation) -> BlockContent? {
        switch info.content {
        case let .text(blockType):
            switch blockType.contentType {
            case .bulleted where blockType.text != "": return .text(.init(contentType: .bulleted))
            case .checkbox where blockType.text != "": return .text(.init(contentType: .checkbox))
            case .numbered where blockType.text != "": return .text(.init(contentType: .numbered))
            case .toggle where UserSession.shared.isToggled(blockId: info.id) : return .text(.init(contentType: .text))
            case .toggle where blockType.text != "": return .text(.init(contentType: .toggle))
            default: return .text(.init(contentType: .text))
            }
        default: return nil
        }
    }

    private static func createContentType(blockType: BlockContentType) -> BlockContent? {
        switch blockType {
        case let .text(style):
            return .text(.init(contentType: style))
        case .bookmark:
            return .bookmark(.empty())
        case let .divider(style):
            return .divider(.init(style: style))
        case let .file(type):
            return .file(.empty(contentType: type))
        case let .link(style):
            return .link(.init(style: style))
        case .layout, .smartblock, .featuredRelations:
            return nil
        }
    }
}
