//
//  CellView.swift
//  KreuzEck
//
//  Created by Markus Gnadl on 30.12.17.
//  Copyright © 2017 Markus Gnadl. All rights reserved.
//

import Foundation
import UIKit


class CellView: UIView {
    
    //General
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var bgView: UIView!
    
    //Decoration
    @IBOutlet var bigBorderLeftView: UIView!
    @IBOutlet var bigBorderRightView: UIView!
    @IBOutlet var bigBorderTopView: UIView!
    @IBOutlet var bigBorderBottomView: UIView!
    
    var editable = false {
        didSet {
            tapGestureRecognizer.isEnabled = editable
        }
    }
    
    var startOfHor = false {
        didSet {
            bigBorderLeftView.isHidden = !startOfHor
        }
    }
    var startOfVer = false {
        didSet {
            bigBorderTopView.isHidden = !startOfVer
        }
    }
    var endOfHor = false {
        didSet {
            bigBorderRightView.isHidden = !endOfHor
        }
    }
    var endOfVer = false {
        didSet {
            bigBorderBottomView.isHidden = !endOfVer
        }
    }
    
    var content = "" {
        didSet {
            textLabel.text = content
        }
    }
    
    var solution: String? = nil
    
    func prepareForReuse() {

        self.startOfHor = false
        self.startOfVer = false
        self.endOfHor = false
        self.endOfVer = false
        self.content = ""
    }
    
    weak var delegate: CellViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        tapGestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(clicked))
        tapGestureRecognizer.numberOfTapsRequired = 2
        self.addGestureRecognizer(tapGestureRecognizer)
        
        
        let eraseGesture = EraseGestureRecognizer(target: self, action: #selector(eraseContent))
        self.addGestureRecognizer(eraseGesture)
    }
    
    @objc func eraseContent() {
        content = ""
    }
    
    let highColor = UIColor.init(red: 14.0/255, green: 122.0/255, blue: 254.0/255, alpha: 1.0)
    let redColor  = UIColor.red
    
    public var erroneous = false {
        didSet {
            bgView.backgroundColor = erroneous ? redColor.withAlphaComponent(0.2): UIColor.systemBackground
        }
    }
    
    public var highlighted = false {
        didSet {
            if !self.selected { //selected has precedence
                bgView.backgroundColor = highlighted ? highColor.withAlphaComponent(0.2)  : UIColor.systemBackground
            }
        }
    }
    
    public var selected = false
        {
        didSet {
            bgView.backgroundColor = selected ? highColor.withAlphaComponent(0.5) : UIColor.systemBackground
        }
    }
    
    public var inverted = false {
        didSet {
            bgView.backgroundColor = inverted ? UIColor.black : UIColor.white
            textLabel.textColor = inverted ? UIColor.white : UIColor.black
        }
    }
    
    @objc func clicked(){
        delegate?.cellViewTouched(cellView: self)
    }
    
}

protocol CellViewDelegate: class
{
    func cellViewTouched(cellView: CellView)
}


