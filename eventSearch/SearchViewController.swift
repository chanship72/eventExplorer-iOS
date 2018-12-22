//
//  SearchViewController.swift
//  eventSearch
//
//  Created by chanshin Peter Park on 11/16/18.
//  Copyright © 2018 chanshin Peter Park. All rights reserved.
//

import UIKit
import SearchTextField
import McPicker
import DLRadioButton
import EasyToast
import CoreLocation
import Alamofire
import Alamofire_SwiftyJSON

class SearchViewController: UIViewController,UITextFieldDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var inputKeyword: SearchTextField!
    @IBOutlet weak var inputCategory: McTextField!
    @IBOutlet weak var inputDistance: UITextField!
    @IBOutlet weak var inputUnit: UITextField!
    @IBOutlet weak var inputSpecifyLocation: UITextField!
    @IBOutlet weak var currentLoc: DLRadioButton!
    @IBOutlet weak var customLoc: DLRadioButton!
    
    var noKeyword:Bool! = true
    var noLocation:Bool! = false
    let locationManager = CLLocationManager()
    var currentLocation:CLLocationCoordinate2D? = nil
    var selectedLocation:CLLocationCoordinate2D? = nil
    let geocoder = CLGeocoder()
    let categoryList:[[String]] = [["Default","All","Music","Sports","Arts & Theatre","Film","Miscellaneous"]]
    let categoryKey:[String:String] = ["Default":"all","All":"all","Music":"KZFzniwnSyZfZ7v7nJ","Sports":"KZFzniwnSyZfZ7v7nE","Arts & Theatre":"KZFzniwnSyZfZ7v7na","Film":"KZFzniwnSyZfZ7v7nn","Miscellaneous":"KZFzniwnSyZfZ7v7n1"]
    let unit:[[String]] = [["miles","kilometers"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCustomSearchTextField()

        inputKeyword.delegate = self
        inputCategory.delegate = self
        inputDistance.delegate = self
        inputUnit.delegate = self
        inputSpecifyLocation.delegate = self
        inputSpecifyLocation.isEnabled = false

        currentLoc.isSelected = true
        getCurrentLocation()
    }
    @IBAction func changeKeyword(_ sender: UITextField) {
        let keyword:String? = inputKeyword.text
        if (keyword?.trimmingCharacters(in:.whitespaces).isEmpty)!{
            self.noKeyword = true
        }
        else{
            self.noKeyword = false
        }
    }
    func getCurrentLocation(){
        let ipapi = "http://ip-api.com/json"
        
        Alamofire.request(ipapi, method: .get, encoding: URLEncoding.default)
            .responseSwiftyJSON { response in
                print("Request: \(String(describing: response.request))")
                print("Response: \(String(describing: response.response))")
                if response.result.value != nil{
                    let swiftJson = response.result.value
                    let lat = Double(swiftJson!["lat"].stringValue)
                    let lon = Double(swiftJson!["lon"].stringValue)
                    self.currentLocation = CLLocationCoordinate2D(latitude: lat!,
                                                      longitude: lon!)
                }
                else{
                    self.view.showToast("No Record.", position: .bottom, popTime: 1, dismissOnTap: true)
                }
        }
    }
    @IBAction func getLocation(_ sender: UITextField) {
//        print("specific location")
        geocoder.geocodeAddressString(sender.text!) {
            placemarks, error in
            let placemark = placemarks?.first
            self.selectedLocation = placemark?.location?.coordinate
            self.noLocation = false
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (inputKeyword.text!.trimmingCharacters(in:.whitespaces).isEmpty){
            self.noKeyword = true
        }
        
        if inputSpecifyLocation.isEnabled && (inputSpecifyLocation.text?.isEmpty)! {
            self.noLocation = true
        }
        
        if self.noKeyword || self.noLocation {
            self.view.showToast("Keyword and Location are mandatory fields", position: .bottom, popTime: 1, dismissOnTap: true)
            return false
        }
        else{
            return true
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! EventListViewController
        getCurrentLocation()
        var location = self.currentLocation
        if customLoc.isSelected{
            location = selectedLocation
        }
        let lat = String(location!.latitude)
        let lon = String(location!.longitude)
        let category = categoryKey[inputCategory.text!]
        let keyword = inputKeyword.text
        var distance = ""
        if inputDistance.text != ""{
            distance = String(Int(inputDistance.text!)!)
        }else{
            distance = "10"
        }
        var unit = "miles"
        if inputUnit.text != "miles"{
            unit = "km"
        }else{
            unit = "miles"
        }
        
        destination.receivedData = ["keyword":keyword,"segmentid":category,"radius":distance,"lat":lat,"lon":lon,"unit":unit] as! Dictionary<String, String>
//        print(destination.receivedData)
    }
    @IBAction func clickCurrent(_ sender: AnyObject) {
//        print("currentLocation")
        self.noLocation = false
        inputSpecifyLocation.isEnabled = false
        getCurrentLocation()
    }
    @IBAction func clickSpecificLocation(_ sender: AnyObject) {
//        print("specificLocation")
        if inputSpecifyLocation.text == ""{
            noLocation = true
        }
        inputSpecifyLocation.isEnabled = true
    }

    @IBAction func clear(_ sender: Any) {
        inputKeyword.text = ""
        inputCategory.text = "Default"
        inputDistance.text = ""
        inputUnit.text = "miles"
        currentLoc.isSelected = true
        inputSpecifyLocation.text = ""
        inputSpecifyLocation.isEnabled = false
        self.noKeyword = true
        self.noLocation = false
    }
    @IBAction func showCategory(_ sender: McTextField) {
        inputCategory.resignFirstResponder()
        McPicker.show(data :categoryList){
            [weak self] (selections: [Int : String]) -> Void in
            if let name = selections[0] {
                self?.inputCategory.text = name
            }
        }
    }
    @IBAction func showUnit(_ sender: McTextField) {
        inputUnit.resignFirstResponder()
        McPicker.show(data :unit){
            [weak self] (selections: [Int : String]) -> Void in
            if let name = selections[0] {
                self?.inputUnit.text = name
            }
        }
    }
    fileprivate func filterAcronymInBackground(_ criteria: String, callback: @escaping ((_ results: [SearchTextFieldItem]) -> Void)) {
        print(criteria)
        let keyword = criteria.removingWhitespaces()
        let url = URL(string: "http://eventexplorer.us-west-1.elasticbeanstalk.com/autocomplete/\(keyword)")
        print(url)
        if let url = url {
            let task = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
                do {
                    if let data = data {
                        let jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                        
                        if let jsonResults = jsonData["attractions"] as? [[String: AnyObject]] {
                            var results = [SearchTextFieldItem]()
                            
                            for result in jsonResults {
                                results.append(SearchTextFieldItem(title: result["name"] as! String))

                            }
                            
                            DispatchQueue.main.async {
                                callback(results)
                            }
                        } else {
                            DispatchQueue.main.async {
                                callback([])
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            callback([])
                        }
                    }
                }
                catch {
                    print("Network Error: \(error)")
                    DispatchQueue.main.async {
                        callback([])
                    }
                }
            })
            task.resume()
        }
    }

    fileprivate func configureCustomSearchTextField() {
        inputKeyword.theme = SearchTextFieldTheme.lightTheme()

        inputKeyword.theme.font = UIFont.systemFont(ofSize: 20)
        inputKeyword.theme.bgColor = UIColor.white
        inputKeyword.theme.cellHeight = 50
        inputKeyword.maxNumberOfResults = 5

        inputKeyword.maxResultsListHeight = 200

        inputKeyword.comparisonOptions = [.caseInsensitive]
        inputKeyword.forceRightToLeft = false
        inputKeyword.itemSelectionHandler = { filteredResults, itemPosition in
            let item = filteredResults[itemPosition]
            self.inputKeyword.text = item.title
        }
    
        inputKeyword.userStoppedTypingHandler = {
            if let criteria = self.inputKeyword.text {
                if criteria.count > 0 {
                    
                    // Show loading indicator
                    self.inputKeyword.showLoadingIndicator()
                    
                    self.filterAcronymInBackground(criteria) { results in
                        // Set new items to filter
                        self.inputKeyword.filterItems(results)
                        
                        // Stop loading indicator
                        self.inputKeyword.stopLoadingIndicator()
                    }
                }
            }
        } as (() -> Void)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.currentLocation = (locations.last?.coordinate)!
    }
}
extension CGRect{
    init(_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat) {
        self.init(x:x,y:y,width:width,height:height)
    }
    
}
extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
