//
//  Puzzle.swift
//  KreuzEck
//
//  Created by Markus Gnadl on 01.01.18.
//  Copyright © 2018 Markus Gnadl. All rights reserved.
//

import Foundation
import UIKit

enum Direction {
    case vertical
    case horizontal
}

extension Direction {
    func other() -> Direction {
        return (self == .vertical) ? .horizontal : .vertical
    }
}

enum InputType {
    case alphabet
    case numeric
}

class Puzzle {
    
    var identifier: String = ""
    var category: String = ""
    
    var numCols = 0
    var numRows = 0
    
    var inputType: InputType = .alphabet
    
    var crossWordTitle: String  = ""
    
    var contentPath: String? = nil
    
    var cellGenerator: ()->(AnyObject) = {
        let cell: CellView = CellView.fromNib()
        return cell
    }
    
    //TODO:checker
    
    var crossWordNum: Int = 0
    
    
    var solution = [[Character?]]()
    
    
    init(contentPath: String){
        self.contentPath = contentPath
    }

    
    
    func load(parseString: String) {
        
    }
    
    func load() {
        if let contents = try? String(contentsOfFile: contentPath!) {
            self.load(parseString: contents)
        }
    }
    
    var saveFilePath: String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return (url!.appendingPathComponent(crossWordNum.description, isDirectory: false).path)
    }
    
    func loadSolution() -> [[String?]] {
        let url = URL.init(fileURLWithPath: saveFilePath)
        if let data = try? Data.init(contentsOf: url) {
            if let ourData = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [[String?]] {
                return ourData
            }
        }
            
        
        return []
    }
    
    func saveSolution(input: [[String?]]) {
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: input, requiringSecureCoding: false) {
            let url = URL.init(fileURLWithPath: saveFilePath)
            do {
                try data.write(to: url)
            } catch {
                print("Something went wrong")
            }
        }
    }
    
    func decoratePuzzleGrid(_ grid: [[CellView]], image: UIImageView) {
        
    }
    
    func proposeDirectionAndHighlightedCellsForSelectCellView(_ cellView: CellView, grid: [[CellView]], direction: Direction) -> (Direction, [CellView]) {
        //does nothing
        
        return (direction, [])
    }
    
    func proposeNextSelectedCell(_ cellView: CellView, grid: [[CellView]], direction: Direction) -> CellView? {
        return nil
    }
    
    func doCheck( grid: [[CellView]] ) -> [CellView]{
        return []
    }
    
}
