//
//  StraightsPuzzle.swift
//  KreuzEck
//
//  Created by Markus Gnadl on 06.01.18.
//  Copyright © 2018 Markus Gnadl. All rights reserved.
//

import Foundation

import UIKit


//Specialzation for Str8s
class StraightsPuzzle : Puzzle {
    
    var numbers = [Character]()
    var intSolution = [Character]()
    var black   = [Bool]()
    
    
    //get new from
    //https://www.str8ts.com/feed/fetchStr8tsDAILYtxt.asp?d=0&accid=9302&asym=1
    
    override func load(parseString: String) {
    
        self.numCols = 9
        self.numRows = 9
        
        self.inputType = .numeric
        
        self.crossWordTitle = ""
        
        //format str8ts.com
        for (index, char) in parseString.enumerated() {
            switch (index) {
            case 1 ..< 82:
            //case (1 + 81*0) ..< (1 + 81*1):
                numbers.append( char )
            case 82 ..< 163:
            //case (1 + 81*1) ..< (1 + 81*2):
                intSolution.append( char )
            case 163 ..< 244:
                //case (1 + 81*2) ..< (1 + 81*3):
                black.append( char == "1")
            case 244:
            //case (1 + 81*3)... :
                crossWordTitle.append( char )
            default: ()
            }
        }
    }
    
    override func decoratePuzzleGrid(_ grid: [[CellView]], image: UIImageView) {
        
        //Populate Cells
        for (rowIdx, row) in grid.enumerated() {
            for (colIdx, cell) in row.enumerated() {
                let idx = colIdx + rowIdx*9
                let number = numbers[idx]
                let isBlack = black[idx]
                cell.content = (number == "0") ? "" : number.description
                cell.editable = (number == "0") && !isBlack
                cell.inverted = isBlack
            }
        }
        
    }
}
