//
//  SudokuPuzzle.swift
//  KreuzEck
//
//  Created by Markus Gnadl on 06.01.18.
//  Copyright © 2018 Markus Gnadl. All rights reserved.
//

import Foundation
import UIKit

class SudokuPuzzle : Puzzle {
    
    var cells = [[Int]]()
    
    override func load(parseString string: String) {
        
        cells = [
            [1, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 2, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 3, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
        ]
        
        //is fixed for normal sudoku
        self.numCols = 9
        self.numRows = 9
        
        self.inputType = .numeric
    }
    
    override func decoratePuzzleGrid(_ grid: [[CellView]], image: UIImageView) {
        
        //Populate Cells
        for (rowIdx, row) in grid.enumerated() {
            for (colIdx, cell) in row.enumerated() {
                let number = cells[rowIdx][colIdx]
                cell.content = (number == 0) ? "" : number.description
                cell.editable = (number == 0)
            }
        }
        
        let sizeSub = 3
        
        //Decorate
        for (rowIdx, row) in grid.enumerated() {
            for (colIdx, cell) in row.enumerated() {
                if(rowIdx != 0 && (rowIdx % sizeSub) == 0) {
                    cell.startOfVer = true
                }
                if(colIdx != 0 && (colIdx % sizeSub) == 0) {
                    cell.startOfHor = true
                }
            }
        }
    }
    
    override func proposeNextSelectedCell(_ cellView: CellView, grid: [[CellView]], direction: Direction) -> CellView? {
        //stay in the same cell
        return cellView
    }
}
