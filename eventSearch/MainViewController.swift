//
//  MainViewController.swift
//  eventSearch
//
//  Created by chanshin Peter Park on 11/16/18.
//  Copyright © 2018 chanshin Peter Park. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var tabSeperateControl: UISegmentedControl!
    @IBOutlet weak var searchTabView: UIView!
    @IBOutlet weak var favoriteTabView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTabView.isHidden = false
        favoriteTabView.isHidden = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    @IBAction func segmentSelected(_ sender: UISegmentedControl) {
        switch tabSeperateControl.selectedSegmentIndex
        {
        case 0:
            searchTabView.isHidden = false
            favoriteTabView.isHidden = true
        case 1:
            searchTabView.isHidden = true
            favoriteTabView.isHidden = false
        default:
            break;
        }
    }
    
}
