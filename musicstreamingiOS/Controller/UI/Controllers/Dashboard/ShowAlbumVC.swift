//
//  ShowAlbumVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 23/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import SwiftEventBus
import DeepSoundSDK
import GoogleMobileAds

class ShowAlbumVC: BaseVC {
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var scrolHeight: NSLayoutConstraint!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var songsCountLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var albumTitleLabel: UILabel!
    var albumObject:TrendingModel.TopAlbum?
    var searchAlbumObject:SearchModel.Album?
    var profileAlbumObject:ProfileModel.AlbumElement?
    private var albumSongsArray = [GetAlbumSongsModel.Song]()
    private let popupContentController = R.storyboard.player.musicPlayerVC()
    private var albumSongMusicArray = [MusicPlayerModel]()
    var isPurchase:Bool? = false
    var userID:Int? = 0
    var albumID:Int? = 0
    var AlbumURL:String? = ""
        var bannerView: GADBannerView!
    var interstitial: GADInterstitialAd!
    var price : Double? = 0.0
    var albumIDSting:String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.profileImage.borderColorV = .mainColor
        self.playBtn.backgroundColor = .mainColor
        albumTitleLabel.text = (NSLocalizedString("Album", comment: ""))
        log.verbose("Search Price = \(self.searchAlbumObject?.albumID ?? "")")
        self.fetchAlbumtSongs()
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
    //
    
    @IBAction func playPressed(_ sender: Any) {
        let object = self.albumSongsArray[0]
        
        AppInstance.instance.player = nil
        AppInstance.instance.AlreadyPlayed = false
        
        
        self.albumSongsArray.forEach({ (it) in
            var audioString:String? = ""
            var isDemo:Bool? = false
            let name = it.publisher?.name ?? ""
            let time = it.timeFormatted ?? ""
            let title = it.title ?? ""
            let musicType = it.categoryName ?? ""
            let thumbnailImageString = it.thumbnail ?? ""
            
            if it.demoTrack == ""{
                audioString = it.audioLocation ?? ""
                isDemo = false
            }else if it.demoTrack != "" && it.audioLocation != ""{
                audioString = it.audioLocation ?? ""
                isDemo = false
            }else{
                audioString = it.demoTrack ?? ""
                isDemo = true
            }
            let isOwner = it.isOwner ?? false
            let audioId = it.audioID ?? ""
            let likeCount = it.countLikes?.intValue ?? 0
            let favoriteCount = it.countFavorite?.intValue ?? 0
            let recentlyPlayedCount = it.countViews?.intValue ?? 0
            let sharedCount = it.countShares?.intValue ?? 0
            let commentCount = it.countComment?.intValue ?? 0
            let trackId = it.id ?? 0
            let isLiked = it.isLiked ?? false
            let isFavorited = it.isFavoriated ?? false
            let likecountString = it.countLikes?.stringValue ?? ""
            let favoriteCountString = it.countFavorite?.stringValue ?? ""
            let recentlyPlayedCountString = it.countViews?.stringValue ?? ""
            let sharedCountString = it.countShares?.stringValue ?? ""
            let commentCountString = it.countComment?.stringValue ?? ""
            
            let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
            self.albumSongMusicArray.append(musicObject)
        })
        var audioString:String? = ""
        var isDemo:Bool? = false
        let name = object.publisher?.name ?? ""
        let time = object.timeFormatted ?? ""
        let title = object.title ?? ""
        let musicType = object.categoryName ?? ""
        let thumbnailImageString = object.thumbnail ?? ""
        if object.demoTrack == ""{
            audioString = object.audioLocation ?? ""
            isDemo = false
        }else if object.demoTrack != "" && object.audioLocation != ""{
            audioString = object.audioLocation ?? ""
            isDemo = false
        }else{
            audioString = object.demoTrack ?? ""
            isDemo = true
        }
        let isOwner = object.isOwner ?? false
        let audioId = object.audioID ?? ""
        let likeCount = object.countLikes?.intValue ?? 0
        let favoriteCount = object.countFavorite?.intValue ?? 0
        let recentlyPlayedCount = object.countViews?.intValue ?? 0
        let sharedCount = object.countShares?.intValue ?? 0
        let commentCount = object.countComment?.intValue ?? 0
        let trackId = object.id ?? 0
        let isLiked = object.isLiked ?? false
        let isFavorited = object.isFavoriated ?? false
        
        let likecountString = object.countLikes?.stringValue ?? ""
        let favoriteCountString = object.countFavorite?.stringValue ?? ""
        let recentlyPlayedCountString = object.countViews?.stringValue ?? ""
        let sharedCountString = object.countShares?.stringValue ?? ""
        let commentCountString = object.countComment?.stringValue ?? ""
        
        let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
        popupContentController!.popupItem.title = object.publisher?.name ?? ""
        popupContentController!.popupItem.subtitle = object.title?.htmlAttributedString ?? ""
        let cell  = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? BrowseAlbums_TableCell
        popupContentController!.popupItem.image = cell?.thumbnailImage.image
        
        AppInstance.instance.popupPlayPauseSong = false
        SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
        self.addToRecentlyWatched(trackId: object.id ?? 0)
        
        tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
            
            self.popupContentController?.musicObject = musicObject
            self.popupContentController!.musicArray = self.albumSongMusicArray
            self.popupContentController!.currentAudioIndex = 0
            self.popupContentController?.setup()
            
            
        })
    }
    @IBAction func morePressed(_ sender: Any) {
        
        if AppInstance.instance.getUserSession(){
            if AppInstance.instance.userId == self.userID ?? 0 {
                self.showMoreAlert()
            }else{
                self.showMoreAlertforNonSameUser()
            }
        }else{
            notLoggedInAlert()
        }
        
    }
    private func setupUI(){
        
        if albumObject != nil{
            self.title = albumObject?.title ?? ""
            self.nameLabel.text = albumObject?.publisher?.name  ?? albumObject?.publisher?.username ?? ""
            self.albumNameLabel.text = albumObject?.title ?? ""
            let profileURL = URL.init(string:albumObject?.publisher?.avatar ?? "")
            let coverURL = URL.init(string:albumObject?.thumbnail ?? "")
            if albumObject?.price == 0.0{
                self.playBtn.isHidden = false
                self.isPurchase = false
                
            }else{
                self.playBtn.isHidden = true
                self.isPurchase = true
            }
            
            profileImage.sd_setImage(with: profileURL , placeholderImage:R.image.imagePlacholder())
            coverImage.sd_setImage(with: coverURL , placeholderImage:R.image.imagePlacholder())
            thumbnailImage.sd_setImage(with: coverURL , placeholderImage:R.image.imagePlacholder())
            self.userID = albumObject?.publisher?.id ?? 0
            self.albumID = albumObject?.id ?? 0
            self.AlbumURL = albumObject?.url ?? ""
            self.price = self.albumObject?.price ?? 0.0
            self.albumIDSting = self.albumObject?.albumID ?? ""
            
            
        }else if searchAlbumObject != nil{
            
            self.title = searchAlbumObject?.title ?? ""
            self.nameLabel.text = searchAlbumObject?.publisher?.name ?? searchAlbumObject?.publisher?.username ?? ""
            self.albumNameLabel.text = searchAlbumObject?.title ?? ""
            let profileURL = URL.init(string:searchAlbumObject?.publisher?.avatar ?? "")
            let coverURL = URL.init(string:searchAlbumObject?.thumbnail ?? "")
            profileImage.sd_setImage(with: profileURL , placeholderImage:R.image.imagePlacholder())
            coverImage.sd_setImage(with: coverURL , placeholderImage:R.image.imagePlacholder())
            thumbnailImage.sd_setImage(with: coverURL , placeholderImage:R.image.imagePlacholder())
            
            self.userID = searchAlbumObject?.publisher?.id ?? 0
            self.albumID = searchAlbumObject?.id ?? 0
            self.AlbumURL = searchAlbumObject?.url ?? ""
            self.price = self.searchAlbumObject?.price ?? 0.0
            self.albumIDSting = self.searchAlbumObject?.albumID ?? ""
            if searchAlbumObject?.price == 0.0{
                self.playBtn.isHidden = false
                self.isPurchase = false
                
            }else{
                self.playBtn.isHidden = true
                self.isPurchase = true
                
                
            }
            
            
            
        }else if profileAlbumObject != nil{
            self.title = profileAlbumObject?.title ?? ""
            self.albumNameLabel.text =  profileAlbumObject?.title ?? ""
            
            let profileURL = URL.init(string:profileAlbumObject?.publisher?.avatar ?? searchAlbumObject?.publisher?.avatar ?? "")
            let coverURL = URL.init(string: profileAlbumObject?.thumbnail ?? "")
            
            profileImage.sd_setImage(with: profileURL , placeholderImage:R.image.imagePlacholder())
            coverImage.sd_setImage(with: coverURL , placeholderImage:R.image.imagePlacholder())
            thumbnailImage.sd_setImage(with: coverURL , placeholderImage:R.image.imagePlacholder())
            
            self.userID = profileAlbumObject?.publisher?.id ?? 0
            self.albumID = profileAlbumObject?.id ?? 0
            self.AlbumURL = profileAlbumObject?.url ?? ""
            self.price = self.profileAlbumObject?.price ?? 0.0
            self.albumIDSting = self.profileAlbumObject?.albumID ?? ""
            if profileAlbumObject?.price == 0.0{
                self.playBtn.isHidden = false
                self.isPurchase = false
                
            }else{
                self.playBtn.isHidden = true
                self.isPurchase = true
                
                
            }
            
        }
        
        self.tableView.separatorStyle = .none
        tableView.register(R.nib.browseAlbumsTableCell(), forCellReuseIdentifier: R.reuseIdentifier.browseAlbums_TableCell.identifier)
        tableView.register(R.nib.noDataTableItem(), forCellReuseIdentifier: R.reuseIdentifier.noDataTableItem.identifier)
        tableView.register(R.nib.noDataTableItem(), forCellReuseIdentifier:
            R.reuseIdentifier.noDataTableItem.identifier)
        tableView.register(R.nib.purchaseButtonTableItem(), forCellReuseIdentifier:
            R.reuseIdentifier.purchaseButtonTableItem.identifier)
        
    }
    private func fetchAlbumtSongs(){
        if Connectivity.isConnectedToNetwork(){
            self.albumSongsArray.removeAll()
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: ""))
            let accessToken = AppInstance.instance.accessToken ?? ""
            let albumId = self.albumID ?? 0
            Async.background({
                AlbumManager.instance.getAlbumSongs(albumId: albumId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                log.debug("userList = \(success?.songs ?? [])")
                                self.albumSongsArray = success?.songs ?? []
                                if self.albumSongsArray.count == 0{
                                    self.playBtn.isHidden = true
                                }else{
                                    if self.isPurchase ?? false{
                                        self.playBtn.isHidden = true
                                    }else{
                                        self.playBtn.isHidden = false
                                    }
                                }
                                
                                self.tableView.reloadData()
                                self.scrolHeight.constant = self.scrolHeight.constant + self.tableView.contentSize.height - 20.0
                                self.songsCountLabel.text = "\(self.albumSongsArray.count) Songs"
                            }
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast(NSLocalizedString(sessionError?.error ?? "", comment: ""))
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                })
            })
            
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(NSLocalizedString(InterNetError, comment: ""))
        }
    }
    func showMoreAlert(){
        let alert = UIAlertController(title: (NSLocalizedString("Album", comment: "")), message: "", preferredStyle: .actionSheet)
        let deleteAlbum = UIAlertAction(title: (NSLocalizedString("Delete Album", comment: "")), style: .default) { (action) in
            if self.albumObject != nil{
                self.deleteTrack(albumID: self.albumObject?.id ?? 0)
            } else if   self.searchAlbumObject != nil{
                self.deleteTrack(albumID: self.searchAlbumObject?.id ?? 0)
            }else if self.profileAlbumObject != nil{
                self.deleteTrack(albumID: self.profileAlbumObject?.id ?? 0)
            }
            
            log.verbose("Delete Song")
        }
        let EditAlbum = UIAlertAction(title: (NSLocalizedString("Edit Album", comment: "")), style: .default) { (action) in
            log.verbose("Edit Song")
            let vc = R.storyboard.album.uploadAlbumVC()
            if self.albumObject != nil{
                
                let object = UpdateAlbumModel(AlbumID: self.albumObject?.albumID ?? "", userID: self.albumObject?.publisher?.id ?? 0, title: self.albumObject?.title ?? "", description: self.albumObject?.topAlbumDescription ?? "", imageString: self.albumObject?.thumbnail ?? "", genre: self.albumObject?.categoryName ?? "", price: self.albumObject?.price ?? 0.0)
                vc?.albumObject = object
                
            }else if   self.searchAlbumObject != nil{
                let object = UpdateAlbumModel(AlbumID: self.searchAlbumObject?.albumID ?? "", userID: self.searchAlbumObject?.publisher?.id ?? 0, title: self.searchAlbumObject?.title ?? "", description: self.searchAlbumObject?.albumDescription ?? "", imageString: self.searchAlbumObject?.thumbnail ?? "", genre: self.searchAlbumObject?.categoryName ?? "", price: 0.0)
                vc?.albumObject = object
            }else if self.profileAlbumObject != nil{
                let object = UpdateAlbumModel(AlbumID: self.profileAlbumObject?.albumID ?? "", userID: self.profileAlbumObject?.publisher?.id ?? 0, title: self.profileAlbumObject?.title ?? "", description: self.profileAlbumObject?.albumDescription ?? "", imageString: self.profileAlbumObject?.thumbnail ?? "", genre: self.profileAlbumObject?.categoryName ?? "", price: 0.0)
                vc?.albumObject = object
                
            }
            self.navigationController?.pushViewController(vc!, animated: true)
            
        }
        
        let ShareAlbum = UIAlertAction(title: (NSLocalizedString("Share", comment: "")), style: .default) { (action) in
            log.verbose("Share")
            self.share(shareString: self.AlbumURL ?? "")
        }
        let CopyAlbum = UIAlertAction(title: (NSLocalizedString("Copy", comment: "")), style: .default) { (action) in
            UIPasteboard.general.string = self.AlbumURL ?? ""
            self.view.makeToast(NSLocalizedString(("Text copy to clipboad"), comment: ""))
            
        }
        let cancel = UIAlertAction(title: (NSLocalizedString(
        "Cancel", comment: "")), style: .destructive, handler: nil)
        
        alert.addAction(deleteAlbum)
        alert.addAction(EditAlbum)
        alert.addAction(ShareAlbum)
        alert.addAction(CopyAlbum)
        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: nil)
        
        
    }
    func showMoreAlertforNonSameUser(){
        let alert = UIAlertController(title: (NSLocalizedString(
        "Album", comment: "")), message: "", preferredStyle: .actionSheet)
        
        let share = UIAlertAction(title: (NSLocalizedString(
        "Share", comment: "")), style: .default) { (action) in
            self.share(shareString: self.AlbumURL ?? "")
            
        }
        let CopyAlbum = UIAlertAction(title: "Copy", style: .default) { (action) in
            UIPasteboard.general.string = self.AlbumURL ?? ""
            self.view.makeToast(NSLocalizedString(("Text copy to clipboad"), comment: ""))
        }
        let cancel = UIAlertAction(title: (NSLocalizedString("Cancel", comment: "")), style: .destructive, handler: nil)
        
        alert.addAction(share)
        alert.addAction(CopyAlbum)
        alert.addAction(cancel)
         alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: nil)
    }
    func notLoggedInAlert(){
        let alert = UIAlertController(title: (NSLocalizedString(
        "Album", comment: "")), message: "", preferredStyle: .actionSheet)
        
        let CopyAlbum = UIAlertAction(title: (NSLocalizedString(
        "Copy", comment: "")), style: .default) { (action) in
            UIPasteboard.general.string = self.AlbumURL ?? ""
            self.view.makeToast(NSLocalizedString(("Text copy to clipboad"), comment: ""))
            
        }
        let cancel = UIAlertAction(title: (NSLocalizedString("Cancel", comment: "")), style: .destructive, handler: nil)
        
        alert.addAction(CopyAlbum)
        alert.addAction(cancel)
         alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: nil)
        
    }
    private func deleteTrack(albumID:Int){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                AlbumManager.instance.deleteAlbum(albumId: albumID, AccessToken: accessToken, type: "single") { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.status ?? 0)")
                                self.navigationController?.popViewController(animated: true)
                            }
                            
                            
                        })
                        
                    }else if sessionError != nil{
                        
                        Async.main({
                            
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(NSLocalizedString(sessionError?.error ?? "", comment: ""))
                            }
                            
                            
                        })
                    }else {
                        Async.main({
                            
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(NSLocalizedString(error?.localizedDescription ?? "", comment: ""))
                            }
                            
                        })
                    }
                }
            })
        }else{
            
            self.dismissProgressDialog {
                log.error("internetErrro = \(InterNetError)")
                self.view.makeToast(NSLocalizedString(InterNetError, comment: ""))
            }
            
        }
    }
    private func share(shareString:String?){
        // text to share
        let text = shareString ?? ""
        
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
}


extension ShowAlbumVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.userID == AppInstance.instance.userId ?? 0 {
            if self.albumSongsArray.count == 0{
                return 1
            }else{
                return self.albumSongsArray.count
            }
        }else{
            if self.price == 0.0 {
                if self.albumSongsArray.count == 0{
                    return 1
                }else{
                    return self.albumSongsArray.count
                }
            }else{
                return 1
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.userID == AppInstance.instance.userId ?? 0{
            if self.albumSongsArray.isEmpty{
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noDataTableItem.identifier) as? NoDataTableItem
                return cell!
                
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.browseAlbums_TableCell.identifier) as? BrowseAlbums_TableCell
                
                cell?.albumVC = self
                cell?.likeDelegate = self
                cell?.indexPath = indexPath.row
                let object = self.albumSongsArray[indexPath.row]
                cell?.bind(object, index: indexPath.row)
                return cell!
            }
            
        }else{
            if self.price == 0.0{
                
                if self.albumSongsArray.isEmpty{
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noDataTableItem.identifier) as? NoDataTableItem
                    return cell!
                    
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.browseAlbums_TableCell.identifier) as? BrowseAlbums_TableCell
                    
                    cell?.albumVC = self
                    cell?.likeDelegate = self
                    cell?.indexPath = indexPath.row
                    let object = self.albumSongsArray[indexPath.row]
                    cell?.bind(object, index: indexPath.row)
                    return cell!
                }
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.purchaseButtonTableItem.identifier) as? PurchaseButtonTableItem
                cell!.vc = self
                cell?.price = self.price
                cell?.albumID = self.albumIDSting ?? ""
                return cell!
                
            }
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                if AppInstance.instance.addCount == ControlSettings.interestialCount {
                    interstitial.present(fromRootViewController: self)
                        interstitial = CreateAd()
                        AppInstance.instance.addCount = 0
                }
        AppInstance.instance.addCount =  AppInstance.instance.addCount! + 1
        AppInstance.instance.player = nil
             AppInstance.instance.AlreadyPlayed = false
        
        if self.userID == AppInstance.instance.userId ?? 0{
                   if self.albumSongsArray.isEmpty{
                    log.verbose("nothing")
                   }else{
                    
                           let object = self.albumSongsArray[indexPath.row]
                           
                           self.albumSongsArray.forEach({ (it) in
                               var audioString:String? = ""
                               var isDemo:Bool? = false
                               let name = it.publisher?.name ?? ""
                               let time = it.timeFormatted ?? ""
                               let title = it.title ?? ""
                               let musicType = it.categoryName ?? ""
                               let thumbnailImageString = it.thumbnail ?? ""
                               
                               if it.demoTrack == ""{
                                   audioString = it.audioLocation ?? ""
                                   isDemo = false
                               }else if it.demoTrack != "" && it.audioLocation != ""{
                                   audioString = it.audioLocation ?? ""
                                   isDemo = false
                               }else{
                                   audioString = it.demoTrack ?? ""
                                   isDemo = true
                               }
                               let isOwner = it.isOwner ?? false
                               let audioId = it.audioID ?? ""
                               let likeCount = it.countLikes?.intValue ?? 0
                               let favoriteCount = it.countFavorite?.intValue ?? 0
                               let recentlyPlayedCount = it.countViews?.intValue ?? 0
                               let sharedCount = it.countShares?.intValue ?? 0
                               let commentCount = it.countComment?.intValue ?? 0
                               let trackId = it.id ?? 0
                               let isLiked = it.isLiked ?? false
                               let isFavorited = it.isFavoriated ?? false
                               let likecountString = it.countLikes?.stringValue ?? ""
                               let favoriteCountString = it.countFavorite?.stringValue ?? ""
                               let recentlyPlayedCountString = it.countViews?.stringValue ?? ""
                               let sharedCountString = it.countShares?.stringValue ?? ""
                               let commentCountString = it.countComment?.stringValue ?? ""
                               
                               let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
                               self.albumSongMusicArray.append(musicObject)
                           })
                           var audioString:String? = ""
                           var isDemo:Bool? = false
                           let name = object.publisher?.name ?? ""
                           let time = object.timeFormatted ?? ""
                           let title = object.title ?? ""
                           let musicType = object.categoryName ?? ""
                           let thumbnailImageString = object.thumbnail ?? ""
                           if object.demoTrack == ""{
                               audioString = object.audioLocation ?? ""
                               isDemo = false
                           }else if object.demoTrack != "" && object.audioLocation != ""{
                               audioString = object.audioLocation ?? ""
                               isDemo = false
                           }else{
                               audioString = object.demoTrack ?? ""
                               isDemo = true
                           }
                           let isOwner = object.isOwner ?? false
                           let audioId = object.audioID ?? ""
                           let likeCount = object.countLikes?.intValue ?? 0
                           let favoriteCount = object.countFavorite?.intValue ?? 0
                           let recentlyPlayedCount = object.countViews?.intValue ?? 0
                           let sharedCount = object.countShares?.intValue ?? 0
                           let commentCount = object.countComment?.intValue ?? 0
                           let trackId = object.id ?? 0
                           let isLiked = object.isLiked ?? false
                           let isFavorited = object.isFavoriated ?? false
                           
                           let likecountString = object.countLikes?.stringValue ?? ""
                           let favoriteCountString = object.countFavorite?.stringValue ?? ""
                           let recentlyPlayedCountString = object.countViews?.stringValue ?? ""
                           let sharedCountString = object.countShares?.stringValue ?? ""
                           let commentCountString = object.countComment?.stringValue ?? ""
                           
                           let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
                           popupContentController!.popupItem.title = object.publisher?.name ?? ""
                           popupContentController!.popupItem.subtitle = object.title?.htmlAttributedString ?? ""
                           let cell  = tableView.cellForRow(at: indexPath) as? BrowseAlbums_TableCell
                           popupContentController!.popupItem.image = cell?.thumbnailImage.image
                           AppInstance.instance.popupPlayPauseSong = false
                           SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
                           self.addToRecentlyWatched(trackId: object.id ?? 0)
                           
                           
                           tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                               
                               self.popupContentController?.musicObject = musicObject
                               self.popupContentController!.musicArray = self.albumSongMusicArray
                               self.popupContentController!.currentAudioIndex = indexPath.row
                               self.popupContentController?.setup()
                               
                           })
                   }
                   
               }else{
                   if self.price == 0.0{
                       
                       if self.albumSongsArray.isEmpty{
                        log.verbose("Nothing")
                           
                       }else{
                                  let object = self.albumSongsArray[indexPath.row]
                                  
                                  self.albumSongsArray.forEach({ (it) in
                                      var audioString:String? = ""
                                      var isDemo:Bool? = false
                                      let name = it.publisher?.name ?? ""
                                      let time = it.timeFormatted ?? ""
                                      let title = it.title ?? ""
                                      let musicType = it.categoryName ?? ""
                                      let thumbnailImageString = it.thumbnail ?? ""
                                      
                                      if it.demoTrack == ""{
                                          audioString = it.audioLocation ?? ""
                                          isDemo = false
                                      }else if it.demoTrack != "" && it.audioLocation != ""{
                                          audioString = it.audioLocation ?? ""
                                          isDemo = false
                                      }else{
                                          audioString = it.demoTrack ?? ""
                                          isDemo = true
                                      }
                                      let isOwner = it.isOwner ?? false
                                      let audioId = it.audioID ?? ""
                                      let likeCount = it.countLikes?.intValue ?? 0
                                      let favoriteCount = it.countFavorite?.intValue ?? 0
                                      let recentlyPlayedCount = it.countViews?.intValue ?? 0
                                      let sharedCount = it.countShares?.intValue ?? 0
                                      let commentCount = it.countComment?.intValue ?? 0
                                      let trackId = it.id ?? 0
                                      let isLiked = it.isLiked ?? false
                                      let isFavorited = it.isFavoriated ?? false
                                      let likecountString = it.countLikes?.stringValue ?? ""
                                      let favoriteCountString = it.countFavorite?.stringValue ?? ""
                                      let recentlyPlayedCountString = it.countViews?.stringValue ?? ""
                                      let sharedCountString = it.countShares?.stringValue ?? ""
                                      let commentCountString = it.countComment?.stringValue ?? ""
                                      
                                      let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
                                      self.albumSongMusicArray.append(musicObject)
                                  })
                                  var audioString:String? = ""
                                  var isDemo:Bool? = false
                                  let name = object.publisher?.name ?? ""
                                  let time = object.timeFormatted ?? ""
                                  let title = object.title ?? ""
                                  let musicType = object.categoryName ?? ""
                                  let thumbnailImageString = object.thumbnail ?? ""
                                  if object.demoTrack == ""{
                                      audioString = object.audioLocation ?? ""
                                      isDemo = false
                                  }else if object.demoTrack != "" && object.audioLocation != ""{
                                      audioString = object.audioLocation ?? ""
                                      isDemo = false
                                  }else{
                                      audioString = object.demoTrack ?? ""
                                      isDemo = true
                                  }
                                  let isOwner = object.isOwner ?? false
                                  let audioId = object.audioID ?? ""
                                  let likeCount = object.countLikes?.intValue ?? 0
                                  let favoriteCount = object.countFavorite?.intValue ?? 0
                                  let recentlyPlayedCount = object.countViews?.intValue ?? 0
                                  let sharedCount = object.countShares?.intValue ?? 0
                                  let commentCount = object.countComment?.intValue ?? 0
                                  let trackId = object.id ?? 0
                                  let isLiked = object.isLiked ?? false
                                  let isFavorited = object.isFavoriated ?? false
                                  
                                  let likecountString = object.countLikes?.stringValue ?? ""
                                  let favoriteCountString = object.countFavorite?.stringValue ?? ""
                                  let recentlyPlayedCountString = object.countViews?.stringValue ?? ""
                                  let sharedCountString = object.countShares?.stringValue ?? ""
                                  let commentCountString = object.countComment?.stringValue ?? ""
                                  
                                  let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
                                  popupContentController!.popupItem.title = object.publisher?.name ?? ""
                                  popupContentController!.popupItem.subtitle = object.title?.htmlAttributedString ?? ""
                                  let cell  = tableView.cellForRow(at: indexPath) as? BrowseAlbums_TableCell
                                  popupContentController!.popupItem.image = cell?.thumbnailImage.image
                                  AppInstance.instance.popupPlayPauseSong = false
                                  SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
                                  self.addToRecentlyWatched(trackId: object.id ?? 0)
                                  
                                  
                                  tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                                      
                                      self.popupContentController?.musicObject = musicObject
                                      self.popupContentController!.musicArray = self.albumSongMusicArray
                                      self.popupContentController!.currentAudioIndex = indexPath.row
                                      self.popupContentController?.setup()
                                      
                                  })
                       }
                   }else{
                    log.verbose("Nothing")
                       
                   }
               }
       
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.price == 0.0{
            if albumSongsArray.isEmpty{
                return 300.0
            }else{
                return 90.0
            }
        }else{
            return 400.0
        }
    }
}


extension ShowAlbumVC:likeDislikeSongDelegate{
    
    func likeDisLikeSong(status: Bool, button: UIButton,audioId:String) {
        
        if status{
            button.setImage(R.image.ic_outlineHeart(), for: .normal)
            self.likeDislike(audioId: audioId, button: button)
        }else{
            button.setImage(R.image.ic_redHeart(), for: .normal)
            self.likeDislike(audioId: audioId, button: button)
        }
    }
    
    private func likeDislike(audioId:String,button:UIButton){
        if Connectivity.isConnectedToNetwork(){
            let accessToken = AppInstance.instance.accessToken ?? ""
            let audioId = audioId ?? ""
            Async.background({
                likeManager.instance.likeDisLikeSong(audiotId: audioId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.mode ?? "")")
                                if success?.mode == "disliked"{
                                    button.setImage(R.image.ic_outlineHeart(), for: .normal)
                                }else{
                                    button.setImage(R.image.ic_redHeart(), for: .normal)
                                }
                            }
                        })
                        
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(NSLocalizedString((sessionError?.error ?? ""), comment: ""))
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(NSLocalizedString((error?.localizedDescription ?? ""), comment: ""))
                            }
                        })
                    }
                })
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(NSLocalizedString(InterNetError, comment: ""))
        }
    }
}

