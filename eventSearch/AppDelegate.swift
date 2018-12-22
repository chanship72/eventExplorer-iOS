//
//  AppDelegate.swift
//  eventSearch
//
//  Created by chanshin Peter Park on 11/16/18.
//  Copyright © 2018 chanshin Peter Park. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreData
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSPlacesClient.provideAPIKey("AIzaSyASkeq3CB5KbrpTJNo-Zbv9VgoIR5DnT20")
        GMSServices.provideAPIKey("AIzaSyASkeq3CB5KbrpTJNo-Zbv9VgoIR5DnT20")
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    lazy var persistentContainer: NSPersistentContainer = {

        let pcontainer = NSPersistentContainer(name: "FavoriteModel")
        pcontainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return pcontainer
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let pcontext = persistentContainer.viewContext
        if pcontext.hasChanges {
            do {
                try pcontext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

