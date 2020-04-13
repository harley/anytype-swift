//
//  BlocksViews+Base.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI

extension BlocksViews.Base {
    class ViewModel: ObservableObject {
        typealias BlockModel = BlockModels.Block.RealBlock
        typealias BlockModelReal = BlockModels.Block.RealBlock // has type .block
        typealias BlockModelID = BlockModels.Block.RealBlock.Index
        
        private var block: BlockModel
        
        // MARK: Initialization
        init(_ block: BlockModel) {
            self.block = block
        }
        
        static func generateID() -> BlockModelID {
            BlockModels.Utilities.IndexGenerator.generateID()
        }
        
        // MARK: Subclass / Blocks
        func getID() -> BlockModelID { getBlock().indexPath }
        
        /// Discussion
        /// This function should return full index and convert it in two numbers.
        /// Hahaha.
        func getFullIndex() -> BlockModelID {
            let block = getBlock()
            return block.indexPath
        }
        
        // MARK: Block model processing
        func getBlock() -> BlockModel { block }
        func isRealBlock() -> Bool { block.kind == .block }
        func getRealBlock() -> BlockModelReal { block }
        func update(block: (inout BlockModelReal) -> ()) {
            if isRealBlock() {
                self.block = update(getRealBlock(), body: block)
            }
        }
        
        // MARK: Indentation
        func indentationLevel() -> UInt {
            self.getBlock().indentationLevel()
            //getID().section > 0 ? UInt(getID().section) : 0
        }
        
        // MARK: Subclass / Information
        var information: MiddlewareBlockInformationModel { block.information }
        
        // MARK: Subclass / Views
        func makeSwiftUIView() -> AnyView { .init(Text("")) }
        func makeUIView() -> UIView { .init() }
    }
}

// MARK: Updates ( could be proposed in further releases ).
extension BlocksViews.Base.ViewModel {
    /// Update structure in natural `.with` way.
    /// - Parameters:
    ///   - value: a struct that you want to update
    ///   - body: block with updates.
    /// - Returns: new updated structure.
    private func update<T>(_ value: T, body: (inout T) -> ()) -> T {
        var value = value
        body(&value)
        return value
    }
}

/// Requirement: `Identifiable` is necessary for view model.
/// We use these models in plain way in `SwiftUI`.
extension BlocksViews.Base.ViewModel: Identifiable {}

/// Requirement: `BlockViewBuilderProtocol` is necessary for view model.
/// We use these models in wrapped (Row contains viewModel) way in `UIKit`.
extension BlocksViews.Base.ViewModel: BlockViewBuilderProtocol {
    var blockId: BlockID { getRealBlock().information.id }
    
    var id: IndexID { getID() }
    
    func buildView() -> AnyView { makeSwiftUIView() }
    func buildUIView() -> UIView { makeUIView() }
}

// MARK: Holder
// This protocol may be deprecated.
// It is required for now to enable communication between updater and text user interactor and view model.
protocol BlocksViewsViewModelHolder {
    typealias ViewModel = BlocksViews.Base.ViewModel
    var ourViewModel: BlocksViews.Base.ViewModel { get }
}

// MARK: Legacy
extension BlocksViews.Base {
    /// Contains legacy entities.
    enum Utilities {}
}

