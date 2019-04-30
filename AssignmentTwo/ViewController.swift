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
import CoreData

let cache = NSCache<NSString, NSURL>()

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var artworksCoreData = [ArtworkCore]()
    var reports: [String: [Artwork]]!
    var allArtworks = [Artwork]()
    var fileNames = [String]()
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
        
        let fetchRequest: NSFetchRequest<ArtworkCore> = ArtworkCore.fetchRequest()
        do {
            let artworksCoreData = try PersistenceService.context.fetch(fetchRequest)
            self.artworksCoreData = artworksCoreData
        }
        catch {
            print("error")
        }
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
                        sec = searchArtworkSection[x]
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
        var titleCount = 0
        
        if (searching) {
            for x in 0..<searchArtworkTitle.count {
                var artwork = allArtworks[0]
                
                if (searchArtworkTitle.count > 1) {// If this shortens as the word has been shortened, then we reinit the searchArtworkSection array
                    titleCount = searchArtworkTitle.count
                }
                
                for y in 0..<allArtworks.count {
                    artwork = allArtworks[y]
                    
                    if (searchArtworkTitle[x] == artwork.title!) { // Searching title matches a title from the array
                        
                        cell.textLabel?.text = artwork.title
                        cell.detailTextLabel?.text = artwork.artist
                        
                        if !(searchArtworkSection.contains(allArtworks[y].locationNotes!)) { // If we already have the section then dont append
                            searchArtworkSection.append(allArtworks[y].locationNotes!)
                        }
                        if (searchArtworkSection.count != titleCount) {
                            searchArtworkSection.removeAll()
                            if (searchArtworkTitle[x] == artwork.title!) { // Searching title matches a title from the array
                                searchArtworkSection.append(allArtworks[y].locationNotes!)
                            }
                        }
                    }
                }
            }
        }
        else {
            searchArtworkSection.removeAll()
            
            let artwork = reports[artworkLocationNotes[indexPath.section]]![indexPath.row]
            cell.textLabel?.text = artwork.title
            cell.detailTextLabel?.text = artwork.artist
            
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: Double(artwork.lat)!, longitude: Double(artwork.long)!) // Pinpoint the coordinates
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
                    
                    let artworkCore = ArtworkCore(context: PersistenceService.context)
                    
                    for i in 0..<self.allArtworks.count {
                        artworkCore.title = self.allArtworks[i].title
                        artworkCore.artist = self.allArtworks[i].artist
                        artworkCore.information = self.allArtworks[i].Information
                        artworkCore.yearOfWork = self.allArtworks[i].yearOfWork
                        artworkCore.locationNotes = self.allArtworks[i].locationNotes

                        PersistenceService.saveContext()
                        self.artworksCoreData.append(artworkCore)
                        
//                        self.artworkTitles.append(self.allArtworks[i].title!)
                        self.artworkSection.append(self.allArtworks[i].locationNotes!)
                        self.fileNames.append(self.allArtworks[i].fileName!)
                    }
                    
                    print(self.artworksCoreData.count)
                    
                    DispatchQueue.main.async(execute: {
                        self.table.reloadData()
                    })
                    //                    self.cacheAllImages()
                }
                catch let jsonErr {
                    print("Error decoding JSON", jsonErr)
                }
                }
                .resume()
            
        }
    }
    
    
    
    func download(fileName: String) {
        
        let baseUrl = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artwork_images/"
        
        var url = URL(string: baseUrl)!
        url.appendPathComponent(fileName)
        
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        
        let session = URLSession.shared
        let task = session.downloadTask(with: request) { file, response, error in
            print("\(Date()) \(fileName)")
            
            cache.setObject(file! as NSURL, forKey: fileName as NSString)
        }
        task.resume()
    }
    
    func cacheAllImages() {
        let queue = OperationQueue.main
        queue.maxConcurrentOperationCount = 3
        
        for i in 0..<self.fileNames.count {
            queue.addOperation {
                self.download(fileName: self.fileNames[i])
            }
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
