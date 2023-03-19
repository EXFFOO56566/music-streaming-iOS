//
//  NotLoggedInHomeVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 3/3/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
class NotLoggedInHomeVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var latestSongsArray:DiscoverModel.NewReleases?
    private var recentlyPlayedArray:DiscoverModel.RecentlyplayedUnion?
    private var mostPopularArray:DiscoverModel.PopularWeekUnion?
    private var slideShowArray:DiscoverModel.Randoms?
    private var genresArray = [GenresModel.Datum]()
    private var artistArray = [ArtistModel.Datum]()
    private var refreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = (NSLocalizedString("Discover", comment: ""))
        self.setupUI()
        self.fetchDiscover()
        
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
        
        self.tableView.register(R.nib.noLoginTableItem(), forCellReuseIdentifier: R.reuseIdentifier.noLoginTableItem.identifier)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    @objc func refresh(sender:AnyObject) {
        self.latestSongsArray?.data?.removeAll()
        //        self.recentlyPlayedArray?.data?.removeAll()
        //        self.mostPopularArray?.data?.removeAll()
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
    
    private func fetchDiscover(){
        if Connectivity.isConnectedToNetwork(){
            self.latestSongsArray?.data?.removeAll()
            //            self.recentlyPlayedArray?.data?.removeAll()
            //            self.mostPopularArray?.data?.removeAll()
            self.showProgressDialog(text: "Loading...")
            
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                DiscoverManager.instance.getDiscover(AccessToken: accessToken, completionBlock: { (success,notLoggedInSuccess, sessionError, error) in
                    if success != nil{
                        
                        log.debug("userList = \(success?.status ?? 0)")
                        self.latestSongsArray = success?.newReleases ?? nil
                        self.recentlyPlayedArray = success?.recentlyPlayed ?? nil
                        self.mostPopularArray = success?.mostPopularWeek ?? nil
                        self.slideShowArray = success?.randoms ?? nil
                        self.fetchGenres()
                        
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(sessionError?.error ?? "")
                                log.error("sessionError = \(sessionError?.error ?? "")")
                            }
                        })
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                self.view.makeToast(error?.localizedDescription ?? "")
                                log.error("error = \(error?.localizedDescription ?? "")")
                            }
                        })
                    }
                })
            })
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
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
                        self.fetchArtist()
                        
                        
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            self.view.makeToast(sessionError?.error ?? "")
                            log.error("sessionError = \(sessionError?.error ?? "")")
                        }
                    })
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            
                            self.view.makeToast(error?.localizedDescription ?? "")
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
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog {
                            
                            self.view.makeToast(sessionError?.error ?? "")
                            log.error("sessionError = \(sessionError?.error ?? "")")
                        }
                    })
                }else {
                    Async.main({
                        self.dismissProgressDialog {
                            
                            self.view.makeToast(error?.localizedDescription ?? "")
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    })
                }
            })
        })
    }
    func loginAlert(){
        let alert = UIAlertController(title:NSLocalizedString("Login", comment: "Login") , message:NSLocalizedString("Please login to continue", comment: "Please login to continue"), preferredStyle: .alert)
        let login = UIAlertAction(title: NSLocalizedString("Login", comment: "Login"), style: .default) { (action) in
            self.appDelegate.window?.rootViewController = R.storyboard.login.main()
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
        alert.addAction(login)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
}
extension NotLoggedInHomeVC:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 10
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
            
            
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardSectionOneTableItem.identifier) as? DashboardSectionOneTableItem
            cell?.notLoggedBind(slideShowArray ?? nil)
            cell?.selectionStyle = .none
            cell?.notloggedInVC = self
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noLoginTableItem.identifier) as? NoLoginTableItem
            cell?.selectionStyle = .none
            return cell!
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as? SectionHeaderTableItem
            cell?.selectionStyle = .none
            
            cell?.titleLabel.text = NSLocalizedString("Genres", comment: "Genres")
            return cell!
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardSectionTwoTableItem.identifier) as? DashboardSectionTwoTableItem
            cell?.selectionStyle = .none
            cell?.bind(genresArray)
            cell?.notLoggedInVC = self
            return cell!
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as? SectionHeaderTableItem
            cell?.selectionStyle = .none
            
            cell?.titleLabel.text = NSLocalizedString("Latest Songs", comment: "Latest Songs")
            return cell!
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardSectionThreeTableItem.identifier) as? DashboardSectionThreeTableItem
            cell?.selectionStyle = .none
            cell?.NotLoggedbind(latestSongsArray ?? nil)
            cell?.notloggedInVC = self
            return cell!
            
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as? SectionHeaderTableItem
            cell?.selectionStyle = .none
            
            cell?.titleLabel.text = NSLocalizedString("Popular", comment: "Popular")
            return cell!
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashboardSectionFiveTableItem.identifier) as? DashboardSectionFiveTableItem
            cell?.selectionStyle = .none
            cell?.notLoggedBind(mostPopularArray?.newRelease ?? nil)
            cell?.notloggedInVC = self
            
            return cell!
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sectionHeaderTableItem.identifier) as? SectionHeaderTableItem
            cell?.selectionStyle = .none
            
            cell?.titleLabel.text = NSLocalizedString("Artist", comment: "Artist")
            return cell!
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.dashBoardSectionSixTableItem.identifier) as? DashBoardSectionSixTableItem
            cell?.notLoggedHomeVC = self
            cell?.selectionStyle = .none
            cell?.bind(artistArray)
            cell?.notLoggedHomeVC = self
            return cell!
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if ((self.slideShowArray?.recommended?.isEmpty) != nil){
                return 0
            }else{
                return 300
            }
        case 1:
            return 100.0
        case 2:
            if ((self.genresArray.isEmpty) == nil){
                return 0
            }else{
                return UITableView.automaticDimension
            }
            
        case 3:
            if ((self.genresArray.isEmpty) == nil){
                return 0
            }else{
                return 200
            }
        case 4:
            if ((self.latestSongsArray?.data?.isEmpty) == nil){
                return 0
            }else{
                return UITableView.automaticDimension
            }
            
        case 5:
            if ((self.latestSongsArray?.data?.isEmpty) == nil){
                return 0
            }else{
                return 280
            }
        case 6:
            if ((self.mostPopularArray?.newRelease?.data?.isEmpty) == nil){
                return 0
            }else{
                return UITableView.automaticDimension
            }
            
        case 7:
            if ((self.mostPopularArray?.newRelease?.data?.isEmpty) == nil){
                return 0
            }else{
                return 280
            }
        case 8:
            if ((self.artistArray.isEmpty) == nil){
                return 0
            }else{
                return UITableView.automaticDimension
            }
            
        case 9:
            if ((self.artistArray.isEmpty) == nil){
                return 0
            }else{
                return 280
            }
        default:
            return 280
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            self.loginAlert()
        case 4:
            let vc = R.storyboard.discover.latestSongsVC()
            vc!.notLoggedLatestSongsArray = self.latestSongsArray ?? nil
            self.navigationController?.pushViewController(vc!, animated: true)
        case 6:
            
            let vc = R.storyboard.discover.popularVC()
            vc!.notLoggedPopularArray = self.mostPopularArray?.newRelease ?? nil
            self.navigationController?.pushViewController(vc!, animated: true)
        case 8:
            let vc = R.storyboard.discover.artistVC()
//            vc!.artistArray = self.artistArray ?? []
            self.navigationController?.pushViewController(vc!, animated: true)
        default:
            log.verbose("Nothing to select")
        }
    }
    
    
}
