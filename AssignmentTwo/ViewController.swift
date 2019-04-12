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
    
    var allReports = [[Artwork]]() // first array stores years, second year stores the reports associated with them
    var allReportsDistance = [[Any]]() // first array stores years, second year stores the reports associated with them

    var allArtworks = [Artwork]()
    var distance = [Double]()
    var range = [Double]()

    var locationManager = CLLocationManager()
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
        return allReports[section].first?.locationNotes
    }
    // returns the range of years,  so from from 2001 - 2018 (Returns 18 sections)
    func numberOfSections(in tableView: UITableView) -> Int {
        return allReports.count // returns the count of the first array
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allReports[section].count // Gets the count of how many papers there are given the associated year
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "jsonCells", for: indexPath)
        
        let artwork = allReports[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = artwork.title
        cell.detailTextLabel?.text = artwork.artist
        
        let lat = Double(artwork.lat) // Get the location of each artwork
        let long = Double(artwork.long)
        
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!) // Pinpoint the coordinates
        annotation.coordinate = coordinate
        annotation.title = artwork.title // Add & set title
        self.map.addAnnotation(annotation)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    // Setting the current location to the ashton building, & the zoom of the map
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationOfUser = locations[0]
        let lat = locationOfUser.coordinate.latitude
        let long = locationOfUser.coordinate.longitude
        let latDelta: CLLocationDegrees = 0.005
        let lonDelta: CLLocationDegrees = 0.005
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
                    self.groupedByBuilding(artworkArray: getArtworks.campus_artworks)
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
            secondClass.desArtworkDetail = allReports[arrayIndexSection!][arrayIndexRow!]
//            tableView.deselectRow(at: tblReports.indexPathForSelectedRow!, animated: true) // Little animation touches
        }
    }
    
    
    // converts the sorted JSON array into a 2D array orgnasied by the year
    func groupedByBuilding(artworkArray: [Artwork]) {
        var count = 0 // Stores the element position of the year array within the 2D array
        allReports = [[Artwork]()] // Initalising 2D array to store type techReport
        allReports[0].append(artworkArray[0]) // Appends the first section of reports (2018 reports only)
        
        for i in 1..<artworkArray.count {
            if (artworkArray[i-1].locationNotes != artworkArray[i].locationNotes) {
                count += 1
                allReports.append([Artwork]())
            }
            allReports[count].append(artworkArray[i]) // Adds current report selected to the correct associated year
        }
        sortByDistance()
    }
    
    
    
    func distanceFromLoc() { // grouped by distance
        let currentLat = Double((locationManager.location?.coordinate.latitude)!)
        let currentLong = Double((locationManager.location?.coordinate.longitude)!)
        let total = currentLat + currentLong
    }
    
    func sortByDistance() {
        var count = 0 //
        allReportsDistance = [[Artwork]()]
        allReportsDistance[0].append(allArtworks[0].lat + allArtworks[0].long)
        
        for i in 1..<allArtworks.count {
            if (allArtworks[i-1].locationNotes != allArtworks[i].locationNotes) {
                count += 1
                allReportsDistance.append([allArtworks[i].locationNotes!])
            }
            allReportsDistance[count].append(allArtworks[i].lat + allArtworks[i].long)
        }
        print(allReportsDistance[2]) // Stores the section, and all the distance following it within that section
    }
    
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
