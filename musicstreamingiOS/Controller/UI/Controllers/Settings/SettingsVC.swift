
import UIKit
import Async
import DeepSoundSDK
import SwiftEventBus
import Async
class SettingsVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .singleLineEtched
        self.title = (NSLocalizedString("Settings", comment: ""))
        self.setupUI()
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    private func setupUI(){
        self.tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "SectionHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "SectionHeaderTableViewCell")
        tableView.register(R.nib.settingsSectionOneTableItem(), forCellReuseIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier)
        tableView.register(R.nib.settingsSectionTwoTableItem(), forCellReuseIdentifier: R.reuseIdentifier.settingsSectionTwoTableItem.identifier)
        
    }
    
    private func logout(){
        let alert = UIAlertController(title: (NSLocalizedString("Logout", comment: "")), message: (NSLocalizedString("Are you sure you want to logout", comment: "")), preferredStyle: .alert)
        let logout = UIAlertAction(title: (NSLocalizedString("Logout", comment: "")), style: .destructive) { (action) in
            self.logoutUser()
        }
        let cancel = UIAlertAction(title: (NSLocalizedString("Cancel", comment: "")), style: .cancel, handler: nil)
        alert.addAction(logout)
        alert.addAction(cancel)
        self.present(alert, animated:true, completion: nil)
        
    }
    private func logoutUser(){
        if Connectivity.isConnectedToNetwork(){
            
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            let accessToken = AppInstance.instance.accessToken ?? ""
            
            Async.background({
                UserManager.instance.LogoutUser(AccessToken: accessToken, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.message ?? "")")
                                self.view.makeToast(success?.message ?? "")
                                let timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.update), userInfo: nil, repeats: false)
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
    @objc func update() {
        UserDefaults.standard.removeValuefromUserdefault(Key: Local.USER_SESSION.User_Session)
        AppInstance.instance.userProfile = nil
        let vc = R.storyboard.login.main()
        appDelegate.window?.rootViewController = vc
        self.dismiss(animated: true, completion: nil)
        
    }
    private func theme(){
        let alert = UIAlertController(title: (NSLocalizedString("Select Theme", comment: "")), message: "", preferredStyle: .alert)
        let light = UIAlertAction(title: (NSLocalizedString("Light", comment: "")), style: .destructive) { (action) in
            if #available(iOS 13.0, *) {
                self.appDelegate.window?.overrideUserInterfaceStyle = .light
                UserDefaults.standard.setDarkMode(value: false, ForKey: "darkMode")
            }
        }
        let dark = UIAlertAction(title: "Dark", style: .destructive) { (action) in
            if #available(iOS 13.0, *) {
                self.appDelegate.window?.overrideUserInterfaceStyle = .dark
                UserDefaults.standard.setDarkMode(value: true, ForKey: "darkMode")
            }
        }
        let cancel = UIAlertAction(title: (NSLocalizedString("Cancel", comment: "")), style: .cancel, handler: nil)
        alert.addAction(light)
        alert.addAction(dark)
        alert.addAction(cancel)
        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated:true, completion: nil)
        
    }
}

extension SettingsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == IndexPath(row: 0, section: 0) {
            return 100
        }else  if indexPath == IndexPath(row: 0, section: 1) {
            return 56
        } else {
            return 56
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            if ControlSettings.isGoProEnabled{
                if AppInstance.instance.userProfile?.data?.isPro ?? 0 == 0{
                    if indexPath.row == 0 {
                        let vc = R.storyboard.settings.editProfileVC()
                        self.navigationController?.pushViewController(vc!, animated: true)
                    } else if indexPath.row == 1 {
                        let vc = R.storyboard.settings.myAccountVC()
                        self.navigationController?.pushViewController(vc!, animated: true)
                    } else if indexPath.row == 2 {
                        print("Move to Notification")
                        
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Settings", bundle: nil)
                        let vc = storyBoard.instantiateViewController(withIdentifier: "SettingNotificationVC") as! SettingNotificationVC
                        navigationController?.pushViewController(vc, animated: true)
                    } else if indexPath.row == 3 {
                        let vc = R.storyboard.upgrade.widthdrawalsVC()
                        self.navigationController?.pushViewController(vc!, animated: true)
                    } else if indexPath.row == 4 {
                        //                      if  ControlSettings.isApplePay!{
                        //                                if let controller = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) {
                        //                                    controller.delegate = self
                        //                                    present(controller, animated: true, completion: nil)
                        //                                }
                        //                            }else{
                        //
                        //                            }
        //                if AppInstance.instance.userProfile?.data?.isPro ?? 0 == 1{
        //                    let vc = R.storyboard.popups.premiumPopupVC()
        //                    self.present(vc!, animated: true, completion: nil)
        //                }else{
        //                    let vc = R.storyboard.upgrade.upgradeProVC()
        //                    self.navigationController?.pushViewController(vc!, animated: true)
        //                }
                        let vc = R.storyboard.upgrade.upgradeProVC()
                                           self.navigationController?.pushViewController(vc!, animated: true)
                        
                    } else if indexPath.row == 5 {

                        let storyBoard: UIStoryboard = UIStoryboard(name: "Settings", bundle: nil)
                        let vc = storyBoard.instantiateViewController(withIdentifier: "SettingWalletVC") as! SettingWalletVC
                        navigationController?.pushViewController(vc, animated: true)
                        print("walletVc")
                        
                    }else if indexPath.row == 6 {
                        let vc = R.storyboard.settings.blockUsersVC()
                        self.navigationController?.pushViewController(vc!, animated: true)
                    }
                }else{
                    if indexPath.row == 0 {
                        let vc = R.storyboard.settings.editProfileVC()
                        self.navigationController?.pushViewController(vc!, animated: true)
                    } else if indexPath.row == 1 {
                        let vc = R.storyboard.settings.myAccountVC()
                        self.navigationController?.pushViewController(vc!, animated: true)
                    } else if indexPath.row == 2 {
                        let vc = R.storyboard.upgrade.widthdrawalsVC()
                        self.navigationController?.pushViewController(vc!, animated: true)
                    } else if indexPath.row == 3 {
                        let vc = R.storyboard.settings.articlesVC()
                        self.navigationController?.pushViewController(vc!, animated: true)
                        
                    }else if indexPath.row == 4 {
                        let vc = R.storyboard.settings.blockUsersVC()
                        self.navigationController?.pushViewController(vc!, animated: true)
                    }else if indexPath.row == 5{
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Settings", bundle: nil)
                        let vc = storyBoard.instantiateViewController(withIdentifier: "SettingWalletVC") as! SettingWalletVC
                        navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }else{
                if indexPath.row == 0 {
                    let vc = R.storyboard.settings.editProfileVC()
                    self.navigationController?.pushViewController(vc!, animated: true)
                } else if indexPath.row == 1 {
                    let vc = R.storyboard.settings.myAccountVC()
                    self.navigationController?.pushViewController(vc!, animated: true)
                } else if indexPath.row == 2 {
                    let vc = R.storyboard.upgrade.widthdrawalsVC()
                    self.navigationController?.pushViewController(vc!, animated: true)
                } else if indexPath.row == 3 {
                    let vc = R.storyboard.settings.articlesVC()
                    self.navigationController?.pushViewController(vc!, animated: true)
                    
                }else if indexPath.row == 4 {
                    let vc = R.storyboard.settings.blockUsersVC()
                    self.navigationController?.pushViewController(vc!, animated: true)
                }else if indexPath.row == 5{
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Settings", bundle: nil)
                    let vc = storyBoard.instantiateViewController(withIdentifier: "SettingWalletVC") as! SettingWalletVC
                    navigationController?.pushViewController(vc, animated: true)
                }
            } 
        }else if indexPath.section == 2{
            switch indexPath.row {
            case 0:
                let vc = R.storyboard.settings.changePasswordVC()
                self.navigationController?.pushViewController(vc!, animated: true)
            case 1:
                let vc = R.storyboard.settings.settingsTwoFactorVC()
                self.navigationController?.pushViewController(vc!, animated: true)
            case 2:
                let vc = R.storyboard.settings.manageSessionsVC()
                self.navigationController?.pushViewController(vc!, animated: true)
                
            default:
                break
            }
            
        }else if indexPath.section == 3 {
            switch indexPath.row {
            case 0:
                self.theme()
            default:
                break
            }
            
        }else if indexPath.section == 4 {
            switch indexPath.row {
            case 0:
                let vc = R.storyboard.login.genresVC()
                self.navigationController?.pushViewController(vc!, animated: true)
            case 1:
                let vc = R.storyboard.settings.articlesVC()
                self.navigationController?.pushViewController(vc!, animated: true)
                
            default:
                break
            }
            
        }else if indexPath.section == 5{
            switch indexPath.row {
            case 0:
                print("Rate out APP")
                
            case 1:
                print("ABOUT")
//                let termOfUseURL = URL(string:  ControlSettings.termsOfUse)
//                UIApplication.shared.openURL(termOfUseURL!)
            case 2:
                print("terms of use" )
                let termOfUseURL = URL(string:  ControlSettings.termsOfUse)
                UIApplication.shared.openURL(termOfUseURL!)
//                let vc = R.storyboard.settings.deleteAccountVC()
//                self.navigationController?.pushViewController(vc!, animated: true)
            case 3:
                let helpURL = URL(string: ControlSettings.HelpLink)
                UIApplication.shared.openURL(helpURL!)
                //self.logout()
                
            default:
                break
            }
        }else if indexPath.section == 6{
            switch indexPath.row {
            case 0:
                print("deleteAccountVC")
                let vc = R.storyboard.settings.deleteAccountVC()
                self.navigationController?.pushViewController(vc!, animated: true)
                
            case 1:
                print("logout")
                self.logout()
            
                
            default:
                break
            }
        }
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 56))
//        view.backgroundColor = UIColor.systemBackground
//
//        let separatorView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 8))
//
//        separatorView.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
////        separatorView.backgroundColor = UIColor.systemBackground
//        let label = UILabel(frame: CGRect(x: 16, y: 8, width: view.frame.size.width, height: 48))
//        label.textColor = UIColor.mainColor
//        label.font = UIFont(name: "Poppins-Regular", size: 17)
//        if section == 0{
//            label.text = (NSLocalizedString("General", comment: ""))
//
//        } else if section == 1 {
//            label.text = (NSLocalizedString("Security", comment: ""))
//        } else if section == 2 {
//            label.text = (NSLocalizedString("Display", comment: ""))
//        } else if section == 3 {
//            label.text = (NSLocalizedString("Interest", comment: ""))
//        } else{
//            label.text = (NSLocalizedString("Support", comment: ""))
//        }
//        view.addSubview(separatorView)
//        view.addSubview(label)
//        return view
//
//    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 56
//    }
}

extension SettingsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0: return 1
        case 1:if ControlSettings.isGoProEnabled{ if AppInstance.instance.userProfile?.data?.isPro ?? 0 == 0 {return 7}else{return 6}}else{return 6}
        case 2: return 3
        case 3: return 1
        case 4: return 2
        case 5: return 4
        case 6: return 2
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            switch indexPath.row{
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier:"SectionHeaderTableViewCell") as! SectionHeaderTableViewCell
                cell.bind()
                
//                cell.titleLabel.text = (NSLocalizedString("Password", comment: ""))
//                cell.descriptionLabel.text = (NSLocalizedString("Change your password", comment: ""))
                return cell
            default:
                return UITableViewCell()
            }
        case 1:
            if ControlSettings.isGoProEnabled{
                if AppInstance.instance.userProfile?.data?.isPro ?? 0 == 0{
                    switch indexPath.row {
                    case 0:
                    
                        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                        cell.titleLabel.text = (NSLocalizedString("Edit Profile Info", comment: ""))
                        return cell
                    case 1:
                        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                        cell.titleLabel.text = (NSLocalizedString("My Account", comment: ""))
                        return cell
                    case 2:
                        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                        cell.titleLabel.text = (NSLocalizedString("Notifications", comment: ""))
                        return cell
                    case 3:
                        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                        cell.titleLabel.text = (NSLocalizedString("Withdrawals", comment: ""))
                        return cell
                    case 4:
                        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                        cell.titleLabel.text = (NSLocalizedString("Go Pro", comment: ""))
                        return cell
                    case 5:
                        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                        cell.titleLabel.text = (NSLocalizedString("Wallet", comment: ""))
                        return cell
                    case 6:
                        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                        cell.titleLabel.text = (NSLocalizedString("Blocked Users", comment: ""))
                        cell.introForwardImage.isHidden = false
                        return cell
                    default:
                        return UITableViewCell()
                    }
                }else{
                    switch indexPath.row {
                    case 0:
                    
                        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                        cell.titleLabel.text = (NSLocalizedString("Edit Profile Info", comment: ""))
                        return cell
                    case 1:
                        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                        cell.titleLabel.text = (NSLocalizedString("My Account", comment: ""))
                        return cell
                    case 2:
                        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                        cell.titleLabel.text = (NSLocalizedString("Withdrawals", comment: ""))
                        return cell
                   
                    case 3:
                        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                        cell.titleLabel.text = (NSLocalizedString("Articles", comment: ""))
                        return cell
                   
                    case 4:
                        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                        cell.titleLabel.text = (NSLocalizedString("Blocked Users", comment: ""))
                        return cell
                    case 5:
                       let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                       cell.titleLabel.text = (NSLocalizedString("Wallet", comment: ""))
                       return cell
                    default:
                        return UITableViewCell()
                    }
                }
            }else{
                switch indexPath.row {
                case 0:
                
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                    cell.titleLabel.text = (NSLocalizedString("Edit Profile Info", comment: ""))
                    return cell
                case 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                    cell.titleLabel.text = (NSLocalizedString("My Account", comment: ""))
                    return cell
                case 2:
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                    cell.titleLabel.text = (NSLocalizedString("Withdrawals", comment: ""))
                    return cell
               
                case 3:
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                    cell.titleLabel.text = (NSLocalizedString("Articles", comment: ""))
                    return cell
               
                case 4:
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                    cell.titleLabel.text = (NSLocalizedString("Blocked Users", comment: ""))
                    return cell
                 case 5:
                    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                    cell.titleLabel.text = (NSLocalizedString("Wallet", comment: ""))
                    return cell
                default:
                    return UITableViewCell()
                }
            }

           
        case 2:
            switch indexPath.row{
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier:R.reuseIdentifier.settingsSectionTwoTableItem.identifier) as! SettingsSectionTwoTableItem
                cell.titleLabel.text = (NSLocalizedString("Password", comment: ""))
                cell.descriptionLabel.text = (NSLocalizedString("Change your password", comment: ""))
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                cell.titleLabel.text = (NSLocalizedString("Two-factor authentication", comment: ""))
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                cell.titleLabel.text = (NSLocalizedString("Manage Sessions", comment: ""))
                return cell
            default:
                return UITableViewCell()
            }
        case 3:
            switch indexPath.row{
                
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                cell.titleLabel.text = (NSLocalizedString("Theme", comment: ""))
                return cell
            default:
                return UITableViewCell()
            }
        case 4:
            switch indexPath.row{
                
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier:R.reuseIdentifier.settingsSectionTwoTableItem.identifier) as! SettingsSectionTwoTableItem
                cell.titleLabel.text = (NSLocalizedString("Interest", comment: ""))
                cell.descriptionLabel.text = (NSLocalizedString("Select Your Music Preference", comment: "Select Your Music Preference"))
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                cell.titleLabel.text = (NSLocalizedString("Articles", comment: ""))
                return cell
            default:
                return UITableViewCell()
            }
            
        case 5:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                cell.titleLabel.text = (NSLocalizedString("Rate our App", comment: ""))
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                cell.titleLabel.text = (NSLocalizedString("About", comment: ""))
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                cell.titleLabel.text = (NSLocalizedString("Term of use", comment: ""))
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                cell.titleLabel.text = (NSLocalizedString("Help", comment: ""))
                return cell
                
            default:
                return UITableViewCell()
            }
        case 6:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                cell.titleLabel.text = (NSLocalizedString("Delete Acoount", comment: ""))
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.settingsSectionOneTableItem.identifier) as! SettingsSectionOneTableItem
                cell.titleLabel.text = (NSLocalizedString("Logout", comment: ""))
                cell.introForwardImage.isHidden = true
                return cell
                
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
        }
    }
}
