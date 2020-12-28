//
//  ZeitCellView.swift
//  KreuzEck
//
//  Created by Markus Gnadl on 06.01.18.
//  Copyright © 2018 Markus Gnadl. All rights reserved.
//

import UIKit

class ZeitCellView : CellView {

    @IBOutlet var numLabel: UILabel!
    
    public var num: Int? = nil
    {
        didSet
        {
            if let val = num {
                numLabel.text = "\(val)"
            }
            else {
                numLabel.text = ""
            }
        }
    }
    
    var wordIndexHorizontal: Int? = nil
    var wordIndexVertical: Int? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.num = nil

        self.wordIndexHorizontal = nil
        self.wordIndexVertical   = nil
    }
}

extension ZeitCellView { //Utility functions
    
    func isActive() -> Bool {
        return wordIndexHorizontal != nil || wordIndexVertical != nil
    }
    
    func isStartForDirection() -> Direction? {
        if (startOfHor && wordIndexHorizontal != nil) {
            return .horizontal
        }
        else if (startOfVer && wordIndexVertical != nil) {
            return .vertical
        }
        return nil
    }

    func wordIndexForDirection(_ direction: Direction) -> Int? {
        return  (direction == .vertical) ? wordIndexVertical : wordIndexHorizontal
    }
}
