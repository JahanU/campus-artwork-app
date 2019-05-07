//
//  BuildingArtworks.swift
//  AssignmentTwo
//
//  Created by Jahan on 06/05/2019.
//  Copyright © 2019 Jahan. All rights reserved.
//

import UIKit

class BuildingArtworksController: UITableViewController {
    
    @IBOutlet weak var tblView: UITableView!
    var buildingArtworks: String!
    var artworks = [ArtworkCore]()
    
    
    override func viewDidLoad() {
        print("Building!")
        super.viewDidLoad()
        navigationItem.title = buildingArtworks
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  10
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cells", for: indexPath)
        
        cell.textLabel?.text = artworks[indexPath.row].title
        cell.detailTextLabel?.text = artworks[indexPath.row].artist
        
        return cell
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        if let secondClass = segue.destination as? DetailViewController {
//            let arrayIndexRow = tblView.indexPathForSelectedRow?.row
//            let selectedCell = artworks[arrayIndexRow!]
//            
//            secondClass.desArtworkDetail = selectedCell
//        }
//        
//        tblView.deselectRow(at: tblView.indexPathForSelectedRow!, animated: true) // Little animation touches
//    }
    
}
