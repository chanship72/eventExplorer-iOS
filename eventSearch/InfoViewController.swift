//
//  InfoViewController.swift
//  eventSearch
//
//  Created by chanshin Peter Park on 11/18/18.
//  Copyright © 2018 chanshin Peter Park. All rights reserved.
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SwiftSpinner
import CoreLocation

class InfoViewController: UIViewController {

    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var venueView: UIView!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var ticketView: UIView!
    @IBOutlet weak var seatmapView: UIView!
    
    @IBOutlet weak var nameText: UITextView!
    @IBOutlet weak var venueText: UITextView!
    @IBOutlet weak var timeText: UITextView!
    @IBOutlet weak var categoryText: UITextView!
    @IBOutlet weak var priceText: UITextView!
    @IBOutlet weak var statusText: UITextView!
    @IBOutlet weak var ticketText: UITextView!
    @IBOutlet weak var seatmapText: UITextView!
    let geocoder = CLGeocoder()

    override func viewDidLoad() {
        super.viewDidLoad()

        initDetailData()
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    func initDetailData(){
        SwiftSpinner.show("Searching Details......")
        let detailContainer = self.tabBarController as! DetailViewController
        let eventID = detailContainer.receiveId!
        let url = "http://eventexplorer.us-west-1.elasticbeanstalk.com/detailinfo/\(eventID)"
        Alamofire.request(url, method: .get, encoding: URLEncoding.queryString)
            .responseSwiftyJSON { response in
                print("Request: \(String(describing: response.request))")
                print("Response: \(String(describing: response.response))")
                if response.result.value != nil{
                    let swiftJson = response.result.value
                    let result = swiftJson!
                    
                    detailContainer.detail = detailEvent(
                        name: result["name"].string,
                        id: eventID,
                        address:"N/A",
                        icon:"N/A",
                        venue: "N/A",
                        time: "N/A",
                        segmentid: "N/A",
                        genre: "N/A",
                        price: "N/A",
                        status: "N/A",
                        ticket: "N/A",
                        seatmap: "N/A",
                        artists: [],
                        venueInfo: venueInfo()
                    )
                    //name
                    self.nameText.text = result["name"].string
//                    if result["images"][0]["url"].exists(){
//                        detailContainer.detail.icon = result["images"][0]["url"].string
//                    }
                    
                    if result["_embedded"]["venues"][0]["name"].exists(){
                        detailContainer.detail.address = result["_embedded"]["venues"][0]["name"].string
                    }
                    //venue
                    if result["_embedded"]["venues"][0]["name"].exists(){
                        detailContainer.detail.venue = result["_embedded"]["venues"][0]["name"].string
                        self.venueText.text = detailContainer.detail.venue
                    }
                    else{
                        self.venueText.text = "N/A"
                    }
                    //time
                    if result["dates"]["start"].exists(){
                        let dateFormatterGet = DateFormatter()
                        dateFormatterGet.dateFormat = "yyyy-MM-dd"
                        
                        let dateFormatterPrint = DateFormatter()
                        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
                        
                        let date: Date? = dateFormatterGet.date(from: result["dates"]["start"]["localDate"].stringValue)
                        
                        detailContainer.detail.time = result["dates"]["start"]["localDate"].stringValue
                        self.timeText.text = dateFormatterPrint.string(from: date!) + " " + result["dates"]["start"]["localTime"].stringValue
                        
                    }
                    else{
                        self.timeText.text = "N/A"
                    }
                    //category
                    if result["classifications"].exists(){
                        detailContainer.detail.segmentid = result["classifications"][0]["segment"]["name"].stringValue
                        detailContainer.detail.icon = result["classifications"][0]["segment"]["name"].stringValue
                        detailContainer.detail.genre = result["classifications"][0]["genre"]["name"].stringValue
                        self.categoryText.text = detailContainer.detail.segmentid + " | " + detailContainer.detail.genre
                    }
                    else{
                        self.categoryText.text = "N/A"
                    }
                    //price
                    var priceStr = ""
                    if result["priceRanges"][0]["min"].exists(){
                        if result["priceRanges"][0]["max"].exists(){
                            priceStr = "$" + result["priceRanges"][0]["min"].stringValue + " ~ $" + result["priceRanges"][0]["max"].stringValue
                            detailContainer.detail.price = priceStr
                        }else{
                            //min only
                            detailContainer.detail.price = "$" + result["priceRanges"][0]["min"].stringValue
                        }
                        self.priceText.text = detailContainer.detail.price
                    }
                    else{
                        if result["priceRanges"][0]["max"].exists(){
                            detailContainer.detail.price = result["priceRanges"][0]["max"].stringValue
                            self.priceText.text = detailContainer.detail.price
                        }else{
                            self.priceText.text = "N/A"
                        }
                    }
                    //status
                    if result["dates"]["status"].exists(){
                        detailContainer.detail.status = result["dates"]["status"]["code"].string
                        self.statusText.text = detailContainer.detail.status
                    }
                    else{
                        self.statusText.text = "N/A"
                    }
                    //url
                    if result["url"].exists(){
                        detailContainer.detail.ticket = result["url"].string
                        
                        let linkAttr = [
                            NSAttributedString.Key.link: detailContainer.detail.ticket!,
                            NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 15.0)!,
                            NSAttributedString.Key.foregroundColor: UIColor.blue
                            ] as [NSAttributedString.Key : Any]
                        
                        let attrStr = NSMutableAttributedString(string: "Ticketmaster")
                        attrStr.setAttributes(linkAttr, range: NSMakeRange(0, 12))
                        
                        self.ticketText.attributedText = attrStr
                        
                    }
                    else{
                        self.ticketText.text = "N/A"
                    }
                    //seatmap
                    if result["seatmap"].exists(){
                        detailContainer.detail.seatmap = result["seatmap"]["staticUrl"].string

                        let linkAttributes = [
                            NSAttributedString.Key.link: detailContainer.detail.seatmap!,
                            NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 15.0)!,
                            NSAttributedString.Key.foregroundColor: UIColor.blue
                            ] as [NSAttributedString.Key : Any]
                        
                        let attributedString = NSMutableAttributedString(string: "View Here")
                        attributedString.setAttributes(linkAttributes, range: NSMakeRange(0, 9))

                        self.seatmapText.attributedText = attributedString
                    }
                    else{
                        self.seatmapText.text = "N/A"
                    }
                    //artists
                    if result["_embedded"]["attractions"].exists(){
                        for i in 0..<result["_embedded"]["attractions"].count{
                            let artist = result["_embedded"]["attractions"][i]["name"].stringValue
                            detailContainer.detail.artists.append(artistInfo(name:artist,
                                                                        followers:"",
                                                                        popularity:"",
                                                                        checkAt:"",
                                                                        photoList:[]))
                        }
                    }else{
                        let artist = result["name"].string!
                        detailContainer.detail.artists.append(artistInfo(name:artist,
                                                                         followers:"",
                                                                         popularity:"",
                                                                         checkAt:"",
                                                                         photoList:[]))
                    }
               
                let genre = detailContainer.detail.segmentid
                
                if genre?.lowercased() == "music" && detailContainer.detail.artists.count > 0{
                    //        for i in 0..<1{
                    let infoUrl = "http://eventexplorer.us-west-1.elasticbeanstalk.com/artist"
                    let aparameters:Dictionary<String,String> = ["artist":String(detailContainer.detail.artists[0]!.name)]
                    Alamofire.request(infoUrl, method: .get, parameters: aparameters, encoding: URLEncoding.default)
                        .responseSwiftyJSON { response in
                            print("Request: \(String(describing: response.request))")
                            print("Response: \(String(describing: response.response))")
                            if response.result.value != nil{
                                let swiftJson = response.result.value
                                let result = swiftJson!["artists"]
                                
                                //detailContainer.detail.artists[0]!.name = result["items"][0]["name"].stringValue
                                detailContainer.detail.artists[0]!.followers = result["items"][1]["followers"]["total"].stringValue
                                detailContainer.detail.artists[0]!.popularity = result["items"][0]["popularity"].stringValue
                                detailContainer.detail.artists[0]!.checkAt = result["items"][0]["external_urls"]["spotify"].stringValue
                            }
                            else{
                                self.view.showToast("No Record.", position: .bottom, popTime: 1, dismissOnTap: true)
                            }
                    }
                }
    
                let photoUrl = "http://eventexplorer.us-west-1.elasticbeanstalk.com/photo"
                if detailContainer.detail.artists.count > 0 {
                    let bparameters:Dictionary<String,String> = ["image":String(detailContainer.detail.artists[0]!.name)]
                
                    Alamofire.request(photoUrl, method: .get, parameters: bparameters, encoding: URLEncoding.default)
                        .responseSwiftyJSON { response in
                            print("Request: \(String(describing: response.request))")
                            print("Response: \(String(describing: response.response))")
                            if response.result.value != nil{
                                let swiftJson = response.result.value
                                let result = swiftJson!["items"]
                                
                                var photoList = [String]()
                                for k in 0..<result.count{
                                    photoList.append(result[k]["link"].stringValue)
                                }
                                detailContainer.detail.artists[0]!.photoList = photoList
                            }
                            else{
                                self.view.showToast("No Record.", position: .bottom, popTime: 1, dismissOnTap: true)
                            }
                    }
                }
                let photoUrl1 = "http://eventexplorer.us-west-1.elasticbeanstalk.com/photo"
                if detailContainer.detail.artists.count > 1 {
                    let bparameters1:Dictionary<String,String> = ["image":String(detailContainer.detail.artists[1]!.name)]
                    
                    Alamofire.request(photoUrl1, method: .get, parameters: bparameters1, encoding: URLEncoding.default)
                        .responseSwiftyJSON { response in
                            print("Request: \(String(describing: response.request))")
                            print("Response: \(String(describing: response.response))")
                            if response.result.value != nil{
                                let swiftJson = response.result.value
                                let result = swiftJson!["items"]
                                
                                var photoList = [String]()
                                for k in 0..<result.count{
                                    photoList.append(result[k]["link"].stringValue)
                                }
                                detailContainer.detail.artists[1]!.photoList = photoList
                            }
                            else{
                                self.view.showToast("No Record.", position: .bottom, popTime: 1, dismissOnTap: true)
                            }
                    }
                }
                    
                let venueUrl = "http://eventexplorer.us-west-1.elasticbeanstalk.com/venueInfo"
                let cparameters:Dictionary<String,String> = ["venueName":String(detailContainer.detail.venue)]
                    
                Alamofire.request(venueUrl, method: .get, parameters: cparameters, encoding: URLEncoding.default)
                    .responseSwiftyJSON { response in
                        print("Request: \(String(describing: response.request))")
                        print("Response: \(String(describing: response.response))")
                        if response.result.value != nil{
                            let swiftJson = response.result.value
                            let result = swiftJson!["_embedded"]["venues"][0]
                            
                            //address
                            if result["address"]["line1"].exists(){
                                detailContainer.detail.venueInfo?.address = result["address"]["line1"].stringValue
                            }
                            else{
                                detailContainer.detail.venueInfo?.address = "N/A"
                            }
                            //city
                            if result["city"]["name"].exists(){
                                detailContainer.detail.venueInfo?.city = result["city"]["name"].stringValue + ", " + result["state"]["name"].stringValue
                            }
                            else{
                                detailContainer.detail.venueInfo?.city = "N/A"
                            }

                            //Phone Number
                            if result["boxOfficeInfo"]["phoneNumberDetail"].exists(){
                                detailContainer.detail.venueInfo?.phoneNumber = result["boxOfficeInfo"]["phoneNumberDetail"].stringValue
                            }
                            else{
                                detailContainer.detail.venueInfo?.phoneNumber = "N/A"
                            }
                            //Open Hours
                            if result["boxOfficeInfo"]["openHoursDetail"].exists(){
                                detailContainer.detail.venueInfo?.openHours = result["boxOfficeInfo"]["openHoursDetail"].stringValue
                            }
                            else{
                                detailContainer.detail.venueInfo?.openHours = "N/A"
                            }
                            //General Rules
                            if result["generalInfo"]["generalRule"].exists(){
                                detailContainer.detail.venueInfo?.generalRules = result["generalInfo"]["generalRule"].stringValue
                            }
                            else{
                                detailContainer.detail.venueInfo?.generalRules = "N/A"
                            }
                            //Child Rules
                            if result["generalInfo"]["childRule"].exists(){
                                detailContainer.detail.venueInfo?.childRules = result["generalInfo"]["childRule"].stringValue
                            }
                            else{
                                detailContainer.detail.venueInfo?.childRules = "N/A"
                            }
                        }
                        else{
                            self.view.showToast("No Record.", position: .bottom, popTime: 1, dismissOnTap: true)
                        }
                        var lat = Double(0.0)
                        var lon = Double(0.0)
                        if detailContainer.detail.venueInfo?.address != nil{
                            self.geocoder.geocodeAddressString((detailContainer.detail.venueInfo?.city)!) {
                                placemarks, error in
                                let placemark = placemarks?.first
                                lat = (placemark?.location?.coordinate.latitude)!
                                lon = (placemark?.location?.coordinate.longitude)!
                                print("Lat: \(lat), Lon: \(lon)")
                                detailContainer.detail.venueInfo?.venueLocation = placemark?.location?.coordinate
                                SwiftSpinner.hide()
//                                if lat == 0 || lon == 0{
//                                    self.geocoder.geocodeAddressString((detailContainer.detail.venue)!) {
//                                        placemarks, error in
//                                        let placemarkcity = placemarks?.first
//                                        lat = (placemarkcity?.location?.coordinate.latitude)!
//                                        lon = (placemarkcity?.location?.coordinate.longitude)!
//                                        print("Lat: \(lat), Lon: \(lon)")
//
//                                        detailContainer.detail.venueInfo?.venueLocation = placemarkcity?.location?.coordinate
//                                        SwiftSpinner.hide()
//                                    }
//                                }else{
//                                }
                            }
                        }

//                        SwiftSpinner.hide()
                    }
            }
            else{
                self.view.showToast("No Record.", position: .bottom, popTime: 1, dismissOnTap: true)
            }
        }
    }
}
