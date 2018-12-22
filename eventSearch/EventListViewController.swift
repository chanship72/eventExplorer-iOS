//
//  EventListViewController.swift
//  eventSearch
//
//  Created by chanshin Peter Park on 11/18/18.
//  Copyright © 2018 chanshin Peter Park. All rights reserved.
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SwiftSpinner
import CoreData

class EventListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var resultTable: UITableView!
    @IBOutlet weak var tip: UILabel!
    var names:[String] = []
    var ids:[String] = []
    var addresses:[String] = []
    var icons:[String] = []
    var dates:[String] = []
    var selectedTableRowNum:Int = 0
    var receivedData:Dictionary<String,String> = [:]
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context = appDelegate.persistentContainer.viewContext
        SwiftSpinner.show("Searching...")
        if receivedData["keyword"] != nil{
            let parameters = receivedData
            let url = "http://eventexplorer.us-west-1.elasticbeanstalk.com/discovery"
            Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.queryString)
                .responseSwiftyJSON { response in
                    print("Request: \(String(describing: response.request))")
                    print("Response: \(String(describing: response.response))")
                    if response.result.value != nil{
                        let swiftJson = response.result.value

                        let results = swiftJson!["_embedded"]["events"]
                        if results.count == 0{
                            self.resultTable.isHidden = true
                        }
                        else{
                            for i in 0..<results.count{
                                self.names.append(results[i]["name"].string!)
//                                self.icons.append(results[i]["images"][0]["url"].string!)
                                self.icons.append(results[i]["classifications"][0]["segment"]["name"].stringValue)
                                self.addresses.append(results[i]["_embedded"]["venues"][0]["name"].string!)
                                self.ids.append(results[i]["id"].string!)
                                var dateString = ""
                                if results[i]["dates"]["start"]["localDate"].string != nil && results[i]["dates"]["start"]["localTime"].string != nil{
                                    dateString = results[i]["dates"]["start"]["localDate"].string! + " " + results[i]["dates"]["start"]["localTime"].string!
                                }else{
                                    dateString = "N/A"
                                }

                                self.dates.append(dateString)
                            }
                        }
                    }
                    else{
                        self.view.showToast("No Record.", position: .bottom, popTime: 2, dismissOnTap: true)
                    }
                    SwiftSpinner.hide()
                    self.resultTable.reloadData()
            }
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.resultTable.reloadData()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as! ResultTableViewCell
        cell.name.text = names[indexPath.row]
        cell.address.text = addresses[indexPath.row]
        cell.dates.text = dates[indexPath.row]
//        if let url = URL(string: icons[indexPath.row]) {
//            if let data = NSData(contentsOf: url) {
//                cell.icon.image = UIImage(data: data as Data)
//            }
//        }
        if icons[indexPath.row] == "Arts & Theatre"{
            cell.icon.image = UIImage(named:"arts")
        }else{
            cell.icon.image = UIImage(named:icons[indexPath.row].lowercased())
        }
        //handle favorite button
        let eventFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteEvent")
        eventFetch.predicate = NSPredicate(format: "id = %@", ids[indexPath.row])
        eventFetch.returnsObjectsAsFaults = false
        eventFetch.fetchLimit = 1
//        print(eventFetch)
        cell.favorite.tag = indexPath.row
        do {
            let result = try context.fetch(eventFetch) as! [NSManagedObject]
            if result == []{
                cell.favorite.setImage(UIImage(named:"favorite-empty"), for: .normal)
            }else{
                cell.favorite.setImage(UIImage(named:"favorite-filled"), for: .normal)
            }
        } catch {
            print("fail")
        }
        cell.favorite.addTarget(self, action: #selector(touchFavBtn), for:UIControl.Event.touchDown)
        return cell
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return names.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            selectedTableRowNum=indexPath.row
            performSegue(withIdentifier: "showDetailEvent", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! DetailViewController
        dest.receiveName = names[selectedTableRowNum]
        dest.receiveId = ids[selectedTableRowNum]
    }
    
    @objc func touchFavBtn (sender:UIButton){
        let eventFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteEvent")
        eventFetch.predicate = NSPredicate(format: "id = %@", ids[sender.tag])
        eventFetch.returnsObjectsAsFaults = false
        eventFetch.fetchLimit = 1
        do{
            let result = try context.fetch(eventFetch) as! [NSManagedObject]
            if result == []{
                let index = sender.tag
                let entity = NSEntityDescription.entity(forEntityName: "FavoriteEvent", in: context)
                let newEvent = NSManagedObject(entity: entity!, insertInto: context)
                newEvent.setValue(ids[index], forKey: "id")
                newEvent.setValue(names[index], forKey: "name")
                newEvent.setValue(addresses[index], forKey: "address")
                newEvent.setValue(dates[index], forKey: "dates")
                newEvent.setValue(icons[index], forKey: "icon_url")
                do {
                    try context.save()
                    sender.setImage(UIImage(named:"favorite-filled"), for: .normal)
                    self.view.showToast("\(names[index]) was added to favorites", position: .bottom, popTime: 1, dismissOnTap: true)
                } catch {
                    print("add fail")
                }
            }
            else{
                context.delete(result[0])
                do {
                    try context.save()
                    sender.setImage(UIImage(named:"favorite-empty"), for: .normal)
                    self.view.showToast("\(names[sender.tag]) was removed from favorites", position: .bottom, popTime: 1, dismissOnTap: true)
                } catch {
                    print("delete fail")
                }
            }
        }catch{
            print("fail")
        }
    }
}
