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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: - Property
    
    var artworksCoreData = [ArtworkCore]()
    var artworksCoreDataDict: [String:[ArtworkCore]]!
    
    var reports: [String: [Artwork]]!
    var allArtworks = [Artwork]()
    
    var artworkLocationNotes = [String]()
    var searchArtworkSection = [String]()
    var searchArtworkTitle = [String]()
    var artworkTitles = [String]()
    
    var searching = false
    
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var table: UITableView!
    
    let cache = NSCache<NSString, NSData>()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        PersistenceService.clearCoreData()
        decodeJson()
        
        let fetchRequest: NSFetchRequest<ArtworkCore> = ArtworkCore.fetchRequest()
        do {
            let artworksCoreData = try PersistenceService.context.fetch(fetchRequest)
            
            print("coreData \(artworksCoreData.count)")

            let currentLat = Double((self.locationManager.location?.coordinate.latitude)!)
            let currentLong = Double((self.locationManager.location?.coordinate.longitude)!)
            let current = currentLat + currentLong
            
            print("current location is: \(current)")
            
//            self.artworksCoreData = artworksCoreData.sorted(by: {
//                (Double($0.lat) + Double($0.long)).distance(to: current) < (Double($1.lat) + Double($1.long)).distance(to: current)
//            })
            
            self.artworksCoreData = artworksCoreData.sorted(by: {
                (Double($0.lat) + Double($0.long)) - current < (Double($1.lat) + Double($1.long)) - current})
            
            for i in 0..<self.artworksCoreData.count {
                print("\(i) + \(self.artworksCoreData[i].locationNotes)")
            }
            
            self.artworksCoreDataDict = Dictionary(grouping: self.artworksCoreData, by: { $0.locationNotes! })
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
                        //                        print("found match sections: \(searchArtworkSection.count)")
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
        if (searching == false && searchArtworkSection.count == 0) {
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
                var artwork = artworksCoreData[0]
                
                if (searchArtworkTitle.count > 1) {// If this shortens as the word has been shortened, then we reinit the searchArtworkSection array
                    titleCount = searchArtworkTitle.count
                }
                
                for y in 0..<artworksCoreData.count {
                    artwork = artworksCoreData[y]
                    
                    if (searchArtworkTitle[x] == artwork.title!) { // Searching title matches a title from the array
                        
                        cell.textLabel?.text = artwork.title
                        cell.detailTextLabel?.text = artwork.artist
                        
                        if !(searchArtworkSection.contains(artworksCoreData[y].locationNotes!)) { // If we already have the section then dont append
                            searchArtworkSection.append(artworksCoreData[y].locationNotes!)
                        }
                        if (searchArtworkSection.count != titleCount) {
                            searchArtworkSection.removeAll()
                            if (searchArtworkTitle[x] == artwork.title!) { // Searching title matches a title from the array
                                searchArtworkSection.append(artworksCoreData[y].locationNotes!)
                            }
                        }
                    }
                }
            }
        }
        else {
            
            let artwork = artworksCoreDataDict[artworkLocationNotes[indexPath.section]]![indexPath.row]
            
            cell.textLabel?.text = artwork.title
            cell.detailTextLabel?.text = artwork.artist
            
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: artwork.lat, longitude: artwork.long) // Pinpoint the coordinates
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
        
        var fileNames = [String]()
        
        if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artworksOnCampus/data.php?class=campus_artworks&lastUpdate=2017-11-01") {
            let session = URLSession.shared
            
            session.dataTask(with: url) { (data, response, err) in
                
                guard let jsonData = data else { return }
                
                do {
                    let decoder = JSONDecoder()
                    let getArtworks = try decoder.decode(AllArtworks.self, from: jsonData)
                    self.allArtworks = getArtworks.campus_artworks
                    
                    //                    self.allArtworks = self.allArtworks.sorted(by: {
                    //                        (Double($0.lat)! + Double($0.long)!).distance(to: current) < (Double($1.lat)! + Double($1.long)!).distance(to: current)
                    //                    })
                    
                    self.reports = Dictionary(grouping: self.allArtworks, by: { $0.locationNotes! })
                    
                    for (key, _) in self.reports {
                        self.artworkLocationNotes.append(key)
                    }
                    
//                     Check if the JSON has new files or if it is already stored in core data:
                 
                    for i in 0..<self.allArtworks.count {
                        let artworkCore = ArtworkCore(context: PersistenceService.context)
                        
                        if (PersistenceService.checkCoreData(aReportTitle: self.allArtworks[i].title!)){
                            print("Already in core data: dont save again!")
                        }
                        
                        else {
                            print("adding new!")
                            artworkCore.title = self.allArtworks[i].title
                            artworkCore.artist = self.allArtworks[i].artist
                            artworkCore.information = self.allArtworks[i].Information
                            artworkCore.yearOfWork = self.allArtworks[i].yearOfWork
                            artworkCore.locationNotes = self.allArtworks[i].locationNotes

                            artworkCore.lat = Double(self.allArtworks[i].lat)!
                            artworkCore.long = Double(self.allArtworks[i].long)!

                            self.artworksCoreData.append(artworkCore)

                            self.artworkTitles.append(self.allArtworks[i].title!) // Used to filter the search titles
                            fileNames.append(self.allArtworks[i].fileName!)
                        }
                    }
                    
                    print("all artworks \(self.allArtworks.count)")
                    
                    PersistenceService.saveContext()
                    
                    DispatchQueue.main.async(execute: {
                        self.table.reloadData()
                    })
                    
                    self.cacheAllImages(fileNames: fileNames)
                }
                    
                catch let jsonErr {
                    print("Error decoding JSON", jsonErr)
                }
                
                }
                .resume()
            
        }
    }
    
    func download(fileName: String) {
        let session = URLSession.shared
        
        let baseUrl = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/artwork_images/"
        
        var url = URL(string: baseUrl)!
        url.appendPathComponent(fileName)
        
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            //            print("\(Date()) \(fileName)")
            
            self?.cache.setObject(data! as NSData, forKey: fileName as NSString)
        }
        
        task.resume()
    }
    
    func cacheAllImages(fileNames: [String]) {
        let queue = OperationQueue.main
        queue.maxConcurrentOperationCount = 3
        
        for i in 0..<fileNames.count {
            queue.addOperation {
                self.download(fileName: fileNames[i])
            }
        }
    }
    
    
    // Passes the selected section and row to the second screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let secondClass = segue.destination as? DetailViewController {
            let arrayIndexRow = table.indexPathForSelectedRow?.row
            let arrayIndexSection = table.indexPathForSelectedRow?.section
            
            secondClass.desArtworkDetail = reports[artworkLocationNotes[arrayIndexSection!]]![arrayIndexRow!]
            secondClass.cache = cache
            
            table.deselectRow(at: table.indexPathForSelectedRow!, animated: true) // Little animation touches
        }
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if (searchBar.text?.isEmpty == true) {
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
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        table.reloadData()
    }
    
}
//
//
//    func getCurrentLatLong() -> Double { // grouped by distance
//        let currentLat = Double((locationManager.location?.coordinate.latitude)!)
//        let currentLong = Double((locationManager.location?.coordinate.longitude)!)
//        return currentLat + currentLong
//    }
//


//
