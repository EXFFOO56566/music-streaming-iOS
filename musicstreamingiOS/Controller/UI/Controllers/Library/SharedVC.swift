//
//  SharedVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 22/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import DeepSoundSDK
import SwiftEventBus
import Async
class SharedVC: BaseVC {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showImage: UIImageView!
    @IBOutlet weak var showLabel: UILabel!
    
     private let popupContentController = R.storyboard.player.musicPlayerVC()
    private var sharedSongsArray = [MusicPlayerModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.getSharedSongs()
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
        
    }
    
    private func setupUI(){
        self.title = (NSLocalizedString("Shared", comment: ""))
        self.tableView.separatorStyle = .none
        tableView.register(R.nib.sharedTableCell(), forCellReuseIdentifier: R.reuseIdentifier.shared_TableCell.identifier)
          tableView.register(R.nib.noDataTableItem(), forCellReuseIdentifier: R.reuseIdentifier.noDataTableItem.identifier)
    }
    
    private func getSharedSongs(){
        var allData =  UserDefaults.standard.getSharedSongs(Key: Local.SHARE_SONG.Share_Song)
                   self.tableView.isHidden = false
            log.verbose("all data = \(allData)")
            for data in allData{
                let musicObject = try? PropertyListDecoder().decode(MusicPlayerModel.self ,from: data)
                if musicObject != nil{
                    log.verbose("musicObject = \(musicObject?.trackId)")
                    self.sharedSongsArray.append(musicObject!)
                    
                }else{
                    log.verbose("Nil values cannot be append in Array!")
                } 
            }
        
    }
}
extension SharedVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.sharedSongsArray.count == 0{
                 return 1
             }else{
                 return self.sharedSongsArray.count
             }
      
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.sharedSongsArray.count == 0{
                   let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noDataTableItem.identifier) as? NoDataTableItem
                   cell?.selectionStyle = .none
                   return cell!
               }else{
                   let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.shared_TableCell.identifier) as? Shared_TableCell
                   cell?.selectionStyle = .none
                   
                   cell?.vc = self
                   cell?.likeDelegate = self
                   let object = self.sharedSongsArray[indexPath.row]
                   cell?.bind(object, index: indexPath.row)
                   return cell!
               }
       
        
      
            }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppInstance.instance.player = nil
        AppInstance.instance.AlreadyPlayed = false
        popupContentController!.popupItem.title = self.sharedSongsArray[indexPath.row].name ?? ""
        popupContentController!.popupItem.subtitle = self.sharedSongsArray[indexPath.row].title ?? ""
        let cell  = tableView.cellForRow(at: indexPath) as? Shared_TableCell
        popupContentController!.popupItem.image = cell?.thumbnailImage.image
                  AppInstance.instance.popupPlayPauseSong = false
        SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
        
        self.addToRecentlyWatched(trackId: self.sharedSongsArray[indexPath.row].trackId ?? 0)
      
        tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
            
            self.popupContentController?.musicObject = self.sharedSongsArray[indexPath.row]
            self.popupContentController!.musicArray = self.sharedSongsArray
            self.popupContentController!.currentAudioIndex = indexPath.row
             self.popupContentController?.setup()
            
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if self.sharedSongsArray.count == 0{
                   return 500.0
               }else{
                   return 120.0
               }
               
               
           }
    
}
extension SharedVC:likeDislikeSongDelegate{
    
    func likeDisLikeSong(status: Bool, button: UIButton,audioId:String) {
        
        if status{
            button.setImage(R.image.heart(), for: .normal)
            self.likeDislike(audioId: audioId, button: button)
        }else{
            button.setImage(R.image.ic_heartRed(), for: .normal)
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
                                    button.setImage(R.image.heart(), for: .normal)
                                }else{
                                    button.setImage(R.image.ic_heartRed(), for: .normal)
                                }
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
