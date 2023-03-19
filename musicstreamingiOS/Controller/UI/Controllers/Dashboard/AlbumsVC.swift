//
//  AlbumsVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class AlbumsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var albumsArray = [ProfileModel.AlbumElement]()
    var status:Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    func setupUI(){
        tableView.separatorStyle = .none
        tableView.register(R.nib.profileAlbumsTableCell(), forCellReuseIdentifier: R.reuseIdentifier.profileAlbumsTableCell.identifier)
        tableView.register(R.nib.noDataTableItem(), forCellReuseIdentifier: R.reuseIdentifier.noDataTableItem.identifier)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}
extension AlbumsVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if status!{
            if albumsArray.isEmpty{
                return 1
            }else{
                return albumsArray.count ?? 0
                
            }
        }else{
            if albumsArray.isEmpty{
                if AppInstance.instance.userProfile?.data?.albums?.count ==  0{
                    return 1
                }else{
                    return AppInstance.instance.userProfile?.data?.albums?.count ?? 0
                    
                }
                
            }else{
                if albumsArray.isEmpty{
                    return 1
                }else{
                    return albumsArray.count ?? 0
                    
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if status!{
            if (self.albumsArray.count == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noDataTableItem.identifier) as? NoDataTableItem
                cell?.selectionStyle = .none
                return cell!
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.profileAlbumsTableCell.identifier) as? ProfileAlbumsTableCell
                cell?.selectionStyle = .none
                
                let object = albumsArray[indexPath.row]
                cell?.bind(object)
                return cell!
            }
        }else{
            if albumsArray.isEmpty{
                if (AppInstance.instance.userProfile?.data?.albums?.count == 0){
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noDataTableItem.identifier) as? NoDataTableItem
                    cell?.selectionStyle = .none
                    return cell!
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.profileAlbumsTableCell.identifier) as? ProfileAlbumsTableCell
                    cell?.selectionStyle = .none
                    
                    let object = AppInstance.instance.userProfile?.data?.albums![indexPath.row]
                    cell?.bind(object!)
                    return cell!
                }
            }else{
                if (self.albumsArray.count == 0){
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noDataTableItem.identifier) as? NoDataTableItem
                    cell?.selectionStyle = .none
                    return cell!
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.profileAlbumsTableCell.identifier) as? ProfileAlbumsTableCell
                    cell?.selectionStyle = .none
                    
                    let object = albumsArray[indexPath.row]
                    cell?.bind(object)
                    return cell!
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if status!{
            if albumsArray.isEmpty{
                return 300.0
            }else{
                return 120.0
                
            }
        }else{
            if albumsArray.isEmpty{
                if AppInstance.instance.userProfile?.data?.albums?.count ==  0{
                    return 300.0
                }else{
                    return 120.0
                }
                
            }else{
                if albumsArray.isEmpty{
                    return 300.0
                }else{
                    return 120.0
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = R.storyboard.dashboard.showAlbumVC()
        vc?.profileAlbumObject = AppInstance.instance.userProfile?.data?.albums![indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
extension AlbumsVC:IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: (NSLocalizedString("ALBUMS", comment: "ALBUMS")))
    }
}
