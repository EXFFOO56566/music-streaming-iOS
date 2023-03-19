//
//  ProfileLikedVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Async
import DeepSoundSDK
import SwiftEventBus
class ProfileLikedVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    var numberArray = [Int]()
    var likedArray = [ProfileModel.Latestsong]()
    var status:Bool? = false
    private let popupContentController = R.storyboard.player.musicPlayerVC()
      private var albumSongMusicArray = [MusicPlayerModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    func setupUI(){
        tableView.separatorStyle = .none
        tableView.register(R.nib.profileSongTableItem(), forCellReuseIdentifier: R.reuseIdentifier.profileSongTableItem.identifier)
        tableView.register(R.nib.noDataTableItem(), forCellReuseIdentifier: R.reuseIdentifier.noDataTableItem.identifier)
//        if self.likedArray.isEmpty{
////            for (index,value) in (AppInstance.instance.userProfile?.data?.liked?.enumerated())!{
////                self.numberArray.append(index)
////            }
//            
//        }else{
////            for (index,value) in (self.likedArray.enumerated()){
////                self.numberArray.append(index)
////            }
//        }
        
        
        
    }
    
}
extension ProfileLikedVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        
        if status!{
            if likedArray.isEmpty{
                return 1
            }else{
                return likedArray.count ?? 0
                
            }
        }else{
            if likedArray.isEmpty{
                if AppInstance.instance.userProfile?.data?.liked?.count ==  0{
                    return 1
                }else{
                    return AppInstance.instance.userProfile?.data?.liked?.count ?? 0
                }
            }else{
                if likedArray.isEmpty{
                    return 1
                }else{
                    return likedArray.count ?? 0
                    
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        
        if status!{
            if (((likedArray.count == 0))){
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noDataTableItem.identifier) as? NoDataTableItem
                cell?.selectionStyle = .none
                return cell!
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.profileSongTableItem.identifier) as? ProfileSongTableItem
                cell?.selectionStyle = .none
                
                let object = self.likedArray[indexPath.row]
//                let index = self.numberArray[indexPath.row]
                cell?.likeDelegate = self
                cell!.likedVC = self
                cell?.bind(object,index:indexPath.row)
                return cell!
            }
        }else{
            if likedArray.isEmpty{
                if (((AppInstance.instance.userProfile?.data?.liked?.count == 0))){
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noDataTableItem.identifier) as? NoDataTableItem
                    cell?.selectionStyle = .none
                    return cell!
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.profileSongTableItem.identifier) as? ProfileSongTableItem
                    cell?.selectionStyle = .none
                    
                    let object = AppInstance.instance.userProfile?.data?.liked![indexPath.row]
//                    let index = self.numberArray[indexPath.row]
                    cell?.likeDelegate = self
                    cell!.likedVC = self
                    cell?.bind(object!,index:indexPath.row)
                    return cell!
                }
            }else{
                if (((likedArray.count == 0))){
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.noDataTableItem.identifier) as? NoDataTableItem
                    cell?.selectionStyle = .none
                    return cell!
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.profileSongTableItem.identifier) as? ProfileSongTableItem
                    cell?.selectionStyle = .none
                    
                    let object = self.likedArray[indexPath.row]
//                    let index = self.numberArray[indexPath.row]
                    cell?.likeDelegate = self
                    cell!.likedVC = self
                    cell?.bind(object,index:indexPath.row)
                    return cell!
                }
            }
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if status!{
            if likedArray.isEmpty{
                return 300.0
            }else{
                return 120.0
                
            }
        }else{
            if likedArray.isEmpty{
                if AppInstance.instance.userProfile?.data?.liked?.count ==  0{
                    return 300.0
                }else{
                    return 120.0
                }
                
            }else{
                if likedArray.isEmpty{
                    return 300.0
                }else{
                    return 120.0
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppInstance.instance.player = nil
                         AppInstance.instance.AlreadyPlayed = false
        if status!{
            let object = self.likedArray[indexPath.row]
                   self.likedArray.forEach({ (it) in
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
                    let commentCount = it.countComment.intValue ?? 0
                       let trackId = it.id ?? 0
                       let isLiked = it.isLiked ?? false
                       let isFavorited = it.isFavoriated ?? false
                       let likecountString = it.countLikes?.stringValue ?? ""
                       let favoriteCountString = it.countFavorite?.stringValue ?? ""
                       let recentlyPlayedCountString = it.countViews?.stringValue ?? ""
                       let sharedCountString = it.countShares?.stringValue ?? ""
                    let commentCountString = it.countComment.stringValue ?? ""
                       
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
            let commentCount = object.countComment.intValue ?? 0
                   let trackId = object.id ?? 0
                   let isLiked = object.isLiked ?? false
                   let isFavorited = object.isFavoriated ?? false
                   
                   let likecountString = object.countLikes?.stringValue ?? ""
                   let favoriteCountString = object.countFavorite?.stringValue ?? ""
                   let recentlyPlayedCountString = object.countViews?.stringValue ?? ""
                   let sharedCountString = object.countShares?.stringValue ?? ""
            let commentCountString = object.countComment.stringValue ?? ""
                   
                   let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
                   popupContentController!.popupItem.title = object.publisher?.name ?? ""
                   popupContentController!.popupItem.subtitle = object.title?.htmlAttributedString ?? ""
            let cell  = tableView.cellForRow(at: indexPath) as? ProfileSongTableItem
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
        }else{
            let object = AppInstance.instance.userProfile?.data?.liked?[indexPath.row]
            AppInstance.instance.userProfile?.data?.liked!.forEach({ (it) in
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
                               let commentCount = it.countComment.intValue ?? 0
                                  let trackId = it.id ?? 0
                                  let isLiked = it.isLiked ?? false
                                  let isFavorited = it.isFavoriated ?? false
                                  let likecountString = it.countLikes?.stringValue ?? ""
                                  let favoriteCountString = it.countFavorite?.stringValue ?? ""
                                  let recentlyPlayedCountString = it.countViews?.stringValue ?? ""
                                  let sharedCountString = it.countShares?.stringValue ?? ""
                               let commentCountString = it.countComment.stringValue ?? ""
                                  
                                  let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
                                  self.albumSongMusicArray.append(musicObject)
                              })
                              var audioString:String? = ""
                              var isDemo:Bool? = false
            let name = object?.publisher?.name ?? ""
            let time = object?.timeFormatted ?? ""
            let title = object?.title ?? ""
            let musicType = object?.categoryName ?? ""
            let thumbnailImageString = object?.thumbnail ?? ""
            if object?.demoTrack == ""{
                audioString = object?.audioLocation ?? ""
                                  isDemo = false
            }else if object?.demoTrack != "" && object?.audioLocation != ""{
                audioString = object?.audioLocation ?? ""
                                  isDemo = false
                              }else{
                audioString = object?.demoTrack ?? ""
                                  isDemo = true
                              }
            let isOwner = object?.isOwner ?? false
            let audioId = object?.audioID ?? ""
            let likeCount = object?.countLikes?.intValue ?? 0
            let favoriteCount = object?.countFavorite?.intValue ?? 0
            let recentlyPlayedCount = object?.countViews?.intValue ?? 0
            let sharedCount = object?.countShares?.intValue ?? 0
            let commentCount = object!.countComment.intValue ?? 0
            let trackId = object?.id ?? 0
            let isLiked = object?.isLiked ?? false
            let isFavorited = object?.isFavoriated ?? false
                              
            let likecountString = object?.countLikes?.stringValue ?? ""
            let favoriteCountString = object?.countFavorite?.stringValue ?? ""
            let recentlyPlayedCountString = object?.countViews?.stringValue ?? ""
            let sharedCountString = object?.countShares?.stringValue ?? ""
            let commentCountString = object!.countComment.stringValue ?? ""
                              
                              let musicObject = MusicPlayerModel(name: name, time: time, title: title, musicType: musicType, ThumbnailImageString: thumbnailImageString, likeCount: likeCount, favoriteCount: favoriteCount, recentlyPlayedCount: recentlyPlayedCount, sharedCount: sharedCount, commentCount: commentCount, likeCountString: likecountString, favoriteCountString: favoriteCountString, recentlyPlayedCountString: recentlyPlayedCountString, sharedCountString: sharedCountString, commentCountString: commentCountString, audioString: audioString, audioID: audioId, isLiked: isLiked, isFavorite: isFavorited, trackId: trackId,isDemoTrack:isDemo!,isPurchased:false,isOwner: isOwner)
            popupContentController!.popupItem.title = object?.publisher?.name ?? ""
            popupContentController!.popupItem.subtitle = object?.title?.htmlAttributedString ?? ""
            let cell  = tableView.cellForRow(at: indexPath) as? ProfileSongTableItem
                       popupContentController!.popupItem.image = cell?.thumbnailImage.image
                       AppInstance.instance.popupPlayPauseSong = false
                       
                       SwiftEventBus.postToMainThread(EventBusConstants.EventBusConstantsUtils.EVENT_PLAY_PAUSE_BTN, sender: true)
            self.addToRecentlyWatched(trackId: object?.id ?? 0)
                              
                              tabBarController?.presentPopupBar(withContentViewController: popupContentController!, animated: true, completion: {
                                  
                                  self.popupContentController?.musicObject = musicObject
                                  self.popupContentController!.musicArray = self.albumSongMusicArray
                                  self.popupContentController!.currentAudioIndex = indexPath.row
                                  self.popupContentController?.setup()

                              })
        }
    }
}

extension ProfileLikedVC:likeDislikeSongDelegate{
    
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

extension ProfileLikedVC:IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: (NSLocalizedString("LIKED", comment: "LIKED")))
    }
}
