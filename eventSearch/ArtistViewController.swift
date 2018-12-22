//
//  ArtistViewController.swift
//  eventSearch
//
//  Created by chanshin Peter Park on 11/18/18.
//  Copyright © 2018 chanshin Peter Park. All rights reserved.
//

import UIKit
import Alamofire
import Alamofire_SwiftyJSON
import SwiftSpinner

class ArtistViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet weak var artistCollection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    //MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let detailContainer = self.tabBarController as! DetailViewController

        var totalRow = 0
        
        if detailContainer.detail.segmentid.lowercased() == "music"{
            totalRow+=1
        }else{
            totalRow+=1
        }
        if (detailContainer.detail.artists.count > 0){
            if (detailContainer.detail.artists[0]?.photoList.count)! > 0{
                collectionView.isHidden = false
                totalRow += detailContainer.detail.artists[0]!.photoList.count
            }else{
                collectionView.isHidden = false
            }
            if detailContainer.detail.artists.count > 1{
                if (detailContainer.detail.artists[1]?.photoList.count)! > 0{
                    collectionView.isHidden = false
                    totalRow += detailContainer.detail.artists[1]!.photoList.count+1
                }else{
                    collectionView.isHidden = false
                }
            }
        }
        return totalRow
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let detailContainer = self.tabBarController as! DetailViewController
        let photoCell = artistCollection.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        let titleCell = artistCollection.dequeueReusableCell(withReuseIdentifier: "titleCell", for: indexPath) as! TitleCollectionViewCell
        let musicCell = artistCollection.dequeueReusableCell(withReuseIdentifier: "musicCell", for: indexPath) as! MusicArtistViewCellCollectionViewCell
        
        var interimNum0 = 0
        var interimNum1 = 0

//        print("segmentid"+detailContainer.detail.segmentid)
        if detailContainer.detail.artists.count > 0 {
            interimNum0 = (detailContainer.detail.artists[0]?.photoList.count)!
            if detailContainer.detail.artists.count > 1{
                interimNum1 = (detailContainer.detail.artists[1]?.photoList.count)!
            }
            if detailContainer.detail.segmentid.lowercased() == "music"{
                switch indexPath.row {
                case 0:
                    if detailContainer.detail.artists[0]!.name == "" {
                        musicCell.mtitleText.text = "N/A"
                    }else{
                        musicCell.mtitleText.text = detailContainer.detail.artists[0]!.name
                    }
                    if detailContainer.detail.artists[0]!.name == ""{
                        musicCell.nameText.text = "N/A"
                    }else{
                        musicCell.nameText.text = detailContainer.detail.artists[0]!.name
                    }
                    if detailContainer.detail.artists[0]!.popularity == ""{
                        musicCell.popularityText.text = "N/A"
                    }else{
                        musicCell.followersText.text = detailContainer.detail.artists[0]!.popularity
                    }
                    print("followers:"+detailContainer.detail.artists[0]!.followers)
                    if detailContainer.detail.artists[0]!.followers == ""{
                        musicCell.followersText.text = "N/A"
                    }else{
                        musicCell.followersText.text = detailContainer.detail.artists[0]!.followers
                    }
                    
                    if detailContainer.detail.artists[0]!.checkAt == ""{
                        musicCell.checkerAtText.text = "N/A"
                    }else{
                        let linkAttributes = [
                            NSAttributedString.Key.link: detailContainer.detail.artists[0]!.checkAt,
                            NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 15.0)!,
                            NSAttributedString.Key.foregroundColor: UIColor.blue
                            ] as [NSAttributedString.Key : Any]
                        let attributedString = NSMutableAttributedString(string: "Spotify")
                        attributedString.setAttributes(linkAttributes, range: NSMakeRange(0, 7))
                        musicCell.checkerAtText.attributedText = attributedString
                    }
                    
                    return musicCell
                case 1...interimNum0:
                    if let url = URL(string: (detailContainer.detail.artists[0]?.photoList[indexPath.item-1])!) {
                        if let data = NSData(contentsOf: url) {
                            photoCell.photo.image = UIImage(data: data as Data)
                        }
                    }
                    return photoCell
                case 1+interimNum0:
                    musicCell.mtitleText.text = detailContainer.detail.artists[1]!.name
                    musicCell.nameText.text = detailContainer.detail.artists[1]!.name
                    if detailContainer.detail.artists[1]!.popularity == ""{
                        musicCell.popularityText.text = "N/A"
                    }else{
                        musicCell.followersText.text = detailContainer.detail.artists[1]!.popularity
                    }
                    print("followers:"+detailContainer.detail.artists[1]!.followers)
                    if detailContainer.detail.artists[1]!.followers == ""{
                        musicCell.followersText.text = "N/A"
                    }else{
                        musicCell.followersText.text = detailContainer.detail.artists[1]!.followers
                    }
                    let linkAttributes = [
                        NSAttributedString.Key.link: detailContainer.detail.artists[1]!.checkAt,
                        NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 15.0)!,
                        NSAttributedString.Key.foregroundColor: UIColor.blue
                        ] as [NSAttributedString.Key : Any]
                    let attributedString = NSMutableAttributedString(string: "Spotify")
                    attributedString.setAttributes(linkAttributes, range: NSMakeRange(0, 7))
                    musicCell.checkerAtText.attributedText = attributedString
                    
                    return musicCell

                case 2+interimNum0...2+interimNum0+interimNum1:
                    if let url = URL(string: (detailContainer.detail.artists[1]?.photoList[indexPath.item-2-interimNum0])!) {
                        if let data = NSData(contentsOf: url) {
                            photoCell.photo.image = UIImage(data: data as Data)
                        }
                    }
                    return photoCell
                default:
                    return titleCell
                }
            }else{
                switch indexPath.row {
                case 0:
                    titleCell.titleText.text = detailContainer.detail.artists[0]!.name
                    return titleCell
                case 1...interimNum0:
                    if let url = URL(string: (detailContainer.detail.artists[0]?.photoList[indexPath.item-1])!) {
                        if let data = NSData(contentsOf: url) {
                            photoCell.photo.image = UIImage(data: data as Data)
                        }
                    }
                    return photoCell
                case interimNum0+1:
                    titleCell.titleText.text = detailContainer.detail.artists[1]!.name
                    return titleCell
                case 2+interimNum0...2+interimNum0+interimNum1:
                    if let url = URL(string: (detailContainer.detail.artists[1]?.photoList[indexPath.item-2-interimNum0])!) {
                        if let data = NSData(contentsOf: url) {
                            photoCell.photo.image = UIImage(data: data as Data)
                        }
                    }
                    return photoCell
                default:
                    titleCell.titleText.text = detailContainer.detail.artists[1]!.name
                    return titleCell
                }
            }
        }
        return titleCell
    }
}
extension ArtistViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellsAcross: CGFloat = 3
        var widthRemainingForCellContent = collectionView.bounds.width
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            let borderSize: CGFloat = flowLayout.sectionInset.left + flowLayout.sectionInset.right
            widthRemainingForCellContent -= borderSize + ((cellsAcross - 1) * flowLayout.minimumInteritemSpacing)
        }
        let cellWidth = widthRemainingForCellContent / cellsAcross
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
