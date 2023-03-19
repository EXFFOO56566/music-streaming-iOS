//
//  LibraryVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 17/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK
import SwiftEventBus
import GoogleMobileAds

class LibraryVC: UIViewController {
    
    @IBOutlet weak var chatBtn: UIBarButtonItem!
    
    let libraryNameArray = [
        (NSLocalizedString("Liked", comment: "")),
        (NSLocalizedString("Recently Played", comment: "")),
        (NSLocalizedString("Favorite", comment: "")),
        (NSLocalizedString("Shared", comment: "")),
        (NSLocalizedString("Latest Download", comment: "")),
        (NSLocalizedString("Purchases", comment: ""))
        
    ]
    let libraryImageArray = [
        "heart_white",
        "play-button_white",
        "favorite",
        "share",
        "ic_latest_downloads",
         "dollar_in_white"
    ]
    let libraryNameArray1 = [
           NSLocalizedString("Liked", comment: ""),
           (NSLocalizedString("Recently Played", comment: "")),
           (NSLocalizedString("Favorite", comment: "")),
           (NSLocalizedString("Shared", comment: "")),
           (NSLocalizedString("Latest Download", comment: "")),
           (NSLocalizedString("Purchases", comment: ""))
       ]
       let libraryImageArray1 = [
           "heart_white",
           "play-button_white",
           "favorite",
           "share",
            "dollar_in_white"
       ]
    var bannerView: GADBannerView!
    var interstitial: GADInterstitialAd!
    
    @IBOutlet weak var titleLabel: UINavigationItem!
    @IBOutlet weak var libraryTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chatBtn.tintColor = .ButtonColor
        self.setupUI()
        self.titleLabel.title = (NSLocalizedString("Library", comment: ""))
        SwiftEventBus.onMainThread(self, name:   EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            log.verbose("To dismiss the popover")
            AppInstance.instance.player = nil
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        SwiftEventBus.onMainThread(self, name:   "PlayerReload") { result in
            let stringValue = result?.object as? String
            self.view.makeToast(stringValue)
            log.verbose(stringValue)
        }
        if ControlSettings.shouldShowAddMobBanner{
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            addBannerViewToView(bannerView)
            bannerView.adUnitID = ControlSettings.addUnitId
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID:ControlSettings.interestialAddUnitId,
                                   request: request,
                                   completionHandler: { (ad, error) in
                                    if let error = error {
                                        print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                        return
                                    }
                                    self.interstitial = ad
                                   }
            )

        }
    }
    func CreateAd() -> GADInterstitialAd {
        
        GADInterstitialAd.load(withAdUnitID:ControlSettings.interestialAddUnitId,
                               request: GADRequest(),
                               completionHandler: { (ad, error) in
                                if let error = error {
                                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                    return
                                }
                                self.interstitial = ad
                               }
        )
        return  self.interstitial
        
    }
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
        ])
    }
    
    
    private func setupUI(){
        self.libraryTableView.separatorStyle = .none
        libraryTableView.register(R.nib.libraryTableCell(), forCellReuseIdentifier: R.reuseIdentifier.library_TableCell.identifier)
        
    }
    
    
    @IBAction func chatPressed(_ sender: Any) {
        let vc = R.storyboard.chat.chatVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
extension LibraryVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ControlSettings.showHideDownloadBtn{
               return self.libraryNameArray1.count
        }else{
               return self.libraryNameArray.count
        }
     
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if ControlSettings.showHideDownloadBtn{
                   let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.library_TableCell.identifier) as? Library_TableCell
                       cell?.libraryImage.image = UIImage(named: self.libraryImageArray1[indexPath.row])
                       cell?.nameLabel.text = self.libraryNameArray1[indexPath.row]
                       return cell!
               }else{
                     let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.library_TableCell.identifier) as? Library_TableCell
                         cell?.libraryImage.image = UIImage(named: self.libraryImageArray[indexPath.row])
                         cell?.nameLabel.text = self.libraryNameArray[indexPath.row]
                         return cell!
               }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if AppInstance.instance.addCount == ControlSettings.interestialCount {
            interstitial.present(fromRootViewController: self)
                interstitial = CreateAd()
                AppInstance.instance.addCount = 0
        }
        AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1
        self.showDidScreen(index: indexPath.row, ShowHideDownloadBtn: ControlSettings.showHideDownloadBtn)
    }
    private func showDidScreen(index:Int?,ShowHideDownloadBtn:Bool){
        if ShowHideDownloadBtn{
            if index == 0{
                       let vc = R.storyboard.library.likedVC()
                       self.navigationController?.pushViewController(vc!, animated: true)
                   }else if index == 1{
                       let vc = R.storyboard.library.recentlyPlayedVC()
                       self.navigationController?.pushViewController(vc!, animated: true)
                       
                   }else if index == 2{
                       let vc = R.storyboard.library.favoriteVC()
                       self.navigationController?.pushViewController(vc!, animated: true)
                       
                   }else if index == 3{
                       let vc = R.storyboard.library.sharedVC()
                       self.navigationController?.pushViewController(vc!, animated: true)
                       
                   }else if index == 4{
                       let vc = R.storyboard.library.purchasesVC()
                       self.navigationController?.pushViewController(vc!, animated: true)
                       
                   }
        }else{
            if index == 0{
                       let vc = R.storyboard.library.likedVC()
                       self.navigationController?.pushViewController(vc!, animated: true)
                   }else if index == 1{
                       let vc = R.storyboard.library.recentlyPlayedVC()
                       self.navigationController?.pushViewController(vc!, animated: true)
                       
                   }else if index == 2{
                       let vc = R.storyboard.library.favoriteVC()
                       self.navigationController?.pushViewController(vc!, animated: true)
                       
                   }else if index == 3{
                       let vc = R.storyboard.library.sharedVC()
                       self.navigationController?.pushViewController(vc!, animated: true)
                       
                   }else if index == 4{
                       let vc = R.storyboard.library.latestDownloadVC()
                       self.navigationController?.pushViewController(vc!, animated: true)
                       
                   }else if index == 5{
                       let vc = R.storyboard.library.purchasesVC()
                       self.navigationController?.pushViewController(vc!, animated: true)
                       
                   }
        }
       
        
    }
}
