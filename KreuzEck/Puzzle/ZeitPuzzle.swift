//
//  ZeitPuzzle.swift
//  KreuzEck
//
//  Created by Markus Gnadl on 06.01.18.
//  Copyright © 2018 Markus Gnadl. All rights reserved.
//

import Foundation

import UIKit

class ZWord : Word {
    var picture: ZeitPicture?
    
    init(num: Int, length: Int, column: Int, row: Int, hint: String, answer: String, dir: Direction, picture: ZeitPicture?){
        super.init(num: num, length: length, column: column, row: row, hint: hint, answer: answer, dir: dir)
        self.picture = picture
    }
}

struct ZeitPoint : Codable {
    var x: Int
    var y: Int
}

struct ZeitSize : Codable {
    var width: Int
    var height: Int
}

struct ZeitPicture : Codable {
    var url: String
    var position: ZeitPoint
    var size: ZeitSize
}

struct ZeitWord : Codable {
    var question: String
    var answer: String?
    var length: Int
    var isSolution: Bool?
    var picture: ZeitPicture?
}

struct ZeitQuestion : Codable {
    var key: Int
    var vertical: ZeitWord?
    var horizontal: ZeitWord?
    var position: ZeitPoint
}

struct ZeitMeta : Codable {
    var label: String
    var key: String
    var isGewinnspiel: Bool?
}

struct ZeitJsonPuzzle : Codable {
    var questions: [ZeitQuestion]?
    var meta: ZeitMeta
}

struct ZeitList : Codable {
    var id: Int
    var spielname: String
}

//Parsing Zeit Puzzle
/*
extension Word: XMLIndexerDeserializable {
    
    static func deserialize(_ node: XMLIndexer) throws -> Word {
        return try Word(
            num:    node.value(ofAttribute: "no"),
            length: {
                do {
                    let str: String = try node.value(ofAttribute: "answer")
                    return str.count
                }
                catch {
                    return 0
                }
        }(),
            column: node.value(ofAttribute: "xC") - 1, //1-based index to 0-based indexing
            row:    node.value(ofAttribute: "yC") - 1,
            hint:   node.value(),
            answer: node.value(ofAttribute: "answer"),
            dir:    node.value(ofAttribute: "dir")
        )
    }


extension Direction : XMLAttributeDeserializable {
    public static func deserialize(_ attribute: XMLAttribute) -> Direction {
        return (attribute.text == "h") ? Direction.horizontal : Direction.vertical
    }
}
 */

// Specialization for Zeit Puzzle

class ZeitPuzzle : WordPuzzle {
    
    
    override func load(parseString: String) {

        let decoder = JSONDecoder()
        
        do {
            let json = try decoder.decode(ZeitJsonPuzzle.self, from: parseString.data(using: .utf8)!)
            
            for question in json.questions! {
                if let q = question.horizontal {
                    let qanswer = q.answer ?? String(repeating: " ", count: q.length)
                    let w = ZWord(num: question.key, length: q.length, column: question.position.x, row: question.position.y, hint: q.question, answer: qanswer, dir: .horizontal, picture: q.picture)
                    wordsHorizontal.append(w)
                }
                else if let q = question.vertical{
                    let qanswer = q.answer ?? String(repeating: " ", count: q.length)
                    let w = ZWord(num: question.key, length: q.length, column: question.position.x, row: question.position.y, hint: q.question, answer: qanswer, dir: .vertical, picture: q.picture)
                    wordsVertical.append(w)
                }
                
            }
            self.crossWordTitle = json.meta.label
            self.crossWordNum   = Int(json.meta.key)!
            self.numRows        = 40
            self.numCols        = 40
            
            
            
            
        } catch {
            print("Error: \(error)")
        }

        
        self.cellGenerator = {
            let cell: ZeitCellView = ZeitCellView.fromNib()
            return cell
        }
    }
    
    
    override func decoratePuzzleGrid(_ grid: [[CellView]], image: UIImageView) {
        super.decoratePuzzleGrid(grid, image: image)
        
        
        
        
        for (wordIdx, word) in self.wordsHorizontal.enumerated() {
            
            //Zeit specific
            if let cell = grid[word.row][word.column] as? ZeitCellView {
                cell.num = word.num
            }
            
            //only in horizonal words
            if let zword = word as? ZWord {
                if let pic = zword.picture {
                    do {
                        let url = URL(string: pic.url)
                        let data = try Data(contentsOf: url!)
                        
                        let img = UIImage(data: data)
                        image.image = img
                        let grid_size = 48.0 //TODO: move upward
                        let frame = CGRect(x: Double(pic.position.x) * grid_size + 1, y: Double(pic.position.y) * grid_size + 1, width: Double(pic.size.width) * grid_size - 1, height: Double(pic.size.height) * grid_size - 1)
                        image.frame = frame;
                        

                    }
                    catch{
                        
                    }
                }
            }
            
            
            for (i, char) in word.answer.enumerated() {
                let c = grid[word.row][word.column + i]
                c.startOfHor = (i == 0)
                c.endOfHor = (i == word.length-1)
                c.editable = true

                c.solution = String(char)
                
                if let c = c as? ZeitCellView {
                    c.wordIndexHorizontal = wordIdx
                }
  
            }
        }
        
        for (wordIdx,word) in self.wordsVertical.enumerated() {
            
            //Zeit specific
            if let cell = grid[word.row][word.column] as? ZeitCellView {
                cell.num = word.num
            }
            
            //Generalized CrossWord Stuff
            for (i, char) in word.answer.enumerated() {
                let c = grid[word.row+i][word.column]
                c.startOfVer = (i == 0)
                c.endOfVer = (i == word.length-1)
                c.editable = true
                
                c.solution = String(char)
                
                if let c = c as? ZeitCellView {
                    c.wordIndexVertical = wordIdx
                }
            }
        }
        
        // specific for Zeit
        //search if we need to draw a big border by clearing end of words we do not need to mark
        for (row_idx, row) in grid.enumerated() {
            for (col_idx, c) in row.enumerated() {
                if let c = c as? ZeitCellView {
                    if c.isActive() {
                        //when previous cell is endOfHor or endOfVer, then we need to be the start to see the border
                        if(col_idx >= 1) {
                            c.startOfHor =  c.startOfHor || grid[row_idx][col_idx-1].endOfHor
                        }
                        if(row_idx >= 1) {
                            c.startOfVer = c.startOfVer || grid[row_idx-1][col_idx].endOfVer
                        }
                    }
                }
                
                if(c.endOfHor) {
                    //look ahead one col and see if it is active
                    if (col_idx + 1) >= self.numCols {
                        c.endOfHor = false
                    }
                    else {
                        c.endOfHor = grid[row_idx][col_idx+1].editable
                    }
                }
                if(c.endOfVer) {
                    //look ahead one col and see if it is active
                    if (row_idx + 1) >= self.numRows {
                        c.endOfVer = false
                    }
                    else {
                        c.endOfVer = grid[row_idx+1][col_idx].editable
                    }
                }
            }
        }
        
        for row in grid {
            for v in row {
                let active = v.editable
                v.isHidden = !active
            }
        }
        
    }
    
    class func generateNewPuzzle() {
        
        //you will have to find that URL for yourself
        let urlString = ""
        if let url = URL(string: urlString) {
            
            let request = URLRequest(url: url,
                                     cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy,
                                     timeoutInterval: TimeInterval(5)
            )
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    // check for fundamental networking error
                    print("error=\(error!)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response!)")
                }
                
                let decoder = JSONDecoder()
                
                do{
                    let puzzles =  try decoder.decode([ZeitList].self, from: data)
                    
                    //check if puzzle already here?
                    for p in puzzles {
                        print(p)
                    }
                }
                catch {
                    
                }
                
                //if not get and save it into folder
            }
            
            
            task.resume()
            
        }
    }

    
}
