//
//  StrikeThroughGestureRecognizer.swift
//
//  Created by Markus Gnadl on 03.01.18.
//

import Foundation


import UIKit
import UIKit.UIGestureRecognizerSubclass


extension CGPoint {
    func distanceTo( p: CGPoint) -> CGFloat {
        return sqrt(pow(self.x-p.x,2) + pow(self.y-p.y,2))
    }
}

class StrikeThroughGestureRecognizer : UIGestureRecognizer {
    
    var startPoint: CGPoint = .zero
    var endPoint: CGPoint = .zero
    var radius: CGFloat = 50 //radius validation
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //test if touch is in start view
        if let touch = touches.first {
            let p = touch.location(in: self.view)
            if p.distanceTo(p: startPoint) >= radius {
                state = .failed
            }
            else {
                state = .possible
            }
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .failed
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        
        if let touch = touches.first {
            let p = touch.location(in: self.view)
            if p.distanceTo(p: endPoint) >= radius {
                state = .failed
            }
            else {
                state = .recognized
            }
        }
    }
}
