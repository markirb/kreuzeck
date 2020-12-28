//
//  PuzzleManager.swift
//  KreuzEck
//
//  Created by Markus Gnadl on 04.01.18.
//  Copyright © 2018 Markus Gnadl. All rights reserved.
//

import Foundation

import UIKit

enum PuzzleCategory {
    case zeit
    case sudoku
    case str8ts
}

class PuzzleManager : NSObject {
    
    var puzzles = [String: [String: Puzzle]]() //Dict of Category => Title => Puzzle

    
    
    static let sharedInstance: PuzzleManager = {
        let instance = PuzzleManager()
        
        
        //can either come with the app or be downloaded onto the device
        let docsPath = Bundle.main.resourcePath! + "/Puzzles"
        let fileManager = FileManager.default
        
        
        do {
            let catergoriesArray = try fileManager.contentsOfDirectory(atPath: docsPath)
            for categoryName in catergoriesArray {
                
                instance.puzzles[categoryName] = [String: Puzzle]()
                
                let categoryPath = docsPath + "/" + categoryName
                
                let puzzlesArray = try fileManager.contentsOfDirectory(atPath: categoryPath)
                for puzzleFilename in puzzlesArray {
                    let puzzlePath = categoryPath + "/" + puzzleFilename
                    var puzzle: Puzzle?
                    
                    switch(categoryName) {
                    case "Zeit":
                        puzzle = ZeitPuzzle(contentPath: puzzlePath)
                    case "Sudoku":
                        puzzle = SudokuPuzzle(contentPath: puzzlePath)
                    case "Str8ts":
                        puzzle = StraightsPuzzle(contentPath: puzzlePath)
                    default:
                        puzzle = nil
                    }
                    
                    if let puzzle = puzzle {
                        instance.puzzles[categoryName]![puzzleFilename] = puzzle
                        puzzle.category = categoryName
                        puzzle.identifier = puzzleFilename
                    }
                }
            }
        }
        catch {
            print("Error \(error)")
        }
        
        
        return instance
    }()
    
    
}

