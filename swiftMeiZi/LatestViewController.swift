//
//  FirstViewController.swift
//  swiftMeiZi
//
//  Created by teddy on 4/5/16.
//  Copyright © 2016 teddy. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import NVActivityIndicatorView
import LTMorphingLabel
import SKPhotoBrowser
import MXParallaxHeader
import SwiftMoment
import AlamofireImage
import SwiftyJSON

// 首页
class LatestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SKPhotoBrowserDelegate {
    
    // 变量
    var daily: Daily = Daily()
    var mainImageView = UIImageView()
    var mainTableView = UITableView()
    var activityIndicatorView: NVActivityIndicatorView!
    var fuliImageURL: String = ""
    var mainPhotos = [SKPhoto]()
    
    // 开始
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        // 自定义status bar
        let addStatusBar = UIView()
        
        // status bar的大小，位置
        addStatusBar.frame = CGRectMake(Constants.zeroCGFloat, Constants.zeroCGFloat, self.view.bounds.width, Constants.statusBarHeight)
        
        // status bar的背景颜色
        addStatusBar.backgroundColor = Constants.statusBackColor
        
        // 添加status bar到主页面
        view.addSubview(addStatusBar)
        
        // 设置Loading (颜色以及大小)
        let frame = CGRect(x: (self.view.bounds.width / 2) - (Constants.activityIndicatorWH / 2), y: self.view.bounds.height / 2 - (Constants.activityIndicatorWH / 2), width: Constants.activityIndicatorWH, height: Constants.activityIndicatorWH)
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.BallClipRotatePulse)
        activityIndicatorView.color = Constants.activityIndicatorColor
        activityIndicatorView.hidesWhenStopped = true
        
        // 加入到view中
        self.view.addSubview(activityIndicatorView)
        
        // 开始显示Loading
        activityIndicatorView.startAnimation()
        
        // 开始获取数据并显示页面
        getLatestData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 添加PageView - 最新 - appear
        MobClick.beginLogPageView("最新");
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // 添加PageView - 最新 - disappear
        MobClick.endLogPageView("最新");
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // 根据History获取最新日期的内容
    internal func getLatestData() -> () {
        
        // 清空daily
        daily = Daily()
        // 创建临时daily
        let dailyTMP = Daily()
        
        // 获取History列表
        Alamofire.request(.GET, Constants.historyURL).responseJSON{ response in
            
            // 解析返回JSON
            if let valueDate = response.result.value  {
                
                // JSON entity
                let jsonDate = JSON(valueDate)
                
                // 获取最新日期
                let latestDateJson: String = jsonDate["results"][0].stringValue
                let latestDateJson2: String = latestDateJson.stringByReplacingOccurrencesOfString("-", withString: "/")
                
                Alamofire.request(.GET, Constants.dailyPre + latestDateJson2).responseJSON { response in
                    
                    // 解析返回JSON
                    if let valueDaily = response.result.value {
                        
                        // JSON entity
                        let jsonDaily = JSON(valueDaily)
                        
                        // 分类列表
                        let cateList = jsonDaily["category"]
                        
                        // 初始化 除去"福利"的可变列表
                        let cateListNoFuli: NSMutableArray = []
                        
                        // 填充 除去"福利"的列表
                        for (_,subJson):(String, JSON) in cateList {
                            if(subJson.rawString()! != Constants.fuliChinese) {
                                cateListNoFuli.addObject(subJson.rawString()!)
                            }
                        }
                     
                        // 深copy
                        let cateNoFuli: NSArray = cateListNoFuli.copy() as! NSArray
                        dailyTMP.category = cateNoFuli
                        
                        // 分类内容
                        let contentList = jsonDaily["results"]
                        
                        // 内容Array
                        var contentArray: Array<GankItem> = []
                        
                        // Array
                        for (_,subJsonArray):(String, JSON) in contentList {
                            
                            // Dictionary
                            for (_, subJsonDic): (String, JSON) in subJsonArray {
                                
                                // 填充Gank实体类
                                let singleItem = GankItem()
                                
                                singleItem.createdAt = subJsonDic["createdAt"].rawString()
                                singleItem.desc = subJsonDic["desc"].rawString()
                                singleItem.id = subJsonDic["_id"].rawString()
                                singleItem.publishedAt = subJsonDic["publishedAt"].rawString()
                                singleItem.source = subJsonDic["source"].rawString()
                                singleItem.type = subJsonDic["type"].rawString()
                                singleItem.url = subJsonDic["url"].rawString()
                                singleItem.who = subJsonDic["who"].rawString()
                                
                                // 添加到内容Array
                                contentArray.append(singleItem)
                            }
                        }
                        
                        // 把content赋给临时的daily
                        dailyTMP.results = contentArray
                        
                        // 获取数据写入到全局变量daily, 到此, 数据已加载完毕
                        self.daily = dailyTMP
    
                        // 开始显示页面
                        self.setupUI()
                    }
                }
            }
        }
    }
    
    // 准备显示UI
    internal func setupUI() -> () {
        
        // 取消Loading状态
        activityIndicatorView.stopAnimation()
        
        // 获得首页福利大图地址
        let dailyResults: Array<GankItem> = self.daily.results
        
        // 遍历每一个GankItem取得其中的福利地址URL
        for item in dailyResults {
            if (item.type == Constants.fuliChinese) {
                fuliImageURL = item.url!
                break
            }
        }
        
        mainImageView.removeFromSuperview()
        //mainTableView.removeFromSuperview()
        
        // 设置主TableView
        let tableRect: CGRect = CGRect(x: Constants.zeroCGFloat, y: 21, width: self.view.bounds.width, height: self.view.bounds.height)
        self.mainTableView = UITableView(frame: tableRect, style: UITableViewStyle.Grouped)
        self.mainTableView.dataSource = self
        self.mainTableView.delegate = self
        self.mainTableView.registerNib(UINib(nibName: "LatestTableViewCell", bundle: nil), forCellReuseIdentifier: "LatestTableViewCell")
        self.mainTableView.showsVerticalScrollIndicator = false
        self.mainTableView.separatorStyle = .None
        self.mainTableView.backgroundColor = UIColor(hexString: "2B3347")
        
        // 添加福利大图到首页ImageView中
        mainImageView = UIImageView()
        
        // 填充模式 - ScaleAspectFill
        mainImageView.contentMode = .ScaleAspectFill
        
        // 多余的部分截掉
        mainImageView.clipsToBounds = true
        
        // 图片大小以及位置
        let imageFrame: CGRect = CGRect(x: Constants.zeroCGFloat, y: Constants.zeroCGFloat, width: self.view.bounds.width, height: Constants.homeImageViewHeight)
        mainImageView.frame = imageFrame
        
        // 根据地址请求图片
        mainImageView.af_setImageWithURL(
            NSURL(string: fuliImageURL)!,
            placeholderImage: nil,
            imageTransition: .CrossDissolve(0.5)
        )
        
        // Image View Mask
        mainImageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        // Image View Header 设置
        self.mainTableView.parallaxHeader.view = mainImageView
        self.mainTableView.parallaxHeader.height = mainImageView.frame.height
        self.mainTableView.parallaxHeader.mode = MXParallaxHeaderMode.Fill
        self.mainTableView.parallaxHeader.minimumHeight = 0
        
        // 添加TableView
        view.addSubview(mainTableView)
        
        // 为TableView添加点击手势
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LatestViewController.homeImageClick))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        mainImageView.userInteractionEnabled = true
        mainImageView.addGestureRecognizer(singleTap)
        
        // 添加刷新按钮 
        let refreshBtnFrame: CGRect = CGRect(x: self.view.bounds.width - 15 - Constants.refreshBtnWH, y: 15, width: Constants.refreshBtnWH, height: Constants.refreshBtnWH)
        let refreshBtn: UIButton = UIButton(frame: refreshBtnFrame)
        refreshBtn.setImage(UIImage(named: "refresh"), forState: .Normal)
        refreshBtn.addTarget(self, action: #selector(LatestViewController.refreshAll), forControlEvents: .TouchUpInside)
        mainImageView.addSubview(refreshBtn)
        
        HUD.hide()
    }
    
    // 进入report页面
    func startReport() -> () {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let destination = storyboard.instantiateViewControllerWithIdentifier("ReportViewController") as! ReportViewController
        destination.modalTransitionStyle = .CrossDissolve
        self.presentViewController(destination, animated: true, completion: nil)
    }
    
    // 刷新页面
    func refreshAll() -> () {
        HUD.show(.Label("刷新中..."))
        self.getLatestData()
    }
    
    // 点击福利图看大图
    func homeImageClick () -> () {
        
        // 初始化SKPhoto
        var image = [SKPhoto]()
        
        // 添加photo
        let photo = SKPhoto.photoWithImageURL(fuliImageURL)
        photo.shouldCachePhotoURLImage = false
        image.append(photo)
        self.mainPhotos = image
        
        // 设置SKPhoto的选项. 现在有2个选项: 下载 和 举报
        let browser = SKPhotoBrowser(photos: image)
        browser.delegate = self
        browser.statusBarStyle = nil
        browser.bounceAnimation = true
        browser.actionButtonTitles = ["下载", "举报"]
        
        // 弹出SKPhoto
        presentViewController(browser, animated: true, completion: {})
    }
    
    // 自定义图片选项
    func didDismissActionSheetWithButtonIndex(buttonIndex: Int, photoIndex: Int) {
        // 举报
        if (buttonIndex == 1) {
            dispatch_async(dispatch_get_main_queue(), {
                self.dismissViewControllerAnimated(true, completion: {});
                self.startReport()
            })
        }
        // 下载
        else {
            UIImageWriteToSavedPhotosAlbum(self.mainImageView.image!, self, #selector(LatestViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    // 下载完成或出错
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            HUD.flash(.Label("已下载!"), delay: 1.5)
        } else {
            HUD.flash(.Label("下载出错!"), delay: 1.5)
        }
    }
    
    // 返回每个section内的条数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // 获取当前section的名称
        let sectionName: String = self.daily.category[section] as! String
        var num: Int = 0
        
        // 遍历所有的gankitem, 取得当前section名称的数量
        for gank in daily.results {
            if (gank.type == sectionName) {
                num = num + 1
            }
        }
        return num
    }
    
    // 返回Table每一行
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // cell重用
        let cell = tableView.dequeueReusableCellWithIdentifier("LatestTableViewCell", forIndexPath: indexPath) as! LatestTableViewCell
        
        // 取得cell的section和row来确定每一个gank
        let section: Int = indexPath.section
        let row: Int = indexPath.row
        let sectionName: String = self.daily.category[section] as! String
        let tempArray: NSMutableArray = []
        
        for gank in daily.results {
            if (gank.type == sectionName) {
                tempArray.addObject(gank)
            }
        }
        
        // 设置标题
        cell.titleLabel.text = (tempArray[row] as! GankItem).desc
        
        // 取时间
        let timeMoment = moment() - moment((tempArray[row] as! GankItem).createdAt!)!
        
        // 设置时间
        if (timeMoment.hours < 24) {
            cell.timeLabel.text = String(Int(timeMoment.hours)) + " 小时前"
        } else {
            cell.timeLabel.text = String(Int(timeMoment.days)) + " 天前"
        }
        
        // 设置推荐者
        if ((tempArray[row] as! GankItem).who != nil) {
            cell.writerLabel.text = "推荐人: " + (tempArray[row] as! GankItem).who!
        } else {
            cell.writerLabel.text = "推荐人: 可能是雷锋吧:)"
        }
        
        // 设置所有字体大小
        cell.titleLabel.font = UIFont.boldSystemFontOfSize(UIFont.smallSystemFontSize())
        cell.timeLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        cell.writerLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        
        
        // 设置转载网站logo
        if (((tempArray[row] as! GankItem).url?.rangeOfString("github.com")) != nil) {
            cell.logo?.image = UIImage(named: "github_logo")
        } else if (((tempArray[row] as! GankItem).url?.rangeOfString("jianshu.com")) != nil) {
            cell.logo?.image = UIImage(named: "jianshu_logo")
        } else if (((tempArray[row] as! GankItem).url?.rangeOfString("github.io")) != nil) {
            cell.logo?.image = UIImage(named: "github-pages")
        } else if (((tempArray[row] as! GankItem).url?.rangeOfString("mp.weixin.qq")) != nil) {
            cell.logo?.image = UIImage(named: "weixin_logo")
        } else if (((tempArray[row] as! GankItem).url?.rangeOfString("csdn.net")) != nil) {
            cell.logo?.image = UIImage(named: "csdn_logo")
        } else if (((tempArray[row] as! GankItem).url?.rangeOfString("pan.baidu")) != nil) {
            cell.logo?.image = UIImage(named: "baiduyun_logo")
        } else if (((tempArray[row] as! GankItem).url?.rangeOfString("bilibili.com")) != nil) {
            cell.logo?.image = UIImage(named: "bilibili_logo")
        } else if (((tempArray[row] as! GankItem).url?.rangeOfString("zhihu.com")) != nil) {
            cell.logo?.image = UIImage(named: "zhihu_logo")
        } else {
            cell.logo.image = nil
        }
        
        // 返回cell
        return cell
    }
    
    // 返回Section个数
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.daily.category.count
    }
    
    // 返回header的高度
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    // 返回cell的高度
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    // 自定义section的header
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var sectionName: String = self.daily.category[section] as! String
        
        // android字样的app去提交审核,会被拒绝,所以更改一下
        if (sectionName == "Android") {
            sectionName = "APK"
        }
        
        let sectionView: MyHeaderView = MyHeaderView()
        sectionView.label.text = sectionName
        
        // 根据section来选择header的图片
        switch sectionName {
            
            case "APK":
                sectionView.imageView.image = UIImage(named: "APK")
            case "iOS":
                sectionView.imageView.image = UIImage(named: "iOS")
            case "福利":
                sectionView.imageView.image = UIImage(named: "fuli")
            case "App":
                sectionView.imageView.image = UIImage(named: "App")
            case "休息视频":
                sectionView.imageView.image = UIImage(named: "xiuxi")
            case "拓展资源":
                sectionView.imageView.image = UIImage(named: "tuozhan")
            case "前端":
                sectionView.imageView.image = UIImage(named: "front")
            default:
                sectionView.imageView.image = UIImage(named: "default")
        }
        return sectionView
    }
    
    // 点击tableview的事件
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // 取得cell的section和row
        let section: Int = indexPath.section
        let row: Int = indexPath.row
        
        // 根据section取到category的名字
        let sectionName: String = self.daily.category[section] as! String
        let tempArray: NSMutableArray = []
        
        // 把相应section下面的gank都存到临时Array中
        for gank in daily.results {
            if (gank.type == sectionName) {
                tempArray.addObject(gank)
            }
        }
        
        // 根据row来取到对应是哪个gank, 拿到gank对应的文章URL
        let selectGankItemUrl: String = (tempArray[row] as! GankItem).url!
        
        // 实例化Web ViewController
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let destination = storyboard.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        destination.modalTransitionStyle = .CrossDissolve
        
        // 传url值过去
        destination.url = selectGankItemUrl
        
        // 展示
        self.presentViewController(destination, animated: true, completion: nil)
    }
}

