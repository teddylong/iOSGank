//
//  CommonDetailViewController.swift
//  swiftMeiZi
//
//  Created by teddy on 4/15/16.
//  Copyright © 2016 teddy. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
import SwiftMoment
import PKHUD
import SwiftyJSON

// 除"福利"页面的其他所有分类详情页面
class CommonDetailViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    // 变量
    var activityIndicatorView: NVActivityIndicatorView!
    var requestType: String!
    var items: Array<GankItem>! = []
    var searchItems: Array<GankItem>! = []
    var times: Int = 1
    var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置搜索Bar
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.placeholder = "搜索真的好了!不骗你!"
        tableView.tableHeaderView = searchController.searchBar
        
        // 设置Loading (颜色以及大小)
        let frame = CGRect(x: (self.view.bounds.width / 2) - (Constants.activityIndicatorWH / 2), y: self.view.bounds.height / 2 - Constants.activityIndicatorWH, width: Constants.activityIndicatorWH, height: Constants.activityIndicatorWH)
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.BallClipRotatePulse)
        activityIndicatorView.color = Constants.activityIndicatorColor
        activityIndicatorView.hidesWhenStopped = true
        
        // 加入到view中
        self.view.addSubview(activityIndicatorView)
        
        // 开始显示Loading
        activityIndicatorView.startAnimation()
        
        // Nav的Title
        self.navigationItem.title = requestType
        self.navigationController?.navigationBar.translucent = true
        
        // 设置TableView样式
        tableView.backgroundColor = Constants.statusBackColor
        tableView.registerNib(UINib(nibName: "CommonTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomCommonCell")
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .None
        
        // 获取数据
        getData(requestType)
    }

    // 更新搜索结果 (暂时不用,因为是搜索网络数据,所以每次输入都搜索很浪费)
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        //filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String) {
        // Nothing
    }
    
    // 搜索URL转换
    func getSearchTypeByRequestType(type: String) -> String {
        
        // 初始化返回值
        var result: String = ""
        
        switch type {
            case "APK":
                result = "Android"
            case "iOS":
                result = "iOS"
            case "拓展资源":
                result = "拓展资源"
            case "前端":
                result = "前端"
            case "瞎推荐":
                result = "瞎推荐"
            default:
                result = "iOS"
        }
        
        // 返回
        return result
    }
    
    // 点击搜索按钮
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        // 获得焦点
        searchBar.resignFirstResponder()
        
        // 获取搜索关键字,如有中文,转义
        let searchText: String = (searchBar.text?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()))!
        
        // 搜索URL转换
        let searchType = getSearchTypeByRequestType(requestType)
        
        // 拼接 URL
        let requestURL = Constants.searchPre + searchText + "/category/" + searchType + "/count/20/page/1"
        
        // 再次转义
        let searchURL: String = (requestURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()))!

        // 设置Loading
        HUD.show(HUDContentType.Label("别着急,我慢慢找呢..."))
            
        // 开始请求
        Alamofire.request(.GET, searchURL).responseJSON{ response in
            
            // DEBUG
            print (searchURL)
            
            // 判断返回
            if (response.result.value != nil) {
                
                // 解析返回JSON
                if let valueSearch = response.result.value {
                    
                    // JSON entity
                    let jsonSearch = JSON(valueSearch)
            
                    // 分类内容
                    let searchResult = jsonSearch["results"]
                
                    // 内容Array
                    var contentArray: Array<GankItem> = []
                
                    // Array
                    for (_,subJsonDic):(String, JSON) in searchResult {
                    
                        // 填充Gank实体类
                        let searchItem = GankItem()
                        searchItem.desc = subJsonDic["desc"].rawString()
                        searchItem.publishedAt = subJsonDic["publishedAt"].rawString()
                        searchItem.type = subJsonDic["type"].rawString()
                        searchItem.url = subJsonDic["url"].rawString()
                        searchItem.who = subJsonDic["who"].rawString()
                        searchItem.readability = subJsonDic["readability"].rawString()
                        contentArray.append(searchItem)
                    }
                        
                    // 赋值 搜索结果
                    self.searchItems = contentArray
                }
                    
                // 切换到SearchResult Cell
                self.tableView.registerNib(UINib(nibName: "SearchResultTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchResultCell")
            
                // table 重新绘制
                self.tableView.reloadData()
            
                // Loading消失
                HUD.hide()
            }
        }
    }
    
    // 点击search的cancel按钮
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = .Default
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 添加PageView - 分类详情 - appear
        MobClick.beginLogPageView("分类详情 - " + requestType);
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
        // 添加PageView - 分类详情 - disappear
        MobClick.endLogPageView("分类详情 - " + requestType);
    }
    
    // 获取数据
    func getData(type: String) -> () {
        
        // 初始化URL
        var requestURL: String? = ""
        
        if(type != "") {
            switch type {
                case "iOS":
                    requestURL = Constants.alliOSPre
                case "APK":
                    requestURL = Constants.allAndroidPre
                case "休息视频":
                    requestURL = Constants.allXiuXiPre
                case "拓展资源":
                    requestURL = Constants.allTuoZhanPre
                case "前端":
                    requestURL = Constants.allFrontPre
                case "瞎推荐":
                    requestURL = Constants.allTuijian
                default:
                    requestURL = Constants.allPre
            }
        }
        
        // 第一页URL
        requestURL = requestURL! + Constants.firstPageNumberString
        
        Alamofire.request(.GET, requestURL!).responseJSON{ response in
            
            // 解析返回
            if let responseResult = response.result.value {
                
                // 转Json
                let jsonEntity = JSON(responseResult)
                
                // results列表
                let gankList = jsonEntity["results"]
                
                // 内容Array
                var contentArray: Array<GankItem> = []
                
                // 遍历
                for (_,subJsonArray):(String, JSON) in gankList {
                    
                    // 填充Gank实体类
                    let singleItem = GankItem()
                    singleItem.createdAt = subJsonArray["createdAt"].rawString()
                    singleItem.desc = subJsonArray["desc"].rawString()
                    singleItem.id = subJsonArray["_id"].rawString()
                    singleItem.publishedAt = subJsonArray["publishedAt"].rawString()
                    singleItem.source = subJsonArray["source"].rawString()
                    singleItem.type = subJsonArray["type"].rawString()
                    singleItem.url = subJsonArray["url"].rawString()
                    singleItem.who = subJsonArray["who"].rawString()
                        
                    // 添加到内容Array
                    contentArray.append(singleItem)
                }
                
                // 赋值到全局变量
                self.items = contentArray
            }

            // 开始显示页面
            self.setupUI()
        }
    }
    
    // 准备UI
    func setupUI() -> () {
        // 取消Loading状态
        activityIndicatorView.stopAnimation()
        
        // 这个时候已经把数据源更新了，所以要再reload一次，之前初始化tableview的时候load那次没有数据
        tableView.reloadData()
    }
    
    // cell高度
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    // 返回每个section内的条数
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // 判断是否在搜索状态
        if (searchController.active && searchController.searchBar.text != "") {
            return searchItems.count
        } else {
            return items.count
        }
    }
    
    // 返回Table每一行
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // 临时Items,用来区别 正常的Item以及搜索结果的Item
        var tempItems: Array<GankItem>! = []
        
        // 判断是否在搜索状态
        if searchController.active && searchController.searchBar.text != "" {
            
            // 获取搜索结果
            tempItems = searchItems
            
            // 搜索结果的重用cell
            let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultCell", forIndexPath: indexPath) as! SearchResultTableViewCell
            
            // 如果有搜索结果
            if (tempItems.count > 0) {
            
                // 获取row
                let row: Int = indexPath.row
                
                // 设置标题
                cell.titleLabel.text = tempItems[row].desc
                
                // 取时间
                let timeMoment = moment() - moment(tempItems[row].publishedAt!)!
                
                // 设置时间
                if (timeMoment.hours < 24) {
                    cell.timeLabel.text = String(Int(timeMoment.hours)) + " 小时前"
                } else {
                    cell.timeLabel.text = String(Int(timeMoment.days)) + " 天前"
                }
                
                // 设置推荐者
                if (tempItems[row].who != nil) {
                    cell.writerLabel.text = "推荐人: " + tempItems[row].who!
                } else {
                    cell.writerLabel.text = "推荐人: 可能是雷锋吧:)"
                }
                
                // 设置所有字体大小
                cell.titleLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
                cell.timeLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
                cell.writerLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
                
                // 设置转载网站logo
                if ((tempItems[row].url?.rangeOfString("github.com")) != nil) {
                    cell.logo?.image = UIImage(named: "github_logo")
                } else if ((tempItems[row].url?.rangeOfString("jianshu.com")) != nil) {
                    cell.logo?.image = UIImage(named: "jianshu_logo")
                } else if ((tempItems[row].url?.rangeOfString("github.io")) != nil) {
                    cell.logo?.image = UIImage(named: "github-pages")
                } else if ((tempItems[row].url?.rangeOfString("mp.weixin.qq")) != nil) {
                    cell.logo?.image = UIImage(named: "weixin_logo")
                } else if ((tempItems[row].url?.rangeOfString("csdn.net")) != nil) {
                    cell.logo?.image = UIImage(named: "csdn_logo")
                } else if ((tempItems[row].url?.rangeOfString("pan.baidu")) != nil) {
                    cell.logo?.image = UIImage(named: "baiduyun_logo")
                } else if ((tempItems[row].url?.rangeOfString("bilibili.com")) != nil) {
                    cell.logo?.image = UIImage(named: "bilibili_logo")
                } else if ((tempItems[row].url?.rangeOfString("zhihu.com")) != nil) {
                    cell.logo?.image = UIImage(named: "zhihu_logo")
                } else {
                    cell.logo.image = nil
                }
                
            } else {
                // To-do: 设置没有搜索结果的页面, 但是Gank的搜索好像一直都会有结果 :)
            }
            
            return cell
            
        } else {
            
            // 正常展示页面
            tempItems = items
            
            // 正常展示结果的重用cell
            let cell = tableView.dequeueReusableCellWithIdentifier("CustomCommonCell", forIndexPath: indexPath) as! CommonTableViewCell
            
            // 获取row
            let row: Int = indexPath.row
            
            // 设置标题
            cell.titleLabel.text = tempItems[row].desc
            
            // 取时间
            let timeMoment = moment() - moment(tempItems[row].createdAt!)!
            
            // 设置时间
            if (timeMoment.hours < 24) {
                cell.timeLabel.text = String(Int(timeMoment.hours)) + " 小时前"
            } else {
                cell.timeLabel.text = String(Int(timeMoment.days)) + " 天前"
            }
            
            // 设置推荐者
            if (tempItems[row].who != nil) {
                cell.writerLabel.text = "推荐人: " + tempItems[row].who!
            } else {
                cell.writerLabel.text = "推荐人: 可能是雷锋吧:)"
            }
            
            // 设置所有字体大小
            cell.titleLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
            cell.timeLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
            cell.writerLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
            
            // 设置转载网站logo
            if ((tempItems[row].url?.rangeOfString("github.com")) != nil) {
                cell.logo?.image = UIImage(named: "github_logo")
            } else if ((tempItems[row].url?.rangeOfString("jianshu.com")) != nil) {
                cell.logo?.image = UIImage(named: "jianshu_logo")
            } else if ((tempItems[row].url?.rangeOfString("github.io")) != nil) {
                cell.logo?.image = UIImage(named: "github-pages")
            } else if ((tempItems[row].url?.rangeOfString("mp.weixin.qq")) != nil) {
                cell.logo?.image = UIImage(named: "weixin_logo")
            } else if ((tempItems[row].url?.rangeOfString("csdn.net")) != nil) {
                cell.logo?.image = UIImage(named: "csdn_logo")
            } else if ((tempItems[row].url?.rangeOfString("pan.baidu")) != nil) {
                cell.logo?.image = UIImage(named: "baiduyun_logo")
            } else if ((tempItems[row].url?.rangeOfString("bilibili.com")) != nil) {
                cell.logo?.image = UIImage(named: "bilibili_logo")
            } else if ((tempItems[row].url?.rangeOfString("zhihu.com")) != nil) {
                cell.logo?.image = UIImage(named: "zhihu_logo")
            } else {
                cell.logo.image = nil
            }
            
            // 返回cell
            return cell
        }
    }

    // 返回section数量
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // 点击tableview cell进入web view展示页面
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // 临时Items,用来区别 正常的Item以及搜索结果的Item
        var tempItems: Array<GankItem>! = []
        
        // 判断是否在搜索状态
        if searchController.active && searchController.searchBar.text != "" {
            
            // 获取搜索结果
            tempItems = searchItems
        } else {
            
            // 正常展示页面
            tempItems = items
        }
        
        // 获取页面url
        let selectGankItemUrl: String = tempItems[indexPath.row].url!
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let destination = storyboard.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        
        // 设置页面跳转方式
        destination.modalTransitionStyle = .CrossDissolve
        destination.url = selectGankItemUrl
        
        // 跳转
        self.presentViewController(destination, animated: true, completion: nil)
    }
    
    // 判断tableview是否滑到了底部
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        // 判断当前table中是否有cell
        if (tableView.visibleCells.count > 0) {
            
            // 判断可见的cell是哪种类型,如果是搜索状态的就不用获取更多数据
            if((tableView.visibleCells[0].isKindOfClass(CommonTableViewCell))) {
            
                if(scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height) {
                
                    // 获取页码
                    times = times + 1
                
                    // tableview位置偏移
                    tableView.contentInset = UIEdgeInsets(top: 0,left: 0,bottom: 60,right: 0)
                
                    // Loading显示
                    HUD.show(.Label("加载更多..."))
                
                    // 取数据
                    getMoreData(requestType,time: times)
                }
            }
        }
    }
    
    // 加载更多数据方法
    func getMoreData(type: String, time: Int) -> () {
        var requestURL: String? = ""
        if(type != "") {
            switch type {
            case "iOS":
                requestURL = Constants.alliOSPre
            case "APK":
                requestURL = Constants.allAndroidPre
            case "休息视频":
                requestURL = Constants.allXiuXiPre
            case "拓展资源":
                requestURL = Constants.allTuoZhanPre
            case "前端":
                requestURL = Constants.allFrontPre
            default:
                requestURL = Constants.allPre
            }
        }
        requestURL = requestURL! + String(time)
        Alamofire.request(.GET, requestURL!).responseJSON{ response in
            
            // 解析返回JSON
            if let responseResult = response.result.value {
                
                // 转Json
                let jsonEntity = JSON(responseResult)
                
                // results列表
                let gankList = jsonEntity["results"]
                
                // 遍历
                for (_,subJsonArray):(String, JSON) in gankList {
                    
                    // 填充Gank实体类
                    let singleItem = GankItem()
                    singleItem.createdAt = subJsonArray["createdAt"].rawString()
                    singleItem.desc = subJsonArray["desc"].rawString()
                    singleItem.id = subJsonArray["_id"].rawString()
                    singleItem.publishedAt = subJsonArray["publishedAt"].rawString()
                    singleItem.source = subJsonArray["source"].rawString()
                    singleItem.type = subJsonArray["type"].rawString()
                    singleItem.url = subJsonArray["url"].rawString()
                    singleItem.who = subJsonArray["who"].rawString()
                    
                    // 添加到Items中
                    self.items.append(singleItem)
                }
            }

            // 开始显示页面
            self.tableView.reloadData()
            self.tableView.contentInset = UIEdgeInsets(top: 63,left: 0,bottom: 0,right: 0)
            
            HUD.hide()
        }
    }
}
