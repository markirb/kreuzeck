//
//  CrosswordView.swift
//  KreuzEck
//
//  Created by Markus Gnadl on 05.01.18.
//  Copyright © 2018 Markus Gnadl. All rights reserved.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
   
    @discardableResult func bold(_ text: String, _ size: CGFloat) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: size)]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let normal = NSAttributedString(string: text)
        append(normal)
        return self
    }
}

extension UIView {
    //works also with @IBDesignable
    class func fromNib<T: UIView>() -> T {
        return UINib(nibName: String(describing: T.self), bundle: Bundle(for: T.self)).instantiate( withOwner: nil, options: nil).first as! T
    }
}

//Custom Type


//View which shows arbitrary number of Cells in a Matrix and layouts them according to settings
//@IBDesignable
class CrosswordView : UIView {
    
    //Input operations: Input Single, Input Multiple, Delete Single, Delete Multiple
    
    var grid: [[CellView]] = []
    
    var currentCellView: CellView?
    var currentCellsHighlighted: [CellView] = []
    
    var currentDirection = Direction.vertical //State
    
    var image = UIImageView()
    
    var hintClosures =  [ (NSAttributedString) -> () ]() //delegate for hints
    
    var strikeThroughGestureRecognizer = StrikeThroughGestureRecognizer()
    
    var puzzle: Puzzle? {
        didSet {
            guard let puzzle = puzzle else {
                return
            }
            puzzle.load()
            //Redraw everything
            self.drawCrossword()
            self.drawSolution()
            
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        guard let puzzle = puzzle else {
            return .zero
        }
        return CGSize(width: CGFloat(puzzle.numCols) * 48.0, height: CGFloat(puzzle.numRows) * 48.0)
    }
    
    func drawSolution() {
        guard let puzzle = puzzle else {
            return
        }
        
        let solution = puzzle.loadSolution()
        for (rowIdx, row) in solution.enumerated() {
            for (colIdx, char) in row.enumerated() {
                if let c = char {
                    if(grid[rowIdx][colIdx].editable) {
                        grid[rowIdx][colIdx].content = c;
                    }
                }
            }
        }
    }
    
    func save(sender: AnyObject){
        let solution = grid.map { $0.map{ $0.content} }
        
        guard let puzzle = puzzle else {
            return
        }
        puzzle.saveSolution(input: solution)
    }
    
    func clear(sender: AnyObject){
        grid.forEach { $0.forEach{ $0.content = ""} }
    }
    
    func drawCrossword() {
        
        guard let puzzle = puzzle else {
            return
        }
        
        let numRow = puzzle.numRows
        let numCol = puzzle.numCols
        
        //if theres already a grid then get rid of it... we could also place the cell into a reuse pool
        grid.forEach { $0.forEach{ $0.removeFromSuperview()} }
        
        
        grid = Array(repeating: Array(repeating: CellView(), count: numCol), count: numRow) //every element points to same cell instance...
        
        let grid_size = 48.0
        
        //Generate cells and layout
        for (row_idx, row) in grid.enumerated() {
            for (col_idx, _) in row.enumerated() {
                let v: CellView = puzzle.cellGenerator() as! CellView
                grid[row_idx][col_idx] = v //create new cell for each element
                
                let frame = CGRect(x: Double(col_idx) * grid_size, y: Double(row_idx) * grid_size, width: grid_size, height: grid_size)
                v.frame = frame;
                self.addSubview(v)
                v.delegate = self
            }
        }
    
        self.image.image = nil
        self.addSubview(self.image)
        
        grid.forEach { $0.forEach{ $0.prepareForReuse()} }
        
        puzzle.decoratePuzzleGrid(grid, image: image)
    }
    
    
    func inputCharAndAdvance(char: String) {
        guard let cellView = currentCellView else {
            return
        }
        
        cellView.content = char
        
        undoManager?.registerUndo(withTarget: cellView) {
            $0.content = ""
            self.cellViewTouched(cellView: $0)
        }
        undoManager?.setActionName("do thing")
        
        guard let puzzle = puzzle else {
            return
        }
        
        var nextCell: CellView? //Cell to advance to
        nextCell = puzzle.proposeNextSelectedCell(cellView, grid: grid, direction: currentDirection)
        self.setCellSelected(nextCell)
    }
    
    func clearSelection() {
        //deselect
        currentCellView?.selected = false
        currentCellView = nil
        strikeThroughGestureRecognizer.isEnabled = false
    }
    
    
    func highlightCells(_ cells: [CellView]) {
        for c in currentCellsHighlighted {
            c.highlighted = false
        }
        currentCellsHighlighted = []
        
        for c in cells {
            c.highlighted = true
            currentCellsHighlighted.append(c)
        }
    }
    
    func markWrongCells() {
        guard let puzzle = puzzle else {
            return
        }
        
        let wrongCells = puzzle.doCheck(grid: grid)
        wrongCells.forEach { $0.erroneous = true }
    }
    
    func setCellSelected(_ cell: CellView?) {
        
        currentCellView?.selected = false
        
        guard let cell = cell else {
            currentCellView = nil
            return
        }
        
        if currentCellView == cell { //same cell was tapped twice so try a mode switch
            currentDirection = currentDirection.other()
        }
        
        cell.selected = true;
        currentCellView = cell
        
        //strikeThroughGestureRecognizer.isEnabled = true
        //strikeThroughGestureRecognizer.startPoint = currentCellsHighlighted.first!.center
        //strikeThroughGestureRecognizer.endPoint   = currentCellsHighlighted.last!.center
        
        guard let puzzle = puzzle else {
            return
        }
        
        
        //TODO: favor start of word, when cell is not in current highlighted
        let (direction, toHighlight) = puzzle.proposeDirectionAndHighlightedCellsForSelectCellView(cell, grid: self.grid, direction: currentDirection)
        
        currentDirection = direction
        self.highlightCells(toHighlight)
        
        
        if let wordPuzzle = puzzle as? WordPuzzle {
            let questionText = wordPuzzle.hintForCellView(currentCellView!, direction: currentDirection)
            
            for clos in hintClosures {
                clos(questionText)
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        /* seems not to work reliably
        let view: CellView = .alternativeFromNib()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 40,height:40))
        addSubview(view)
        view.prepareForInterfaceBuilder()
        */
    }
}


extension CrosswordView: CellViewDelegate
{
    func cellViewTouched(cellView: CellView) {
        self.setCellSelected(cellView)
    }
}
