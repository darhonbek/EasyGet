//
//  CartFloatingPanelLayout.swift
//  EasyGet
//
//  Created by Darkhonbek Mamataliev on 22/4/19.
//  Copyright © 2019 Darkhonbek Mamataliev. All rights reserved.
//

import Foundation

import FloatingPanel

class CartFloatingPanelLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .tip
    }

    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 16.0 // A top inset from safe area
        case .half: return 216.0 // A bottom inset from the safe area
        case .tip: return 44.0 // A bottom inset from the safe area
        }
    }
}
