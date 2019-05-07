//
//  CountryViewController.swift
//  AssignmentTwo
//
//  Created by Jahan on 07/05/2019.
//  Copyright © 2019 Jahan. All rights reserved.
//

import UIKit

class CountryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tblView: UITableView!
    
    var artworks = [ArtworkCore]()
    var cache: NSCache<NSString, NSData>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = artworks[0].locationNotes
        self.tblView.dataSource = self
        self.tblView.delegate = self
        
        let nib = UINib(nibName: "countryCell", bundle: nil)
        tblView.register(nib, forCellReuseIdentifier: "cells")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artworks.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: "cells", for: indexPath)
        
        cell.textLabel?.text = artworks[indexPath.row].title
        cell.detailTextLabel?.text = artworks[indexPath.row].artist
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dvc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        dvc.desArtworkDetail =  artworks[(tblView.indexPathForSelectedRow?.row)!]
        dvc.cache = cache // Sending the cache image

        // MARK: - Navigation
        self.navigationController?.pushViewController(vc, animated: true)
        tblView.deselectRow(at: tblView.indexPathForSelectedRow!, animated: true) // Little animation touches
    }
    

    
}
