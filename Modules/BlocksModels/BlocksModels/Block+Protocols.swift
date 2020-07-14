//
//  Block+Protocols.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation
import Combine

// MARK: - BlockModel
public protocol BlockModelProtocol: BlockHasInformationProtocol, BlockHasParentProtocol, BlockHasKindProtocol, BlockHasDidChangePublisherProtocol {}

// MARK: - UserSession
public protocol BlockUserSessionModelProtocol {
    typealias BlockId = TopLevel.AliasesMap.BlockId
    typealias Position = TopLevel.AliasesMap.FocusPosition
    func isToggled(by id: BlockId) -> Bool
    func isFirstResponder(by id: BlockId) -> Bool
    func firstResponder() -> BlockId?
    func focusAt() -> Position?
    func setToggled(by id: BlockId, value: Bool)
    func setFirstResponder(by id: BlockId)
    func setFocusAt(position: Position)
    
    func unsetFirstResponder()
    func unsetFocusAt()
    
    func didChangePublisher() -> AnyPublisher<Void, Never>
    func didChange()
}

/// We need to distinct Container and BlockContainer.
/// One of them contains UserSession.
/// Another contains BlockContainer and DetailsContainer.

// MARK: - Container
public protocol BlockHasUserSessionProtocol {
    typealias UserSession = BlockUserSessionModelProtocol
    var userSession: UserSession {get}
}

public protocol BlockHasRootIdProtocol {
    typealias BlockId = TopLevel.AliasesMap.BlockId
    var rootId: BlockId? {get set}
}
public protocol BlockContainerModelProtocol: class, BlockHasRootIdProtocol, BlockHasUserSessionProtocol {
    // MARK: - Operations / List
    func list() -> AnyIterator<BlockId>
    // MARK: - Operations / Choose
    func choose(by id: BlockId) -> BlockActiveRecordModelProtocol?
    // MARK: - Operations / Get
    func get(by id: BlockId) -> BlockModelProtocol?
    // MARK: - Operations / Remove
    func remove(_ id: BlockId)
    // MARK: - Operations / Add
    func add(_ block: BlockModelProtocol)
    // MARK: - Children / Append
    func append(childId: BlockId, parentId: BlockId)
    // MARK: - Children / Add Before
    func add(child: BlockId, beforeChild: BlockId)
    // MARK: - Children / Add
    func add(child: BlockId, afterChild: BlockId)
    // MARK: - Children / Replace
    func replace(childrenIds: [BlockId], parentId: BlockId, shouldSkipGuardAgainstMissingIds: Bool)
}

// MARK: - ChosenBlock
public protocol BlockActiveRecordModelProtocol: BlockActiveRecordHasContainerProtocol, BlockActiveRecordHasBlockModelProtocol, BlockActiveRecordHasIndentationLevelProtocol, BlockActiveRecordCanBeRootProtocol, BlockActiveRecordFindParentAndRootProtocol, BlockActiveRecordFindChildProtocol, BlockActiveRecordCanBeFirstResponserProtocol, BlockActiveRecordCanBeToggledProtocol, BlockActiveRecordCanHaveFocusAtProtocol, BlockHasDidChangePublisherProtocol {}
