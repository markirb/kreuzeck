//
//  PuzzlePickerController.swift
//  KreuzEck
//
//  Created by Markus Gnadl on 05.01.18.
//  Copyright © 2018 Markus Gnadl. All rights reserved.
//

import Foundation
import UIKit

class PuzzlePickerController : UITableViewController {
    
    var selectedProperty: String?
    
    var data = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data = [String](PuzzleManager.sharedInstance.puzzles[selectedProperty!]!.keys).sorted()
        
        let newPuzzleButton = UIBarButtonItem.init(barButtonSystemItem: .refresh, target: self, action: #selector(reload))
        self.navigationItem.rightBarButtonItems = [newPuzzleButton]
    }
    
    @IBAction func reload( _ sender: Any) {
        //check if any options for a new puzzle are available

        //generate puzzle
        ZeitPuzzle.generateNewPuzzle()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let vc = self.presentingViewController as? ViewController {
            vc.puzzle = PuzzleManager.sharedInstance.puzzles[selectedProperty!]![data[indexPath.row]]
        }
        dismiss(animated: true, completion: nil    )
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        
        cell.textLabel?.text = data[indexPath.row]
        
        return cell
    }
    
}
