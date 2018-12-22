//
//  UpcomingViewController.swift
//  eventSearch
//
//  Created by chanshin Peter Park on 11/18/18.
//  Copyright © 2018 chanshin Peter Park. All rights reserved.
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SwiftSpinner

struct Event{
    var name:String?
    var artist:String?
    var date:String?
    var time:String?
    var url:String?
    var type:String?
}

class UpcomingViewController: UIViewController,UITableViewDelegate, UITableViewDataSource  {
    
    var evtNames:[String] = []
    var evtArtist:[String] = []
    var evtDate:[String] = []
    var evtTime:[String] = []
    var evtUrl:[String] = []
    var evtType:[String] = []
    var currentSortCategory = 0
    var currentOrder = 0
    var upcomingEventList = [Event]()
    
    @IBOutlet weak var sortSegment: UISegmentedControl!
    @IBOutlet weak var orderSegment: UISegmentedControl!
    @IBOutlet weak var upcomingTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let detailCtr = self.tabBarController as! DetailViewController
        let upcomingUrl = "http://eventexplorer.us-west-1.elasticbeanstalk.com/upcomingevent"
        let parameters:Dictionary<String,String> = ["venue":String(detailCtr.detail.venue)]
        
        SwiftSpinner.show("Searching...")
        
        Alamofire.request(upcomingUrl, method: .get, parameters: parameters, encoding: URLEncoding.default)
            .responseSwiftyJSON { response in
                print("Request: \(String(describing: response.request))")
                print("Response: \(String(describing: response.response))")
                if response.result.value != nil{
                    let swiftJson = response.result.value
                    let results = swiftJson!["resultsPage"]["results"]["event"]
                    if results.count == 0{
                        self.upcomingTable.isHidden = true
                    }
                    else{
                        var totalNum = 5
                        if results.count < totalNum{
                            totalNum = results.count
                        }
                        for i in 0..<totalNum{
                            if results[i]["displayName"].exists(){
                                self.evtNames.append(results[i]["displayName"].stringValue)
                            }else{
                                self.evtNames.append("N/A")
                            }
                            
                            if results[i]["performance"][0]["artist"]["displayName"].exists(){
                                self.evtArtist.append(results[i]["performance"][0]["artist"]["displayName"].stringValue)
                            }else{
                                self.evtArtist.append("N/A")
                            }
                            if results[i]["start"]["date"].exists(){
                                self.evtDate.append(results[i]["start"]["date"].stringValue)
                            }else{
                                self.evtDate.append("N/A")
                            }
                            
                            if results[i]["start"]["time"].exists(){
                                self.evtTime.append(results[i]["start"]["time"].stringValue)
                            }else{
                                self.evtTime.append("N/A")
                            }
                            
                            if results[i]["type"].exists(){
                                self.evtType.append(results[i]["type"].stringValue)
                            }else{
                                self.evtType.append("N/A")
                            }
                            if results[i]["uri"].exists(){
                                self.evtUrl.append(results[i]["uri"].stringValue)
                            }else{
                                self.evtUrl.append("N/A")
                            }
                            self.upcomingEventList.append(Event(
                                name:self.evtNames[i],
                                artist:self.evtArtist[i],
                                date:self.evtDate[i],
                                time:self.evtTime[i],
                                url:self.evtUrl[i],
                                type:self.evtType[i]
                            ))
                        }
                    }
                    self.upcomingEventList.sorted(by: { (Obj1, Obj2) -> Bool in
                        let Obj1_Name = Obj1.artist ?? ""
                        let Obj2_Name = Obj2.artist ?? ""
                        return (Obj1_Name.localizedCaseInsensitiveCompare(Obj2_Name) == .orderedAscending)
                    })
                }
                else{
                    self.view.showToast("No Record.", position: .bottom, popTime: 2, dismissOnTap: true)
                }
                SwiftSpinner.hide()
                self.upcomingTable.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let urlString = self.upcomingEventList[indexPath.row].url
        if let url = URL(string: urlString!)
        {
            UIApplication.shared.openURL(url)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("show \(self.upcomingEventList.count) records")
//        return self.evtNames.count
        if self.upcomingEventList.count > 5{
            return 5
        }else{
            return self.upcomingEventList.count
        }
    }
    @IBAction func changeOrder(_ sender: Any) {
        switch self.orderSegment.selectedSegmentIndex{
        case 0:
            if self.currentOrder == 1{
                self.upcomingEventList = self.upcomingEventList.reversed()
                self.currentOrder = 0
            }
        case 1:
            if self.currentOrder == 0{
                self.upcomingEventList = self.upcomingEventList.reversed()
                self.currentOrder = 1
            }
        default:
            if self.currentOrder == 1{
                self.upcomingEventList = self.upcomingEventList.reversed()
                self.currentOrder = 0
            }
        }
        self.upcomingTable.reloadData()
    }
    @IBAction func changeSort(_ sender: Any) {
        switch self.sortSegment.selectedSegmentIndex{
        case 0:
            self.orderSegment.isUserInteractionEnabled = false
            self.orderSegment.isEnabled = false
            
            self.currentSortCategory = 0
            if self.currentOrder == 0{
                self.orderSegment.isEnabled = false
                self.upcomingEventList = self.upcomingEventList.sorted(by: { (Obj1, Obj2) -> Bool in
                    let Obj1_Name = Obj1.name ?? ""
                    let Obj2_Name = Obj2.name ?? ""
                    return (Obj1_Name.localizedCaseInsensitiveCompare(Obj2_Name) == .orderedAscending)
                })
            }else{
                self.upcomingEventList = self.upcomingEventList.sorted(by: { (Obj1, Obj2) -> Bool in
                    let Obj1_Name = Obj1.name ?? ""
                    let Obj2_Name = Obj2.name ?? ""
                    return (Obj1_Name.localizedCaseInsensitiveCompare(Obj2_Name) == .orderedDescending)
                })
            }
        case 1:
            self.orderSegment.setEnabled(true, forSegmentAt: 0)
            self.orderSegment.isEnabled = true
            self.orderSegment.isUserInteractionEnabled = true
            self.currentSortCategory = 1
            if self.currentOrder == 0{
                self.upcomingEventList = self.upcomingEventList.sorted(by: { (Obj1, Obj2) -> Bool in
                    let Obj1_Name = Obj1.name ?? ""
                    let Obj2_Name = Obj2.name ?? ""
                    return (Obj1_Name.localizedCaseInsensitiveCompare(Obj2_Name) == .orderedAscending)
                })
            }else{
                self.upcomingEventList = self.upcomingEventList.sorted(by: { (Obj1, Obj2) -> Bool in
                    let Obj1_Name = Obj1.name ?? ""
                    let Obj2_Name = Obj2.name ?? ""
                    return (Obj1_Name.localizedCaseInsensitiveCompare(Obj2_Name) == .orderedDescending)
                })
            }
        case 2:
            self.orderSegment.setEnabled(true, forSegmentAt: 0)
            self.orderSegment.isEnabled = true
            self.orderSegment.isUserInteractionEnabled = true
            self.currentSortCategory = 2
            if self.currentOrder == 0{
                self.upcomingEventList = self.upcomingEventList.sorted(by: { (Obj1, Obj2) -> Bool in
                    let Obj1_Name = Obj1.date ?? ""
                    let Obj2_Name = Obj2.date ?? ""
                    return (Obj1_Name.localizedCaseInsensitiveCompare(Obj2_Name) == .orderedAscending)
                })
            }else{
                self.upcomingEventList = self.upcomingEventList.sorted(by: { (Obj1, Obj2) -> Bool in
                    let Obj1_Name = Obj1.date ?? ""
                    let Obj2_Name = Obj2.date ?? ""
                    return (Obj1_Name.localizedCaseInsensitiveCompare(Obj2_Name) == .orderedDescending)
                })
            }
        case 3:
            self.orderSegment.setEnabled(true, forSegmentAt: 0)
            self.orderSegment.isEnabled = true
            self.orderSegment.isUserInteractionEnabled = true
            self.currentSortCategory = 3
            if self.currentOrder == 0{
                self.upcomingEventList = self.upcomingEventList.sorted(by: { (Obj1, Obj2) -> Bool in
                    let Obj1_Name = Obj1.artist ?? ""
                    let Obj2_Name = Obj2.artist ?? ""
                    return (Obj1_Name.localizedCaseInsensitiveCompare(Obj2_Name) == .orderedAscending)
                })
            }else{
                self.upcomingEventList = self.upcomingEventList.sorted(by: { (Obj1, Obj2) -> Bool in
                    let Obj1_Name = Obj1.artist ?? ""
                    let Obj2_Name = Obj2.artist ?? ""
                    return (Obj1_Name.localizedCaseInsensitiveCompare(Obj2_Name) == .orderedDescending)
                })
            }
        case 4:
            self.orderSegment.setEnabled(true, forSegmentAt: 0)
            self.orderSegment.isEnabled = true
            self.orderSegment.isUserInteractionEnabled = true
            
            self.currentSortCategory = 4
            if self.currentOrder == 0{
                self.upcomingEventList = self.upcomingEventList.sorted(by: { (Obj1, Obj2) -> Bool in
                    let Obj1_Name = Obj1.type ?? ""
                    let Obj2_Name = Obj2.type ?? ""
                    return (Obj1_Name.localizedCaseInsensitiveCompare(Obj2_Name) == .orderedAscending)
                })
            }else{
                self.upcomingEventList = self.upcomingEventList.sorted(by: { (Obj1, Obj2) -> Bool in
                    let Obj1_Name = Obj1.type ?? ""
                    let Obj2_Name = Obj2.type ?? ""
                    return (Obj1_Name.localizedCaseInsensitiveCompare(Obj2_Name) == .orderedDescending)
                })
            }
        default:
            self.orderSegment.setEnabled(true, forSegmentAt: 0)
            self.orderSegment.isEnabled = true
            self.orderSegment.isUserInteractionEnabled = true
            self.currentSortCategory = 0
            if self.currentOrder == 0{
                self.upcomingEventList.sorted(by: { (Obj1, Obj2) -> Bool in
                    let Obj1_Name = Obj1.name ?? ""
                    let Obj2_Name = Obj2.name ?? ""
                    return (Obj1_Name.localizedCaseInsensitiveCompare(Obj2_Name) == .orderedAscending)
                })
            }else{
                self.upcomingEventList.sorted(by: { (Obj1, Obj2) -> Bool in
                    let Obj1_Name = Obj1.name ?? ""
                    let Obj2_Name = Obj2.name ?? ""
                    return (Obj1_Name.localizedCaseInsensitiveCompare(Obj2_Name) == .orderedDescending)
                })
            }
        }
        self.upcomingTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "upcomingCell", for: indexPath) as! UpcomingTableViewCell
        if self.upcomingEventList.count > 0{
            cell.uevtName.text = self.upcomingEventList[indexPath.row].name ?? "N/A"
            cell.uevtArtist.text = self.upcomingEventList[indexPath.row].artist  ?? "N/A"
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd"
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMM dd,yyyy"
            
            let date: Date? = dateFormatterGet.date(from: self.upcomingEventList[indexPath.row].date!)

            cell.uevtDate.text = dateFormatterPrint.string(from: date!)
            cell.uevtDate.text += " " + self.upcomingEventList[indexPath.row].time!
            cell.uevtType.text = "Type: " + self.upcomingEventList[indexPath.row].type!
            cell.uri = self.upcomingEventList[indexPath.row].url!
        }
        return cell
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.upcomingTable.reloadData()
    }
}
