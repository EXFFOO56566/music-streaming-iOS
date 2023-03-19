//
//  AppInstance.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 28/06/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Async
import UIKit
import DeepSoundSDK
import AVKit
class AppInstance {
    
    // MARK: - Properties
    
    static let instance = AppInstance()
    
    var userId:Int? = nil
    var accessToken:String? = nil
    var genderText:String? = "all"
    var profilePicText:String? = "all"
    var statusText:String? = "all"
    var playSongBool:Bool? = false
    var currentIndex:Int? = 0
    var popupPlayPauseSong:Bool? = false
    var offlinePlayPauseSong:Bool? = false
    var AlreadyPlayed:Bool? = false
    var addCount:Int? = 0
     var player:AVPlayer? = nil
    var options =  [String:Any]()
    var latestSong = [DiscoverModel.Song]()
    
    // MARK: -
    var userProfile:ProfileModel.ProfileSuccessModel?
    
    
    func getUserSession()->Bool{
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        if localUserSessionData.isEmpty{
            return false
        }else {
            self.userId = (localUserSessionData[Local.USER_SESSION.User_id]  as! Int)
            self.accessToken = localUserSessionData[Local.USER_SESSION.Access_token] as? String ?? ""
            return true
        }
    }
    
    func fetchUserProfile(){
        
        let status = AppInstance.instance.getUserSession()
        
        if status{
            let userId = AppInstance.instance.userId ?? 0
            let accessToken = AppInstance.instance.accessToken ?? ""
            Async.background({
                ProfileManger.instance.getProfile(UserId: userId, AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                           
                            AppInstance.instance.userProfile = success ?? nil
                            
                        })
                    }else if sessionError != nil{
                        Async.main({
                            
                            log.error("sessionError = \(sessionError?.error ?? "")")
                        })
                        
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription ?? "")")
                        })
                    }
                })
            })
        }else {
            log.error(InterNetError)
        }
    }
    func getOptions(completionBlock: @escaping (_ Success:[String:Any]?,_ sessionError:String?, Error?) ->()){
            Async.background({
                GetOptionsManager.instance.getOptions { success, sessionError, error in
                    if success != nil{
                        Async.main({
                            let data = success?["data"] as? [String:Any]
                            AppInstance.instance.options = data ?? [:]
                            completionBlock(data,nil,nil)
                        })
                    }else if sessionError != nil{
                        Async.main({
                            
                            log.error("sessionError = \(sessionError ?? "")")
                            completionBlock(nil,sessionError ?? "",nil)
                        })
                        
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription ?? "")")
                            completionBlock(nil,nil,error)
                        })
                    }
                }
            })
    }
}

