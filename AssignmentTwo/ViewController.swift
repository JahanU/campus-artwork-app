//
//  ViewController.swift
//  AssignmentTwo
//
//  Created by Jahan on 07/04/2019.
//  Copyright © 2019 Jahan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var reports: [String: [Artwork]]!
    var allArtworks = [Artwork]()
    
    var artworkLocationNotes = [String]()
    
    var searchArtworkSection = [String]()
    
    var artworkSection = [String]()
    
    var searchArtworkTitle = [String]()
    var artworkTitles = [String]()
    
    var artworkArtist = [String]()
    
    var searching = false
    
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        decodeJson()
        table.reloadData()
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var sec: String?
        
        if (searching && searchArtworkSection.count != 0) {
            for x in 0..<searchArtworkTitle.count {
                for y in 0..<allArtworks.count {
                    
                    if (searchArtworkSection[x] == allArtworks[y].locationNotes) {
                        print("found match sections: \(searchArtworkSection.count)")
                        sec = searchArtworkSection[section]
                        if (sec!.isEmpty) {
                            return "Searching"
                        }
                        else {
                            return sec
                        }
                    }
                }
            }
        }
        else {
            searchArtworkSection.removeAll()
            return artworkLocationNotes[section]
        }
        return "false"
    }
    
    // returns the range of years,  so from from 2001 - 2018 (Returns 18 sections)
    func numberOfSections(in tableView: UITableView) -> Int {
        return (searching == true) ? searchArtworkTitle.count : self.artworkLocationNotes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (searching == true) ? searchArtworkTitle.count : reports[artworkLocationNotes[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "jsonCells", for: indexPath)
        var xxx = 0
        
        if (searching) {
            print("seaching")
            for x in 0..<searchArtworkTitle.count {
                var artwork = allArtworks[0]
                if (searchArtworkTitle.count > 1) {// If this shortens as the word has been shortened, then we reinit the searchArtworkSection array
                    xxx = searchArtworkTitle.count
                    print("Count is set to \(xxx)")
                }
                
                for y in 0..<allArtworks.count {
                    artwork = allArtworks[y]
                    
                    if (searchArtworkTitle[x] == artwork.title!) { // Searching title matches a title from the array
                        let count = searchArtworkTitle.count
                        print("found \(count) titles")
                        print("found title --> \(searchArtworkTitle)")
                        print("section atm \(searchArtworkSection)")
                        
                        cell.textLabel?.text = artwork.title
                        cell.detailTextLabel?.text = artwork.artist
                        
                        if !(searchArtworkSection.contains(allArtworks[y].locationNotes!)) { // If we already have the section then dont append
                            searchArtworkSection.append(allArtworks[y].locationNotes!)
                        }
//                        if (searchArtworkSection.count != xxx) {
//                            print("!!!!!")
//                            searchArtworkSection.removeAll()
//                            if (searchArtworkTitle[x] == artwork.title!) { // Searching title matches a title from the array
//                                searchArtworkSection.append(allArtworks[y].locationNotes!)
//                            }
//                        }
                    }
                }
            }
        }
        else {
            searchArtworkSection.removeAll()
            
            let artwork = reports[artworkLocationNotes[indexPath.section]]![indexPath.row]
            cell.textLabel?.text = artwork.title
            cell.detailTextLabel?.text = artwork.artist
            
            let lat = Double(artwork.lat) // Get the location of each artwork
            let long = Double(artwork.long)
            
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!) // Pinpoint the coordinates
            annotation.coordinate = coordinate
            annotation.title = artwork.title // Add & set title
            self.map.addAnnotation(annotation)
        }
        return cell
    }
    
    // Setting the current location to the ashton building, & the zoom of the map
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationOfUser = locations[0]
        let lat = locationOfUser.coordinate.latitude
        let long = locationOfUser.coordinate.longitude
        let latDelta: CLLocationDegrees = 0.004
        let lonDelta: CLLocationDegrees = 0.004
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let region = MKCoordinateRegion(center: location, span: span)
        self.map.setRegion(region, animated: true)
    }
    
    
    func decodeJson() { // Importing the JSON and storing it into an array
        if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artworksOnCampus/data.php?class=campus_artworks&lastUpdate=2017-11-01") {
            let session = URLSession.shared
            
            session.dataTask(with: url) { (data, response, err) in
                
                guard let jsonData = data else { return }
                
                do {
                    let decoder = JSONDecoder()
                    let getArtworks = try decoder.decode(AllArtworks.self, from: jsonData)
                    self.allArtworks = getArtworks.campus_artworks
                    self.reports = Dictionary(grouping: self.allArtworks, by: { $0.locationNotes! })
                    self.artworkLocationNotes = self.reports.keys.sorted(by: < )
                    
                    for i in 0..<self.allArtworks.count {
                        self.artworkTitles.append(self.allArtworks[i].title!)
                        self.artworkSection.append(self.allArtworks[i].locationNotes!)
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.table.reloadData()
                    })
                }
                catch let jsonErr {
                    print("Error decoding JSON", jsonErr)
                }
                }
                .resume()
            
        }
    }
    
    // Passes the selected section and row to the second screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let secondClass = segue.destination as? DetailViewController {
            let arrayIndexRow = table.indexPathForSelectedRow?.row
            let arrayIndexSection = table.indexPathForSelectedRow?.section
            secondClass.desArtworkDetail = reports[artworkLocationNotes[arrayIndexSection!]]![arrayIndexRow!]
            table.deselectRow(at: table.indexPathForSelectedRow!, animated: true) // Little animation touches
        }
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchArtworkTitle = artworkTitles.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        
        // The user is writting the name of the artwork, with this I need to find the locationNote of that artwork and make that the section title
        
        searching = true
        table.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        table.reloadData()
    }
    //    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    //        if searchBar.text?.isEmpty ?? searching == true {
    //            searching = false
    //            searchArtworkTitle = [""]
    //            print(searchArtworkTitle.count)
    //            searchBar.text = ""
    //            table.reloadData()
    //        }
    //    }
}




// I have a 2D array, divided into sections
//        for i in 0..<allArtworks.count {
//            let longAndLat = Double(allArtworks[i].long)! + Double(allArtworks[i].lat)!
//            distance.append(longAndLat)
//
//        }
//        for i in 0..<allArtworks.count {
//            range.append(total - distance[i]) // Stores the range (the disance from current location to each artwork)
//        }


//
//
//
//    func distanceFromLoc() { // grouped by distance
//        let currentLat = Double((locationManager.location?.coordinate.latitude)!)
//        let currentLong = Double((locationManager.location?.coordinate.longitude)!)
//        let total = currentLat + currentLong
//    }
//


//    func sortByDistance() {
//
//        let currentLat = Double((locationManager.location?.coordinate.latitude)!)
//        let currentLong = Double((locationManager.location?.coordinate.longitude)!)
//        let total = currentLat + currentLong
//
//        allArtworks = allArtworks.sorted(by: {$0.lat + $0.long < $1.lat + $1.long})
//
//        for i in 0..<allReports.count {
//            let loc = Double(allArtworks[i].lat)! + Double(allArtworks[i].long)!
//            let distance = loc - total
//
//        }


//        var count = 0
//        allReportsDistance = [[Artwork]()]
//        allReportsDistance[0].append(allArtworks[0].lat + allArtworks[0].long)
//
//        for i in 1..<allArtworks.count {
//            if (allArtworks[i-1].locationNotes != allArtworks[i].locationNotes) {
//                count += 1
//                allReportsDistance.append([allArtworks[i].locationNotes!])
//            }
//            allReportsDistance[count].append(allArtworks[i].lat + allArtworks[i].long)
//        }
//print(allReportsDistance[2]) // Stores the section, and all the distance following it within that section
//    }
