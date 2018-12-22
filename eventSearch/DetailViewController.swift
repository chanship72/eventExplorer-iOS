//
//  DetailViewController.swift
//  
//
//  Created by chanshin Peter Park on 11/19/18.
//

import UIKit
import EasyToast
import CoreLocation
import CoreData

struct artistInfo{
    var name:String!
    var followers:String!
    var popularity:String!
    var checkAt:String!
    var photoList:[String]
}
struct venueInfo{
    var address:String!
    var city:String!
    var phoneNumber:String!
    var openHours:String!
    var generalRules:String!
    var childRules:String!
    var venueLocation:CLLocationCoordinate2D?
}
struct detailEvent{
    let name:String!
    let id:String!
    var address:String!
    var icon:String!
    var venue:String!
    var time:String!
    var segmentid:String!
    var genre:String!
    var price:String!
    var status:String?
    var ticket:String?
    var seatmap:String?
    var artists:[artistInfo?]
    var venueInfo:venueInfo?
}

class DetailViewController: UITabBarController {
    var receiveName:String!
    var receiveId:String!
    var detail:detailEvent!
    var favButton:UIBarButtonItem?
    override func viewDidLoad() {
        super.viewDidLoad()

        let shareButton = UIBarButtonItem(image: UIImage(named: "twitter"), style: .plain, target: self, action: #selector(touchShareBtn))
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let eventFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteEvent")
        eventFetch.predicate = NSPredicate(format: "id = %@", receiveId)
        eventFetch.returnsObjectsAsFaults = false
        eventFetch.fetchLimit = 1
        do{
            let result = try context.fetch(eventFetch) as! [NSManagedObject]
            if result == []{
                favButton = UIBarButtonItem(image: UIImage(named:"favorite-empty"), style: .plain, target: self, action: #selector(touchFavBtn))
            }
            else{
                favButton = UIBarButtonItem(image: UIImage(named:"favorite-filled"), style: .plain, target: self, action: #selector(touchFavBtn))
            }
        }
        catch{
            print("fail")
        }
        
        self.navigationItem.rightBarButtonItems = ([favButton, shareButton] as! [UIBarButtonItem])
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    @objc func touchShareBtn(){
        let twitter="https://twitter.com/intent/tweet?text=Check+out+\(detail.name!)+located+at+\(detail.venue!).+Website:&hashtags=TravelAndEntertainmentSearch&url=\(detail.ticket!)"
        let twitterURL = URL(string: twitter.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        UIApplication.shared.open(twitterURL!)
    }

    @objc func touchFavBtn(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let eventFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteEvent")
        eventFetch.predicate = NSPredicate(format: "id = %@", detail.id)
        eventFetch.returnsObjectsAsFaults = false
        eventFetch.fetchLimit = 1
        do {
            let result = try context.fetch(eventFetch) as! [NSManagedObject]
            if result == []{
                let entity = NSEntityDescription.entity(forEntityName: "FavoriteEvent", in: context)
                let newEvent = NSManagedObject(entity: entity!, insertInto: context)
                newEvent.setValue(detail.id, forKey: "id")
                newEvent.setValue(detail.name, forKey: "name")
                newEvent.setValue(detail.address, forKey: "address")
                newEvent.setValue(detail.time, forKey: "dates")
                newEvent.setValue(detail.icon, forKey: "icon_url")
                do {
                    try context.save()
                    self.view.showToast("\(detail.name!) was added to favorites", position: .bottom, popTime: 1, dismissOnTap: true)
                    favButton?.image = UIImage(named:"favorite-filled")
                } catch {
                    print("add fail")
                }
            }
            else {
                context.delete(result[0])
                do {
                    try context.save()
                    self.view.showToast("\(detail.name!) was removed from favorites", position: .bottom, popTime: 1, dismissOnTap: true)
                    favButton?.image = UIImage(named:"favorite-empty")
                } catch {
                    print("delete fail")
                }
            }
        } catch {
            print("fail")
        }
    }
}
