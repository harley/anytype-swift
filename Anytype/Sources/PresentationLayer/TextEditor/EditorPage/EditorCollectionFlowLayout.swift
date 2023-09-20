import UIKit
import Combine
import Services

struct RowInformation: Equatable, Hashable {
    let allChildIndexPaths: [IndexPath] // It should contain all the Childs recursively
    let indentations: [BlockIndentationStyle] // It should represent how deep the child is
    let ownStyle: BlockIndentationStyle
}

enum EditorFlowLayoutPaddings {
    static let `default`: CGFloat = 20
    static let quote: CGFloat = 48
}

final class CustomInvalidation: UICollectionViewLayoutInvalidationContext {
    override var invalidatedItemIndexPaths: [IndexPath]? {
        indexPaths
    }
    
    private let indexPaths: [IndexPath]
    
    init(indexPaths: [IndexPath]) {
        self.indexPaths = indexPaths
    }
}

// `UICollectionViewLayout` that basically mimics behavior of `UITableView`
public final class EditorCollectionFlowLayout: UICollectionViewLayout {
    var document: BaseDocumentProtocol? {
        didSet {
            guard let document = document else { return }
            rowInformationSubscription = document
                .rowsInformation
                .sink { [weak self] rowInformation in
                    var invalidationIndexPaths = [IndexPath]()
                    
                    self?.nestedIndexPaths.forEach { key, value in
                        if rowInformation[key] != value {
                            invalidationIndexPaths.append(key)
                        }
                    }
                    
//                    self?.invalidateLayout(with: CustomInvalidation(indexPaths: invalidationIndexPaths))
                    self?.nestedIndexPaths = rowInformation
                }
        }
    }
    
    private var nestedIndexPaths = [IndexPath: RowInformation]()
    private var rowInformationSubscription: AnyCancellable?
 
    
    /// Object representing position and height of item
    private struct LayoutItem {
        /// Y coordinate of item
        var y: CGFloat
        /// Height of item
        var height: CGFloat
        var zIndex: Int
        
        /// Creates layout attributes for item at given indexPath
        func attributes(indexPath: IndexPath, collectionViewWidth: CGFloat) -> UICollectionViewLayoutAttributes {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = CGRect(
                x: 0,
                y: y,
                width: collectionViewWidth,
                height: height
            )
            // If you don't set zIndex you can ocassionally end up with incorrect initial layout size
            attributes.zIndex = zIndex
            return attributes
        }
    }
    
    /// Height that is used as estimate if cell item has no computed height
    public var estimatedItemHeight: CGFloat = 32
    
    public override var collectionViewContentSize: CGSize {
        CGSize(width: collectionViewWidth, height: collectionViewHeight)
    }
    
    /// For fast access we need to cache already computed attributes
    ///
    /// Storing whole `UICollectionViewLayoutAttributes` did not seem useful for me as in cases
    /// when item count changes (except for appending to the end), all attributes will need to be recreated
    /// as `UICollectionViewLayoutAttributes` contains indexPath (e.g. when first item is deleted,
    /// all indexPaths change...)
    private var cachedAttributes = [IndexPath: LayoutItem]()
    
    /// It is good to store size of collectionView
    private var collectionViewWidth: CGFloat = 0
    /// It is good to store size of collectionView
    private var collectionViewHeight: CGFloat = 0
    
    public override func prepare() {
        super.prepare()
        
        let numberOfSections = collectionView?.numberOfSections ?? 0
        // We need to store Y offset for next cell, at the beginning we will place it on top
        var offset: CGFloat = 0
        var zIndex = 1
        var parentIndentations = [BlockIndentationStyle]()
        
        // We will go through all sections
        for section in 0..<numberOfSections {
            let numberOfRows = collectionView?.numberOfItems(inSection: section) ?? 0
            
            // We will go through all rows in section
            for row in 0..<numberOfRows {
                let indexPath = IndexPath(item: row, section: section)
                
                // If we already have cached attributes for given indexPath, we will use it
                
                if let rowInformation = nestedIndexPaths[indexPath] {
                    if parentIndentations.count <= rowInformation.indentations.count {
                        
                    } else {
                        var intersection = parentIndentations
                        
                        for indentaion in rowInformation.indentations {
                            if let ix = intersection.firstIndex(of: indentaion) {
                                intersection.remove(at: ix)
                            }
                        }
                        
                        offset += intersection.totalExtraHeight
                    }
                    
                    parentIndentations = rowInformation.indentations
                }
                
                if var layoutItem = cachedAttributes[indexPath] {
                    layoutItem.y = offset
                    layoutItem.zIndex = zIndex
                    cachedAttributes[indexPath] = layoutItem
                    offset += layoutItem.height // do not forget to increase offset for next item
                } else { // If there is no cached attributes, we need to create new attributes with estimated height
                    cachedAttributes[indexPath] = LayoutItem(y: offset, height: estimatedItemHeight, zIndex: zIndex)
                    offset += estimatedItemHeight // do not forget to increase offset for next item
                }
                
              
                                
                zIndex += 1
            }
        }
        
        // we will store collectionView dimensions, we need to decrease it a bit
        // as otherwise on some devices layout's `layoutAttributesForElements(in:)`
        // will not be called as often as it should
        collectionViewWidth = collectionView.map { $0.bounds.width - .leastNonzeroMagnitude } ?? 0
        collectionViewHeight = offset
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let cached = cachedAttributes.reduce(into: [UICollectionViewLayoutAttributes]()) { acc, item in
            let itemAttrs = item.value.attributes(
                indexPath: item.key,
                collectionViewWidth: collectionViewWidth
            )
            
            let indentation = nestedIndexPaths[itemAttrs.indexPath]?.indentations.totalIndentation ?? 0
            
            let frame = CGRect(
                origin: .init(x: itemAttrs.frame.origin.x + indentation, y: itemAttrs.frame.origin.y),
                size: .init(
                    width: itemAttrs.frame.width - indentation,
                    height: itemAttrs.frame.height + additionalHeight(for: itemAttrs.indexPath)
                )
            )
            
            itemAttrs.frame = frame
            
            if rect.intersects(itemAttrs.frame) {
                acc.append(itemAttrs)
            }
        }
                
        return cached
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let itemAttrs = cachedAttributes[indexPath]?.attributes(indexPath: indexPath, collectionViewWidth: collectionViewWidth) else { return nil }
        
        let indentation = nestedIndexPaths[itemAttrs.indexPath]?.indentations.totalIndentation ?? 0
        
        let frame = CGRect(
            origin: .init(x: itemAttrs.frame.origin.x + indentation, y: itemAttrs.frame.origin.y),
            size: .init(
                width: itemAttrs.frame.width - indentation,
                height: itemAttrs.frame.height + additionalHeight(for: itemAttrs.indexPath)
            )
        )
        
        itemAttrs.frame = frame
        
        return itemAttrs
    }
    
    public override func shouldInvalidateLayout(
        forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
        withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes
    ) -> Bool {
        // if height changes, we need to invalidate part of the layout
        originalAttributes.frame.height != preferredAttributes.frame.height + additionalHeight(
            for: originalAttributes.indexPath)
    }
    
    public override func invalidationContext(
        forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
        withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(
            forPreferredLayoutAttributes: preferredAttributes,
            withOriginalAttributes: originalAttributes
        )
            
        // We will check how height has changed
        let heightDiff = originalAttributes.frame.height - preferredAttributes.frame.height
        
        // If item is above top edge, we need to update scroll offset so it is preserved
        let isAboveTopEdge = preferredAttributes.frame.minY < (collectionView?.bounds.minY ?? 0)
        context.contentOffsetAdjustment.y -= isAboveTopEdge ? -heightDiff : 0
        
        // When item height is changed we also need to update collectionView's contentSize
        context.contentSizeAdjustment.height -= heightDiff
//        context.contentSizeAdjustment.height -= additionalHeight(for: originalAttributes.indexPath)
        
        // Finally we need to update cached height, in more complex layout it would be better
        // to do it in a better place (e.g. `prepare()`,
        cachedAttributes[preferredAttributes.indexPath]?.height = preferredAttributes.frame.height
        return context
    }
    
    public override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        
        if context.invalidateEverything {
            cachedAttributes.removeAll()
        } else if let indexPaths = context.invalidatedItemIndexPaths {
            indexPaths.forEach { cachedAttributes.removeValue(forKey: $0) }
        }
    }
    
    private func additionalHeight(for indexPath: IndexPath) -> CGFloat {
        var additionalSize: CGFloat = 0
        if let rowInformation = nestedIndexPaths[indexPath] {
            for childIndexPath in rowInformation.allChildIndexPaths {
                let attributes = cachedAttributes[childIndexPath]?.attributes(
                    indexPath: childIndexPath,
                    collectionViewWidth: collectionViewWidth
                )
                
                additionalSize = additionalSize + (attributes?.size.height ?? 0)
                
                guard let childStyle = nestedIndexPaths[childIndexPath]?.ownStyle else { continue }
                
                additionalSize += childStyle.extraHeight
            }
            
            if rowInformation.allChildIndexPaths.count > 0 {
                additionalSize += rowInformation.ownStyle.extraHeight
            }
        }
        return additionalSize
    }
}


func indexPathMapping(for blockInfoArray: [BlockInformation]) -> [IndexPath: RowInformation] {
    var indexPathMap = [IndexPath: RowInformation]()
    
    func traverseBlockInfo(_ blockInfo: BlockInformation) -> [IndexPath] {
        let childIndexPaths = blockInfo.childrenIds.map { childId -> [IndexPath] in
            
            var indexPaths = [IndexPath]()
            if let childIndex = blockInfoArray.firstIndex { info in
                return info.id == childId
            } {
                indexPaths.append(.init(row: childIndex + 1, section: 1))
                indexPaths.append(contentsOf: traverseBlockInfo(blockInfoArray[childIndex]))
            }
            
            return indexPaths
        }.flatMap { $0 }
        
        return childIndexPaths
    }
    
    let dictionary = Dictionary(uniqueKeysWithValues: blockInfoArray.map { ($0.id, $0) })
    
    func findIdentation(
        currentIdentations: [BlockIndentationStyle],
        block: BlockInformation
    ) -> [BlockIndentationStyle] {
        guard let parentId = block.configurationData.parentId,
              let parent = dictionary[parentId]  else {
            return currentIdentations
        }
        var indentations = currentIdentations
        indentations.append(parent.content.indentationStyle)
        
        return findIdentation(
            currentIdentations: indentations,
            block: parent
        )
    }
    
    for rootBlockInfo in blockInfoArray.enumerated() {
        indexPathMap[IndexPath(row: rootBlockInfo.offset + 1, section: 1)] = .init(
            allChildIndexPaths: traverseBlockInfo(rootBlockInfo.element),
            indentations: findIdentation(currentIdentations: [], block: rootBlockInfo.element),
            ownStyle: rootBlockInfo.element.content.indentationStyle
        )
    }
    
    return indexPathMap
}

extension BlockContent {
    var indentationStyle: BlockIndentationStyle {
        switch self {
        case .text(let blockText):
            switch blockText.contentType {
            case .quote: return .quote
            case .callout: return .callout
            default: return .none
            }
        default: return .none
        }
    }
}

public enum BlockIndentationStyle: Hashable, Equatable {
    case `none`
    case quote
    case callout
    
    var padding: CGFloat {
        switch self {
        case .none:
            return EditorFlowLayoutPaddings.default
        case .quote:
            return EditorFlowLayoutPaddings.quote
        case .callout:
            return EditorFlowLayoutPaddings.quote
        }
    }
    
    var extraHeight: CGFloat {
        switch self {
        case .none:
            return 0
        case .quote, .callout:
            return 20
        }
    }
}

extension Array where Element == BlockIndentationStyle {
    var totalIndentation: CGFloat {
        reduce(into: CGFloat(0)) { partialResult, f in
            partialResult = partialResult + f.padding
        }
    }
    
    var totalExtraHeight: CGFloat {
        reduce(into: CGFloat(0)) { partialResult, f in
            partialResult = partialResult + f.extraHeight
        }
    }
}
