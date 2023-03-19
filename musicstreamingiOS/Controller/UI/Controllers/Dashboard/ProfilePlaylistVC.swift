//
//  ProfilePlaylistVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ProfilePlaylistVC: UIViewController {
    
    @IBOutlet weak var showLabel: UILabel!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    var playlistArray = [ProfileModel.Playlist]()
    var status:Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        showLabel.text = (NSLocalizedString("There are no activity by this user ", comment: ""))
    }
    func setupUI(){
        if status!{
            if self.playlistArray.isEmpty{
                self.showImage.isHidden = false
                self.showLabel.isHidden = false
            }else{
                self.showImage.isHidden = true
                self.showLabel.isHidden = true
                
            }
        }else{
            if (AppInstance.instance.userProfile?.data?.playlists?.isEmpty) ?? false{
                self.showImage.isHidden = false
                self.showLabel.isHidden = false
            }else{
                self.showImage.isHidden = true
                self.showLabel.isHidden = true
            }
        }
        
        collectionView.register(R.nib.profilePlaylistCollectionCell(), forCellWithReuseIdentifier: R.reuseIdentifier.profilePlaylistCollectionCell.identifier)
        
    }
}
extension ProfilePlaylistVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if status!{
            return playlistArray.count ?? 0
        }else{
            if playlistArray.isEmpty{
                return AppInstance.instance.userProfile?.data?.playlists?.count ?? 0
                
            }else{
                return playlistArray.count ?? 0
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if status!{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.profilePlaylistCollectionCell.identifier, for: indexPath) as? ProfilePlaylistCollectionCell
            
            let object = self.playlistArray[indexPath.row]
            cell?.bind(object)
            
            return cell!
        }else{
            if playlistArray.isEmpty{
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.profilePlaylistCollectionCell.identifier, for: indexPath) as? ProfilePlaylistCollectionCell
                let object = AppInstance.instance.userProfile?.data?.playlists![indexPath.row]
                cell?.bind(object!)
                
                return cell!
            }else{
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.profilePlaylistCollectionCell.identifier, for: indexPath) as? ProfilePlaylistCollectionCell
                
                let object = self.playlistArray[indexPath.row]
                cell?.bind(object)
                
                return cell!
                
            }
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if status!{
                let vc = R.storyboard.playlist.showPlaylistDetailsVC()
            vc?.ProfilePlaylistObject = self.playlistArray[indexPath.row]
                  self.navigationController?.pushViewController(vc!, animated:true)
              }else{
                  let vc = R.storyboard.playlist.showPlaylistDetailsVC()
                    vc?.ProfilePlaylistObject = AppInstance.instance.userProfile?.data?.playlists![indexPath.row]
                    self.navigationController?.pushViewController(vc!, animated:true)
              }
  
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.size.width / 2 - 12
        return CGSize(width: width, height: 250)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 7)
    }
    
    
}
extension ProfilePlaylistVC:IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: (NSLocalizedString("PLAYLIST", comment: "PLAYLIST")))
    }
}
