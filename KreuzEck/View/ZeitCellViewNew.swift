//
//  ZeitCellView.swift
//  KreuzEck
//
//  Created by Markus Kirberg on 28.12.20.
//  Copyright © 2020 Markus Kirberg. All rights reserved.
//


extension View {
    func border( width: CGFloat = 1, edges: [Edge] = [], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

struct EdgeBorder: Shape {

    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }

            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }

            var w: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return self.width
                }
            }

            var h: CGFloat {
                switch edge {
                case .top, .bottom: return self.width
                case .leading, .trailing: return rect.height
                }
            }
            path.addPath(Path(CGRect(x: x, y: y, width: w, height: h)))
        }
        return path
    }
}

import SwiftUI

let cellsize  = CGFloat(48.0)


class CellNew : NSObject {
    
    var editable = false
    
    //for styling
    var startOfHor = false
    var startOfVer = false
    var endOfHor = false
    var endOfVer = false
    
    //cell
    var content: Character = " "
    var solution: Character?
}

class ZeitCellNew : CellNew {
    var num: Int? = nil
    var wordIndexHorizontal: Int? = nil //for back annotation
    var wordIndexVertical:   Int? = nil  //for back annotation
}

struct CrossWordViewNew: View {
    
    var grid = [[ZeitCellNew]]()
    
    var body: some View {
        VStack(
            alignment: .leading
        ) {
            ForEach(
                grid,
                id: \.self
            ) {
                let row = $0
                HStack(
                    alignment: .center, spacing: 0
                ) {
                    ForEach(
                        row,
                        id: \.self
                    ) {
                        let content = $0
                        ZeitCellViewNew(content: content).frame(width: cellsize-1, height: cellsize-1, alignment: .center)
                    }
                }
            }
        }
    }
}

struct ZeitCellViewNew: View {
    
    var content: ZeitCellNew
    
    var body: some View {
        let c = String(content.solution ?? " ")
        var num: String = ""
        if let c = content.num {
            num = String(c)
        }
        var edges = [Edge]()
        if content.startOfHor {
            edges.append(Edge.leading)
        }
        if content.endOfHor {
            edges.append(Edge.trailing)
        }
        if content.startOfVer {
            edges.append(Edge.top)
        }
        if content.endOfVer {
            edges.append(Edge.bottom)
        }
        return Text("\(c)").frame(width: cellsize, height: cellsize, alignment: .center).border(Color.black).overlay(Text(num).font(.callout)).border(width: 1.5, edges: edges, color: .black)
    }
}

struct ZeitCellViewNew_Previews: PreviewProvider {
    static var previews: some View {
        let letter = ZeitCellNew()
        letter.content = "a"
        letter.solution = "b"
        var grid = [[letter]]
        
       
        
        
        let puzzle = ZeitPuzzle(contentPath: "")
        puzzle.load(parseString: content)
        grid = puzzle.configureModel()
        
    
        
        return CrossWordViewNew(grid: grid)
.previewInterfaceOrientation(.portraitUpsideDown)
    }
}
