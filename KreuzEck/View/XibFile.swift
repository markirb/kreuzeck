//
//  XibFile.swift
//  KreuzEck
//
//  Created by Markus Gnadl on 05.01.18.
//  Copyright © 2018 Markus Gnadl. All rights reserved.
//

//Could be used to Pull xibs into your view controller see
// https://medium.com/zenchef-tech-and-product/how-to-visualize-reusable-xibs-in-storyboards-using-ibdesignable-c0488c7f525d

import Foundation
import UIKit

@IBDesignable
class XibView : UIView {
    
    @IBInspectable var nibName:String?
    
    func loadViewFromNib(nibName: String) -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(
            withOwner: nil,
            options: nil).first as? UIView
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        guard let nibName = nibName else { return }
        guard let view = loadViewFromNib(nibName: nibName) else { return }
        view.frame = bounds
        view.autoresizingMask =
            [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        view.prepareForInterfaceBuilder()
    }
}

