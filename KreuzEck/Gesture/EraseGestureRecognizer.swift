//
//  EraseGestureRecognizer.swift
//
//  Created by Markus Gnadl
//

import Foundation

import UIKit
import UIKit.UIGestureRecognizerSubclass

enum MovementDirection {
    case left
    case right
    case unknown
}

class EraseGestureRecognizer : UIGestureRecognizer {
    
    var eraseStart: CGPoint = .zero
    var dirChanges = 0
    var lastMovementDirection: MovementDirection = .unknown
    
    var requiredChangesOfDir = 3
    var requiredAmountOfDistance = 25.0
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if let touch = touches.first {
            eraseStart = touch.location(in: view)
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        if let touch = touches.first {
            let newPoint = touch.location(in: view)
            let moveAmount = newPoint.x - eraseStart.x
            let dir = (moveAmount < 0) ? MovementDirection.left : MovementDirection.right

            if(Double(abs(moveAmount)) < requiredAmountOfDistance) {
                return
            }
            if(lastMovementDirection != dir ) {
                dirChanges = dirChanges + 1
                lastMovementDirection = dir
                eraseStart = newPoint
                if dirChanges > requiredChangesOfDir {
                    state = .recognized
                }
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        dirChanges = 0
        lastMovementDirection = .unknown
        eraseStart = .zero
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        dirChanges = 0
        lastMovementDirection = .unknown
        eraseStart = .zero
    }
}
