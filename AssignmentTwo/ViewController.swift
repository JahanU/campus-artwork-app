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

class ViewController: UIViewController {
    
    // MARK: - Property
    var allArtworks = [Artwork]() // Stores all the artworks from the JSON
    // CD = Core data
    var artworksCD = [ArtworkCore]() // This array stores the core data entities
    var artworksCDDict: [String:[ArtworkCore]]!
    var artworkLocationNotesCD = [String]()
    
    // Used to filter the search results. i.e. the section and artwork title
    var searchArtworkSection = [String]()
    var searchArtworkTitle = [String]()
    var artworkTitles = [String]()
    
    var searching = false // Check if user is searching or not
    var locationManager = CLLocationManager()
    let cache = NSCache<NSString, NSData>()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //      PersistenceService.clearCoreData()
        decodeJson() // Decode the JSON
        setLocation() // Set the location of the user
    }
}

// MARK: - Map

extension ViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
    func setLocation() { // Seeting up current location
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Setting the current location to the ashton building, & the zoom of the map
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationOfUser = locations[0]
        let lat = locationOfUser.coordinate.latitude
        let long = locationOfUser.coordinate.longitude
        let latDelta: CLLocationDegrees = 0.003 // Distance from the map
        let lonDelta: CLLocationDegrees = 0.003
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func addAnnotationsSection() { // Adding annotations for each locationNotes section
        
        for i in 0..<artworksCD.count {
            let annotation = MKPointAnnotation()
            annotation.title = artworksCD[i].locationNotes
            
            let artwork = artworksCDDict[annotation.title!]?.first
            annotation.coordinate = CLLocationCoordinate2D(latitude: artwork!.lat, longitude: artwork!.long)
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // If annotation is selected then push new view controller with selected artworks within a building
        if let buildingArtworks = view.annotation?.title {
            let vc = BuildingArtworksVC()
            
            vc.artworks = (artworksCDDict?[buildingArtworks!])! // Send to second view controller
            vc.cache = cache // Send cache (for the images)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

// MARK: - TableView

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // If searching then update section titles with search results sections
        if (searching && searchArtworkSection.count != 0) {
            for x in 0..<searchArtworkTitle.count {
                for y in 0..<artworksCD.count {
                    
                    if (searchArtworkSection[x] == artworksCD[y].locationNotes) {
                        return (searchArtworkSection[x].isEmpty) ? ("searching") : (searchArtworkSection[x])
                    }
                }
            }
        }
        // else return all sections
        return artworkLocationNotesCD[section]
    }
    
    // returns the range of Location notes. If searching then return the updated filtered sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return (searching) ? searchArtworkTitle.count : artworkLocationNotesCD.count
    }
    // If searching then return updated filtered search results, else return all sections
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (searching) ? searchArtworkTitle.count : artworksCDDict[artworkLocationNotesCD[section]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "jsonCells", for: indexPath)
        
        var titleCount = 0 // Stores how many results found from the first search input
        // If searching then store the amount of searches found at first
        if (searching && searchArtworkTitle.count > 1) {
            titleCount = searchArtworkTitle.count
            
            for x in 0..<searchArtworkTitle.count {
                for y in 0..<artworksCD.count {
                    
                    if (searchArtworkTitle[x] == artworksCD[y].title!) { // Searching title matches a title from the array
                        
                        cell.textLabel?.text = artworksCD[y].title
                        cell.detailTextLabel?.text = artworksCD[y].artist
                        
                        if !(searchArtworkSection.contains(artworksCD[y].locationNotes!)) { // If we already have the section then dont append
                            searchArtworkSection.append(artworksCD[y].locationNotes!)
                        }
                        // If the search of artworks has become shorter than the original search, than we reinit the search array with updated searches
                        if (searchArtworkSection.count != titleCount) {
                            searchArtworkSection.removeAll()
                            if (searchArtworkTitle[x] == artworksCD[y].title!) { // Searching title matches a title from the array
                                searchArtworkSection.append(artworksCD[y].locationNotes!) // Adding new titles from searches to the array
                            }
                        }
                    }
                }
            }
        }
        else  {
            let artwork = artworksCDDict[artworkLocationNotesCD[indexPath.section]]![indexPath.row]
            cell.textLabel?.text = artwork.title
            cell.detailTextLabel?.text = artwork.artist
        }
        
        return cell
    }
    
    
    // Passes the selected section and row to the second screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let secondClass = segue.destination as? DetailViewController {
            let arrayIndexRow = table.indexPathForSelectedRow?.row
            let arrayIndexSection = table.indexPathForSelectedRow?.section
            secondClass.desArtworkDetail = artworksCDDict[artworkLocationNotesCD[arrayIndexSection!]]![arrayIndexRow!]
            secondClass.cache = cache // Sending the cache image
            
            table.deselectRow(at: table.indexPathForSelectedRow!, animated: true) // Little animation touches
            
        }
    }
}



extension ViewController {
    func decodeJson() { // Importing the JSON and storing it into an array
        
        var fileNames = [String]()
        
        if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artworksOnCampus/data.php?class=campus_artworks&lastUpdate=2017-11-01") {
            let session = URLSession.shared
            
            session.dataTask(with: url) { (data, response, err) in
                
                guard let jsonData = data else { return self.loadTableView() } // If no wifi to access JSON we use the coredata entities
                
                do {
                    let decoder = JSONDecoder()
                    let getArtworks = try decoder.decode(AllArtworks.self, from: jsonData)
                    self.allArtworks = getArtworks.campus_artworks
                    
                    for i in 0..<self.allArtworks.count {
                        
                        self.artworkTitles.append(self.allArtworks[i].title!) // Used to filter the search titles
                        fileNames.append(self.allArtworks[i].fileName!) // Used to find the image from URL
                        
                        // Check if the JSON has new files or if it is already stored in core data:
                        if (PersistenceService.checkCoreData(aReportTitle: self.allArtworks[i].title!)){
                            print("Already in core data: dont need to save again")
                        }
                            
                        else {
                            print("Adding new artwork")
                            let artworkCore = ArtworkCore(context: PersistenceService.context)
                            artworkCore.title = self.allArtworks[i].title!
                            artworkCore.artist = self.allArtworks[i].artist!
                            artworkCore.information = self.allArtworks[i].Information!
                            artworkCore.yearOfWork = self.allArtworks[i].yearOfWork!
                            artworkCore.locationNotes = self.allArtworks[i].locationNotes!
                            artworkCore.fileName = self.allArtworks[i].fileName!
                            artworkCore.lat = Double(self.allArtworks[i].lat)!
                            artworkCore.long = Double(self.allArtworks[i].long)!
                            
                            PersistenceService.saveContext()
                        }
                    }
                    self.loadTableView() // after storing the new artworks (if any) we store them into core data and load the tableView
                    self.cacheAllImages(fileNames: fileNames) // Cache all the images via the artwork file name

                }
                    
                catch let jsonErr {
                    print("Error decoding JSON", jsonErr)
                }
                }
                .resume()
            
        }
    }
    
    func loadTableView() {
        print("Loading tableview from Core data")
        self.fetchCoreData() // Store and load from core data
        
        DispatchQueue.main.async(execute: {
            self.addAnnotationsSection() // Add annotations to each section
            self.table.reloadData()
        })
    }
    
    func fetchCoreData() {
        
        let fetchRequest: NSFetchRequest<ArtworkCore> = ArtworkCore.fetchRequest() // request stored core data
        do {
            // Store current location via latitude and longtitude
            let currentLat = Double((self.locationManager.location?.coordinate.latitude)!)
            let currentLong = Double((self.locationManager.location?.coordinate.longitude)!)
            let current = currentLat + currentLong
            
            artworksCD = try PersistenceService.context.fetch(fetchRequest) // Store the fetched data
            
            //Sorting the core data artwork array based on distance from current location
            artworksCD = artworksCD.sorted(by: {
                (Double($0.lat) - Double($0.long)).distance(to: current) < (Double($1.lat) - Double($1.long)).distance(to: current)
            })
            
            for i in 0..<artworksCD.count { // Storing location notes (not storing duplicates)
                if !(artworkLocationNotesCD.contains(artworksCD[i].locationNotes!)) {
                    artworkLocationNotesCD.append(artworksCD[i].locationNotes!)
                }
            }
            // Converting array into a dictonary via the sorted locationNotes from the array
            artworksCDDict = Dictionary(grouping: artworksCD, by: { $0.locationNotes! })
        }
            
        catch {
            print("error")
        }
    }
    
    func cacheAllImages(fileNames: [String]) {
        // caching 3 images at a time, makes download less intensive and can load images faster
        let queue = OperationQueue.main
        queue.maxConcurrentOperationCount = 3
        
        for i in 0..<artworksCD.count {
            queue.addOperation { // Cache 3 images at a time
                self.download(fileName: self.artworksCD[i].fileName!)
            }
        }
        
    }
    
    func download(fileName: String) {
        let session = URLSession.shared
        let baseUrl = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artwork_images/"
        
        var url = URL(string: baseUrl)!
        url.appendPathComponent(fileName) // Add the file name to the URL to retrieve the image
        
        var request = URLRequest(url: url) // Make a request to the URL
        request.cachePolicy = .returnCacheDataElseLoad
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            //print("\(Date()) \(fileName)")
            
            // Cache the image with the associated file name
            self?.cache.setObject(data! as NSData, forKey: fileName as NSString)
        }
        
        task.resume()
    }
    
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if ((searchBar.text?.isEmpty)!) { // If not searching then reset everything
            searching = false
            searchArtworkTitle.removeAll()
            searchArtworkSection.removeAll()
            table.reloadData()
        }
        else {// The user is writting the name of the artwork, with this I need to find the locationNote of that artwork and make that the section title
            searchArtworkTitle = artworkTitles.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
            searching = true
            table.reloadData()
        }
    }
    
}

