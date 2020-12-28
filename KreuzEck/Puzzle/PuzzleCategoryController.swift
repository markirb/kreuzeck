//
//  PuzzleCategoryController.swift
//  KreuzEck
//
//  Created by Markus Gnadl on 07.01.18.
//  Copyright © 2018 Markus Gnadl. All rights reserved.
//

import Foundation
import UIKit

class PuzzleCategoryController : UITableViewController {
    
    var data = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data = [String](PuzzleManager.sharedInstance.puzzles.keys).sorted()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = data[indexPath.row]
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCategory" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = segue.destination as! PuzzlePickerController
                controller.selectedProperty = data[indexPath.row]
            }
        }
    }
    
}
