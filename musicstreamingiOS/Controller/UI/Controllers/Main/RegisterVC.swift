//
//  RegisterVC.swift
//  DeepSoundiOS
//
//  Created by Macbook Pro on 14/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Async
import DeepSoundSDK

class RegisterVC: BaseVC {
    
    @IBOutlet weak var createAccount: UIButton!
    @IBOutlet weak var policyLabel: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var confirmPasswordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var usernameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var lastNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var firstNameTextField: SkyFloatingLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func termsOFServicePressed(_ sender: Any) {
        let url = URL(string: ControlSettings.termsOfUse)!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                print("Open url : \(success)")
            })
        }
    }
    @IBAction func createAccountPressed(_ sender: Any) {
        self.registerPressed()
    }
    
    private func setupUI(){
        self.firstNameTextField.selectedLineColor = .mainColor
        self.lastNameTextField.selectedLineColor = .mainColor
        self.emailTextField.selectedLineColor = .mainColor
        self.usernameTextField.selectedLineColor = .mainColor
        self.passwordTextField.selectedLineColor = .mainColor
        self.confirmPasswordTextField.selectedLineColor = .mainColor
        self.createAccount.setTitleColor(.mainColor, for: UIControl.State.normal)
        
        self.signUpLabel.text = NSLocalizedString("Sign Up", comment: "")
        self.firstNameTextField.placeholder = NSLocalizedString("First Name", comment: "")
        self.lastNameTextField.placeholder = NSLocalizedString("Last Name", comment: "")
        self.emailTextField.placeholder = NSLocalizedString("Email", comment: "")
        self.usernameTextField.placeholder = NSLocalizedString("Username", comment: "")
        self.passwordTextField.placeholder = NSLocalizedString("Password", comment: "")
        self.confirmPasswordTextField.placeholder = NSLocalizedString("Confirm Password", comment: "")
        self.createAccount.setTitle(NSLocalizedString("CREATE AN ACCOUNT", comment: ""), for: .normal)
        self.policyLabel.text = NSLocalizedString("BY REGISTERING YOU AGREE TO OUR ", comment: "")
        self.navigationController?.navigationBar.transparentNavigationBar()
    }
    
    private func registerPressed(){
        if appDelegate.isInternetConnected{
            if (self.firstNameTextField.text?.isEmpty)!{
                
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                securityAlertVC?.errorText = NSLocalizedString("Please enter name.", comment: "")
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else if (self.lastNameTextField.text?.isEmpty)!{
                
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                securityAlertVC?.errorText = NSLocalizedString("Please enter name.", comment: "")
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else if (self.emailTextField.text?.isEmpty)!{
                
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                securityAlertVC?.errorText = NSLocalizedString("Please enter username.", comment: "")
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else if (self.usernameTextField.text?.isEmpty)!{
                
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                securityAlertVC?.errorText = NSLocalizedString("Please enter email.", comment: "")
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else if (self.passwordTextField.text?.isEmpty)!{
                
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                securityAlertVC?.errorText = NSLocalizedString("Please enter password.", comment: "")
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else if (self.confirmPasswordTextField.text?.isEmpty)!{
                
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                securityAlertVC?.errorText = NSLocalizedString("Please enter confirm password.", comment: "")
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else if (self.passwordTextField.text != self.confirmPasswordTextField.text){
                
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                securityAlertVC?.errorText = NSLocalizedString("Password do not match.", comment: "")
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else if !((emailTextField.text?.isEmail)!){
                
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                securityAlertVC?.errorText = NSLocalizedString("Email is badly formatted.", comment: "")
                self.present(securityAlertVC!, animated: true, completion: nil)
                
            }else{
                let alert = UIAlertController(title: "", message: NSLocalizedString("By registering you agree to our terms of service", comment: ""), preferredStyle: .alert)
                let okay = UIAlertAction(title: NSLocalizedString("OKAY", comment: ""), style: .default) { (action) in
                    self.registerPressedfunc()
                }
                let termsOfService = UIAlertAction(title: NSLocalizedString("TERMS OF SERVICE", comment: ""), style: .default) { (action) in
                    let url = URL(string: ControlSettings.termsOfUse)!
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        
                        UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                            print("Open url : \(success)")
                        })
                    }
                }
                let privacy = UIAlertAction(title: NSLocalizedString("PRIVACY", comment: ""), style: .default) { (action) in
                    let url = URL(string: ControlSettings.privacyPolicy)!
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        
                        UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                            print("Open url : \(success)")
                        })
                    }
                    
                }
                alert.addAction(termsOfService)
                alert.addAction(privacy)
                alert.addAction(okay)
                self.present(alert, animated: true, completion: nil)
            }
            
        }else{
            self.dismissProgressDialog {
                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                securityAlertVC?.titleText  = NSLocalizedString("Internet Error ", comment: "")
                securityAlertVC?.errorText = NSLocalizedString(InterNetError , comment: "")
                self.present(securityAlertVC!, animated: true, completion: nil)
                log.error("internetError - \(InterNetError)")
            }
        }
    }
    private func registerPressedfunc(){
        self.showProgressDialog(text: NSLocalizedString("Loading...", comment: ""))
        let name = "\(self.firstNameTextField.text ?? "")\(self.lastNameTextField.text ?? "")"
        let username = self.usernameTextField.text ?? ""
        let email = self.emailTextField.text ?? ""
        let password = self.passwordTextField.text ?? ""
        let confirmPassword = self.confirmPasswordTextField.text ?? ""
         let deviceId = UserDefaults.standard.getDeviceId(Key: Local.DEVICE_ID.DeviceId) ?? ""
        Async.background({
            
            UserManager.instance.registerUser(Name: name, Email: email, UserName: username, Password: password, ConfirmPassword: confirmPassword, DeviceId: deviceId, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main{
                        self.dismissProgressDialog{
                            if success?.waitValidation == 1{
                                let securityAlertVC = R.storyboard.popups.securityPopupVC()
                                securityAlertVC?.status = true
                                securityAlertVC?.titleText  = NSLocalizedString("Success", comment: "Success")
                                securityAlertVC?.errorText = NSLocalizedString("Please Verify your email" , comment: "Please Verify your email")
                                self.present(securityAlertVC!, animated: true, completion: nil)
                            }else{
                                let User_Session = [Local.USER_SESSION.Access_token:success?.accessToken as Any,Local.USER_SESSION.User_id:success?.data?.id as Any] as [String : Any]
                                UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                                log.verbose("Success = \(success?.accessToken ?? "")")
                                AppInstance.instance.getUserSession()
                                AppInstance.instance.fetchUserProfile()
                                UserDefaults.standard.setPassword(value: password, ForKey: Local.USER_SESSION.Current_Password)
                                let vc = R.storyboard.login.getStartedVC()
                                self.navigationController?.pushViewController(vc!, animated: true)
                                self.view.makeToast(NSLocalizedString("Login Successfull!!", comment: ""))
                            }
                           
                        }
                        
                    }
                    
                }else if sessionError != nil{
                    Async.main{
                        
                        self.dismissProgressDialog {
                            log.verbose("session Error = \(sessionError?.error ?? "")")
                            let securityAlertVC = R.storyboard.popups.securityPopupVC()
                            securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                            securityAlertVC?.errorText = NSLocalizedString(sessionError?.error ?? "", comment: "")
                            self.present(securityAlertVC!, animated: true, completion: nil)
                        }
                    }
                    
                }else {
                    Async.main({
                        
                        self.dismissProgressDialog {
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            let securityAlertVC = R.storyboard.popups.securityPopupVC()
                            securityAlertVC?.titleText  = NSLocalizedString("Security", comment: "")
                            securityAlertVC?.errorText = NSLocalizedString(error?.localizedDescription ?? "", comment: "")
                            self.present(securityAlertVC!, animated: true, completion: nil)
                        }
                    })
                }
            })
        })
    }
}
