//
//  FavoriteViewController.swift
//  eventSearch
//
//  Created by chanshin Peter Park on 11/16/18.
//  Copyright © 2018 chanshin Peter Park. All rights reserved.
//

import UIKit
import CoreData
import EasyToast

class FavoriteViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var favoriteTable: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext!
    var favoriteEvent:[FavoriteEvent] = []
    var selectedTableRowNum:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        context = appDelegate.persistentContainer.viewContext
        let eventFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteEvent")
        do{
            let result = try context.fetch(eventFetch) as! [NSManagedObject]
            self.favoriteEvent = result as! [FavoriteEvent]
            self.favoriteTable.reloadData()
        }catch{
            print("fail")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favoriteEvent.count == 0 {
            tableView.isHidden = true
        }
        else {
            tableView.isHidden = false
        }
        return favoriteEvent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteTabCell", for: indexPath) as! FavoriteTableViewCell
        cell.name.text = favoriteEvent[indexPath.row].name
        cell.address.text = favoriteEvent[indexPath.row].address
//        if let url = URL(string: favoriteEvent[indexPath.row].icon_url!) {
//            if let data = NSData(contentsOf: url) {
//                cell.icon.image = UIImage(data: data as Data)
//            }
//        }
//        print(favoriteEvent[indexPath.row].icon_url!)
        if favoriteEvent[indexPath.row].icon_url == "Arts & Theatre"{
            cell.icon.image = UIImage(named:"arts")
        }else{
            cell.icon.image = UIImage(named:favoriteEvent[indexPath.row].icon_url!.lowercased())
        }
        cell.dates.text = favoriteEvent[indexPath.row].dates

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTableRowNum=indexPath.row
        performSegue(withIdentifier: "showDetailFromFav", sender: self)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") {
            action, index in
            let name = self.favoriteEvent[indexPath.row].name
            self.context.delete(self.favoriteEvent[indexPath.row])
            do {
                try self.context.save()
                self.view.showToast("\(name!) was removed from favorites", position: .bottom, popTime: 1, dismissOnTap: true)
            } catch {
                print("delete fail")
            }
            self.favoriteEvent.remove(at: indexPath.row)
            tableView.reloadData()
        }
        delete.backgroundColor = UIColor.red
        return [delete]
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! DetailViewController
        dest.receiveName = favoriteEvent[selectedTableRowNum].name
        dest.receiveId = favoriteEvent[selectedTableRowNum].id
    }
}
