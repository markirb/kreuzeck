//
//  WordPuzzle.swift
//  KreuzEck
//
//  Created by Markus Gnadl on 06.01.18.
//  Copyright © 2018 Markus Gnadl. All rights reserved.
//

import Foundation

class Word {
    var num = 0
    var length = 0
    var column = 0
    var row = 0
    var hint = ""
    var answer = ""
    var dir = Direction.horizontal
    
    init(num: Int, length: Int, column: Int, row: Int, hint: String, answer: String, dir: Direction){
        self.num = num
        self.length = length
        self.column = column
        self.row = row
        self.hint = hint
        self.answer = answer
        self.dir = dir
    }
}

class WordPuzzle : Puzzle {
    
    var wordsHorizontal = [Word]()
    var wordsVertical   = [Word]()
    
    func wordsForDirection( _ direction: Direction ) -> [Word] {
        return (direction == .vertical) ? wordsVertical : wordsHorizontal
    }
    
    func wordCellsForWordIndex(_ wordIndex: Int, grid: [[CellView]], direction: Direction) -> [CellView] {
        var cells = [CellView]()
        
        if direction == .vertical {
            let word = self.wordsVertical[wordIndex]
            for i in 0..<word.length {
                cells.append(grid[word.row + i][word.column])
            }
        }
        else {
            let word = self.wordsHorizontal[wordIndex]
            for i in 0..<word.length {
                cells.append(grid[word.row][word.column + i])
            }
        }
        return cells
    }
    
    //proposes other words to highlight and a new direction? depending on stuff
    override func proposeDirectionAndHighlightedCellsForSelectCellView(_ cellView: CellView, grid: [[CellView]], direction: Direction) -> (Direction, [CellView]) {
        
        var direction = direction
        
        
        let cellView = cellView as! ZeitCellView

        
        //We switch mode when a cell is selected which is only available in antoher mode
        if cellView.wordIndexForDirection(direction) == nil {
            direction = direction.other()
        }
        
        let wordIndex = cellView.wordIndexForDirection(direction)!
        
        let highlightCells = wordCellsForWordIndex(wordIndex, grid: grid, direction: direction)
        
    
        
        
        return (direction, highlightCells)
    }
    
    
    func hintForCellView(_ cellView: CellView, direction: Direction) -> NSAttributedString {
        
        let string = NSMutableAttributedString()
        
        let directionText = (direction == .vertical ? "Senkrecht" : "Waagerecht")
        
        let cellView = cellView as! ZeitCellView
        
        let word = self.wordsForDirection(direction)[cellView.wordIndexForDirection(direction)!]
        
        string.bold("\(directionText): \(word.num) ", 17)
            .normal(word.hint)
        
        return string
    }
    
    override func proposeNextSelectedCell(_ cellView: CellView, grid: [[CellView]], direction: Direction) -> CellView? {
        
        let cellView = cellView as! ZeitCellView
        
        let wordCells = wordCellsForWordIndex(cellView.wordIndexForDirection(direction)!, grid: grid, direction: direction)
        
        for cell in wordCells {
            if cell.content == "" {
                return cell
            }
        }
        return nil
    }
    
    
    override func doCheck( grid: [[CellView]] ) -> [CellView]{
        var wrongCells = [CellView]()
        for row in grid {
            for cell in row {
                if let solution = cell.solution {
                    if cell.content != "" && cell.content != solution {
                        wrongCells.append(cell)
                    }
                }
            }
        }
        return wrongCells
    }
    
    
}
