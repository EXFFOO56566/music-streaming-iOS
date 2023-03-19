//
//  ArticlesDetailsVC.swift
//  DeepSoundiOS
//
//  Created by Muhammad Haris Butt on 6/10/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import DeepSoundSDK
class ArticlesDetailsVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var messageTextField: UITextField!
    var object:GetArticlesModel.Datum? = nil
    var articlesCommentsArray = [GetArticlesCommentsModel.Datum]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.getArticleComments()
    }
    private func setupUI(){
        self.title = self.object?.title ?? ""
        
        self.tableView.separatorStyle = .none
        tableView.register(R.nib.articlesSectionOneTableItem(), forCellReuseIdentifier: R.reuseIdentifier.articlesSectionOneTableItem.identifier)
        tableView.register(R.nib.articlesSectionTwoTableItem(), forCellReuseIdentifier: R.reuseIdentifier.articlesSectionTwoTableItem.identifier)
        tableView.register(R.nib.articleSectionThreeTableItem(), forCellReuseIdentifier: R.reuseIdentifier.articleSectionThreeTableItem.identifier)
        tableView.register(R.nib.articlesSectionFourTableItem(), forCellReuseIdentifier: R.reuseIdentifier.articlesSectionFourTableItem.identifier)
//        tableView.register(UINib(), forCellReuseIdentifier: "ArticleSectionFiveTableItem")
        tableView.register(UINib(nibName: "ArticleSectionFiveTableItem", bundle: nil), forCellReuseIdentifier: "ArticleSectionFiveTableItem")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    @IBAction func sendPressed(_ sender: Any) {
        self.createArticle()
    }
    
    private func getArticleComments(){
        if Connectivity.isConnectedToNetwork(){
            self.articlesCommentsArray.removeAll()
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            let accessToken = AppInstance.instance.accessToken ?? ""
            let id = object?.id ?? "0"
            
            Async.background({
                ArticlesManager.instance.getArticlesComments(AccessToken: accessToken, id:Int(id)!,limit: 10, offset: 0) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.articlesCommentsArray = success?.data ?? []
                                log.debug("userList = \(success?.data ?? [])")
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
                }
                
            })
            
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
    private func createArticle(){
        if Connectivity.isConnectedToNetwork(){
            self.articlesCommentsArray.removeAll()
            self.showProgressDialog(text: (NSLocalizedString("Loading...", comment: "")))
            let accessToken = AppInstance.instance.accessToken ?? ""
            let id = object?.id ?? "0"
            let text = self.messageTextField.text ?? ""
            
            Async.background({
                ArticlesManager.instance.createArticleComment(AccessToken: accessToken, id: Int(id)!, text: text) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                self.messageTextField.text = ""
                                self.getArticleComments()
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
                }
                
            })
            
        }else{
            log.error("internetError = \(InterNetError)")
            self.view.makeToast(InterNetError)
        }
    }
}
extension ArticlesDetailsVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
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
            return self.articlesCommentsArray.count ?? 0
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articlesSectionOneTableItem.identifier) as? ArticlesSectionOneTableItem
            cell?.selectionStyle = .none
            cell!.bind(self.object?.thumbnail ?? "")
            
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articlesSectionTwoTableItem.identifier) as? ArticlesSectionTwoTableItem
            cell?.selectionStyle = .none
            
            cell!.bind(self.object?.createdAt ?? "")
            return cell!
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articleSectionThreeTableItem.identifier) as? ArticleSectionThreeTableItem
            cell?.selectionStyle = .none
            
            cell!.bind(self.object?.content ?? "")
            return cell!
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.articlesSectionFourTableItem.identifier) as? ArticlesSectionFourTableItem
            cell?.selectionStyle = .none
            
            cell!.bind(self.object?.view ?? "")
            return cell!
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleSectionFiveTableItem") as? ArticleSectionFiveTableItem
            cell?.selectionStyle = .none
            cell!.bind(self.articlesCommentsArray[indexPath.row])
            return cell!
        default:
            return UITableViewCell()
            
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 250
        case 1,2,3,4:
            return UITableView.automaticDimension
        default:
            return UITableView.automaticDimension
        }
        
    }
    
    
}
