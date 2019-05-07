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
    var buildingArtworks: String!
    var artworks = [ArtworkCore]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        self.tblView.dataSource = self
        self.tblView.delegate = self

        let nib = UINib(nibName: "countryCell", bundle: nil)
        tblView.register(nib, forCellReuseIdentifier: "cells")
        // Do any additional setup after loading the view.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artworks.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tblView.dequeueReusableCell(withIdentifier: "cells", for: indexPath)
        
        cell.textLabel?.text = artworks[indexPath.row].title
        
        return cell
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
