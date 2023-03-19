//
//  Dashboard1VC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/19/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
import MediaPlayer
class Dashboard1VC: BaseVC {
    
    @IBOutlet weak var titleLabel: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    private var latestSongsArray:DiscoverModel.NewReleases?
    private var recentlyPlayedArray:DiscoverModel.RecentlyplayedUnion?
    private var mostPopularArray:DiscoverModel.PopularWeekUnion?
    private var slideShowArray:DiscoverModel.Randoms?
    private var genresArray = [GenresModel.Datum]()
    private var artistArray = [ArtistModel.Datum]()
    private var productsArray = [[String:Any]]()
    private var refreshControl = UIRefreshControl()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.titleLabel.title = (NSLocalizedString("Discover", comment: ""))
        self.fetchDiscover()
        SwiftEventBus.onMainThread(self, name:   EventBusConstants.EventBusConstantsUtils.EVENT_DISMISS_POPOVER) { result in
            AppInstance.instance.player = nil
            self.tabBarController?.dismissPopupBar(animated: true, completion: nil)
        }
        
    }
    func setupUI(){
        self.tableView.separatorStyle = .none
        self.tableView.register(R.nib.sectionHeaderTableItem(), forCellReuseIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier)
        self.tableView.register(R.nib.dashboardSectionOneTableItem(), forCellReuseIdentifier: R.reuseIdentifier.dashboardSectionOneTableItem.identifier)
        self.tableView.register(R.nib.dashboardSectionTwoTableItem(), forCellReuseIdentifier: R.reuseIdentifier.dashboardSectionTwoTableItem.identifier)
        self.tableView.register(R.nib.dashboardSectionThreeTableItem(), forCellReuseIdentifier: R.reuseIdentifier.dashboardSectionThreeTableItem.identifier)
        self.tableView.register(R.nib.dashboardSectionFourTableItem(), forCellReuseIdentifier: R.reuseIdentifier.dashboardSectionFourTableItem.identifier)
        self.tableView.register(R.nib.dashboardSectionFiveTableItem(), forCellReuseIdentifier: R.reuseIdentifier.dashboardSectionFiveTableItem.identifier)
        self.tableView.register(R.nib.dashBoardSectionSixTableItem(), forCellReuseIdentifier: R.reuseIdentifier.dashBoardSectionSixTableItem.identifier)
        
        self.tableView.register(UINib(nibName: "ProductsCollectionTableCell", bundle: nil), forCellReuseIdentifier: "ProductsCollectionTableCell")
        
             refreshControl.attributedTitle = NSAttributedString(string: (NSLocalizedString("Pull to refresh", comment: "")))
         refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    @objc func refresh(sender:AnyObject) {
           self.latestSongsArray?.data?.removeAll()

           self.slideShowArray?.recommended?.removeAll()
           self.artistArray.removeAll()
           self.genresArray.removeAll()
           self.tableView.reloadData()
           self.fetchDiscover()
           refreshControl.endRefreshing()
       }
    @IBAction func notificationPressed(_ sender: Any) {
        let vc = R.storyboard.notfication.notificationVC()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func searchPressed(_ sender: Any) {
        let vc = R.storyboard.search.searchParentVC()
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: .none, message: .none, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Upload single song", style: .default , handler:{ (UIAlertAction)in
                let mediaPicker = MPMediaPickerController(mediaTypes: .music)
                mediaPicker.delegate = self
                mediaPicker.allowsPickingMultipleItems = false
                self.present(mediaPicker, animated: true, completion: nil)
                print("uploadAlbumVC button")
            }))
        alert.addAction(UIAlertAction(title: "Import Song", style: .default , handler:{ (UIAlertAction)in
            let vc = R.storyboard.track.importURLVC()
            self.navigationController?.pushViewController(vc!, animated: true)
            print("User click Delete button")
        }))
            
            alert.addAction(UIAlertAction(title: "Create Album", style: .default , handler:{ (UIAlertAction)in
                let vc = R.storyboard.album.uploadAlbumVC()
                self.navigationController?.pushViewController(vc!, animated: true)

                print("Upload Album button")
            }))

           
        alert.addAction(UIAlertAction(title: "Create Playlist", style: .default , handler:{ (UIAlertAction)in
            let vc = R.storyboard.playlist.createPlaylistVC()
            self.present(vc!, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Create Station", style: .default , handler:{ (UIAlertAction)in
            let vc = R.storyboard.stations.stationsFullVC()
            self.navigationController?.pushViewController(vc!, animated: true)
           
            print("User click Delete button")
        }))
        if AppInstance.instance.userProfile?.data?.artist == 0{
            print("no create event and product")
            
        }else{
            alert.addAction(UIAlertAction(title: "Create Event", style: .default , handler:{ (UIAlertAction)in
                let vc = R.storyboard.events.createEventVC()
                self.navigationController?.pushViewController(vc!, animated: true)
               
               
            }))
            alert.addAction(UIAlertAction(title: "Create Product", style: .default , handler:{ (UIAlertAction)in
                let vc = R.storyboard.products.createProductVC()
                self.navigationController?.pushViewController(vc!, animated: true)
               
           
            }))
        }
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
                print("Import button clicked")
            }))

        
            
            //uncomment for iPad Support
            //alert.popoverPresentationController?.sourceView = self.view

            self.present(alert, animated: true, completion: {
                print("completion block")
            })
        
    }
    @IBAction func CartPressed(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CartVC") as! CartVC
        navigationController?.pushViewController(vc, animated: true)
        print("Navigation to CartVC")
    }
    
    private func fetchDiscover(){
        if Connectivity.isConnectedToNetwork(){
            self.latestSongsArray?.data?.removeAll()
//            self.recentlyPlayedArray?.newRelease?.data?.removeAll()
//            self.mostPopularArray?. ?.removeAll()
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                DiscoverManager.instance.getDiscover(AccessToken: accessToken, completionBlock: { (success,NotDiscovered, sessionError, error) in
                    if success != nil{
                        Async.main({
                            
                            log.debug("userList = \(success?.status ?? 0)")
                            self.latestSongsArray = success?.newReleases ?? nil
                            AppInstance.instance.latestSong = success?.newReleases?.data ?? []
                            if ((success?.recentlyPlayed?.emptyArray?.isEmpty) == true){
                            }else{
                                self.recentlyPlayedArray = success?.recentlyPlayed ?? nil
                            }
                           
                            self.mostPopularArray = success?.mostPopularWeek ?? nil
                            self.slideShowArray = success?.randoms ?? nil
                            self.tableView.reloadData()
                            self.fetchGenres()
                            
                            
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                
                                self.view.makeToast((NSLocalizedString(sessionError?.error ?? "", comment: "")))
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                })
            })
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast((NSLocalizedString(InterNetError, comment: "")))
        }
        
    }
    private func fetchGenres(){
        self.genresArray.removeAll()
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            GenresManager.instance.getGenres(AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        
                        self.genresArray = success?.data ?? []
                        self.tableView.reloadData()
                        self.fetchArtist()
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            self.view.makeToast((NSLocalizedString(sessionError?.error ?? "", comment: "")))
                            log.error("sessionError = \(sessionError?.error ?? "")")
                        }
                    })
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    })
                }
            })
        })
    }
    private func fetchArtist(){
        self.artistArray.removeAll()
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            ArtistManager.instance.getDiscover(AccessToken: accessToken, Limit: 10, Offset: 0, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            self.artistArray = success?.data?.data ?? []
                            self.tableView.reloadData()
                            self.getProducts()
                          
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            self.view.makeToast((NSLocalizedString(sessionError?.error ?? "", comment: "")))
                            log.error("sessionError = \(sessionError?.error ?? "")")
                        }
                    })
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            
                            self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    })
                }
            })
        })
    }
    private func getProducts(){
        self.productsArray.removeAll()
        let accessToken = AppInstance.instance.accessToken ?? ""
        Async.background({
            ProductManager.instance.getProducts(AccessToken: accessToken, priceTo: 0, priceFrom: 0, category: "") { success, sessionError, error in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            self.productsArray = success ?? []
                            self.tableView.reloadData()
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            self.view.makeToast((NSLocalizedString(sessionError ?? "", comment: "")))
                            log.error("sessionError = \(sessionError ?? "")")
                        }
                    })
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            
                            self.view.makeToast((NSLocalizedString(error?.localizedDescription ?? "", comment: "")))
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    })
                }
            }
        })
    }
}
extension Dashboard1VC:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 13
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 1
        case 4:
            return 1
        case 5:
            return 1
        case 6:
            return 1
        case 7:
            return 1
        case 8:
            return 1
        case 9:
            return 1
        case 10:
            return 1
        case 11:
            return 1
        case 12:
            return 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardSectionOneTableItem.identifier) as? DashboardSectionOneTableItem
            cell?.bind(slideShowArray ?? nil)
            cell?.loggedInVC = self
            cell?.selectionStyle = .none
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as? SectionHeaderTableItem
            cell?.selectionStyle = .none
            cell?.titleLabel.text = (NSLocalizedString("Genres", comment: ""))
            return cell!
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardSectionTwoTableItem.identifier) as? DashboardSectionTwoTableItem
            cell?.loggedInVC = self
            cell?.selectionStyle = .none
            
            cell?.bind(genresArray)
            return cell!
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as? SectionHeaderTableItem
            cell?.selectionStyle = .none
            
            cell?.titleLabel.text = (NSLocalizedString("Latest Songs", comment: ""))
            return cell!
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardSectionThreeTableItem.identifier) as? DashboardSectionThreeTableItem
            cell?.loggedInVC = self
            cell?.selectionStyle = .none
            
            cell?.bind(latestSongsArray ?? nil)
            return cell!
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as? SectionHeaderTableItem
            cell?.selectionStyle = .none
            
            cell?.titleLabel.text = (NSLocalizedString("Recently Played", comment: ""))
            return cell!
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardSectionFourTableItem.identifier) as? DashboardSectionFourTableItem
            cell?.selectionStyle = .none
            cell?.loggedInVC = self
            cell?.bind(recentlyPlayedArray?.newRelease ?? nil)
            return cell!
            
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as? SectionHeaderTableItem
            cell?.selectionStyle = .none
            
            cell?.titleLabel.text = (NSLocalizedString("Popular", comment: ""))
            return cell!
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardSectionFiveTableItem.identifier) as? DashboardSectionFiveTableItem
            cell?.loggedInVC = self
            cell?.selectionStyle = .none
            
            cell?.bind(mostPopularArray?.newRelease ?? nil)
            return cell!
        
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as? SectionHeaderTableItem
            cell?.selectionStyle = .none
            
            cell?.titleLabel.text = (NSLocalizedString("Artist", comment: ""))
            return cell!
        case 10:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashBoardSectionSixTableItem.identifier) as? DashBoardSectionSixTableItem
            cell?.loggedHomeVC = self
            cell?.selectionStyle = .none
            cell?.bind(artistArray)
            return cell!
        case 11:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as? SectionHeaderTableItem
            cell?.selectionStyle = .none
            
            cell?.titleLabel.text = (NSLocalizedString("Products", comment: ""))
            return cell!
        case 12:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductsCollectionTableCell") as? ProductsCollectionTableCell
            cell?.vc = self
           // cell?.loggedInVC = self
          //  cell?.selectionStyle = .none
            
            cell?.bind(self.productsArray ?? [])
            return cell!
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          switch indexPath.section {
       
          case 3:
              let vc = R.storyboard.discover.latestSongsVC()
              vc!.latestSongsArray = self.latestSongsArray ?? nil
              self.navigationController?.pushViewController(vc!, animated: true)
            case 5:
                
                let vc = R.storyboard.discover.dashboardRecentlyPlayedVC()
                vc!.recentlyPlayedArray = self.recentlyPlayedArray?.newRelease ?? nil
                self.navigationController?.pushViewController(vc!, animated: true)
          case 7:
              
              let vc = R.storyboard.discover.popularVC()
            vc!.popularArray = self.mostPopularArray?.newRelease ?? nil
              self.navigationController?.pushViewController(vc!, animated: true)
          case 11:
            let story = UIStoryboard(name: "Products", bundle: nil)
            let vc = story.instantiateViewController(identifier: "DiscoverProductsVC") as! DiscoverProductsVC
            
            self.navigationController?.pushViewController(vc, animated: true)
          case 9:
              let vc = R.storyboard.discover.artistVC()
//              vc!.artistArray = self.artistArray ?? []
              self.navigationController?.pushViewController(vc!, animated: true)
          default:
              log.verbose("Nothing to select")
          }
      }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if ((slideShowArray?.recommended?.count) == 0){
                return 0
            }else{
                return 300
            }
        case 1:
            if ((genresArray.count) == 0){
                return 0
            }else{
                return UITableView.automaticDimension
            }
        case 2:
            if ((genresArray.count) == 0){
                return 0
            }else{
                return 200
            }
          
        case 3:
            if ((latestSongsArray?.data?.count) == 0){
                return 0
            }else{
                return UITableView.automaticDimension
            }
        case 4:
            if ((latestSongsArray?.data?.count) == 0){
                return 0
            }else{
                return 280
            }
            
        case 5:
            if ((recentlyPlayedArray?.newRelease?.data?.count) == 0){
                return 0
            }else{
                return UITableView.automaticDimension
            }
            
        case 6:
            if ((recentlyPlayedArray?.newRelease?.data?.count) == 0){
                return 0
            }else{
                return 280
            }
            
        case 7:
            if ((mostPopularArray?.newRelease?.data?.count) == 0){
                return 0
            }else{
                return UITableView.automaticDimension
            }
          
        case 8:
            if ((mostPopularArray?.newRelease?.data?.count) == 0){
                return 0
            }else{
                return 280
            }
        case 11:
            if ((self.productsArray.count) == 0){
                return 0
            }else{
                return UITableView.automaticDimension
            }
          
        case 12:
            if ((self.productsArray.count) == 0){
                return 0
            }else{
                return 350
            }
        case 9:
            if ((artistArray.isEmpty) == nil){
                return 0
            }else{
                return UITableView.automaticDimension
            }
           
        case 10:
            if ((artistArray.isEmpty) == nil){
                return 0
            }else{
                return 280
            }
           
        default:
            return 280
        }
    }
    
    
}
extension Dashboard1VC:MPMediaPickerControllerDelegate{
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        guard let mediaItem = mediaItemCollection.items.first else{
            NSLog("No item selected.")
            return
        }
        let songUrl = mediaItem.value(forProperty: MPMediaItemPropertyAssetURL) as! URL
        print(songUrl)
        // get file extension andmime type
        let str = songUrl.absoluteString
        let str2 = str.replacingOccurrences( of : "ipod-library://item/item", with: "")
        let arr = str2.components(separatedBy: "?")
        var mimeType = arr[0]
        mimeType = mimeType.replacingOccurrences( of : ".", with: "")
        
        let exportSession = AVAssetExportSession(asset: AVAsset(url: songUrl), presetName: AVAssetExportPresetAppleM4A)
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.outputFileType = AVFileType.m4a
        
        //save it into your local directory
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputURL = documentURL.appendingPathComponent(mediaItem.title!)
        print(outputURL.absoluteString)
        do
        {
            try FileManager.default.removeItem(at: outputURL)
        }
        catch let error as NSError
        {
            print(error.debugDescription)
        }
        exportSession?.outputURL = outputURL
        Async.background({
            exportSession?.exportAsynchronously(completionHandler: { () -> Void in
                
                if exportSession!.status == AVAssetExportSession.Status.completed
                {
                    print("Export Successfull")
                    let data = try! Data(contentsOf: outputURL)
                    log.verbose("Data = \(data)")
                  Async.main({
                    self.uploadTrack(TrackData: data)
                  })
                }
            })
        })
        
        self.dismiss(animated: true, completion: nil)
    }
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion: nil)
        print("User selected Cancel tell me what to do")
    }
    
    private func uploadTrack(TrackData:Data){
        self.showProgressDialog(text: "Loading...")
        let accessToken = AppInstance.instance.accessToken ?? ""
        if Connectivity.isConnectedToNetwork(){
            Async.background({
                TrackManager.instance.uploadTrack(AccesToken: accessToken, audoFile_data: TrackData, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.filePath ?? "")")
                                let vc = R.storyboard.track.uploadTrackVC()
                                self.navigationController?.pushViewController(vc!, animated: true)
                            }
                        })
                        
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.error ?? "")")
                                self.view.makeToast(sessionError?.error ?? "")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                        })
                    }
                })
            })
        }else{
            log.error("internetErrro = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
}
