//
//  RandomViewController.swift
//  swiftMeiZi
//
//  Created by teddy on 4/6/16.
//  Copyright © 2016 teddy. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SKPhotoBrowser
import DGElasticPullToRefresh
import LTMorphingLabel
import NVActivityIndicatorView
import SwiftMoment
import PKHUD

class RandomViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SKPhotoBrowserDelegate, UITableViewDelegate, UITableViewDataSource  {

    // 定义collection
    var fuliCollectionView: UICollectionView!
    
    // 定义collection的数据源
    var fuliArray: [String] = []
    
    // 定义tableview
    var randomTableView: UITableView!
    
    // 定义tableview的数据源
    var randomArray: Array<GankItem> = []
    
    // 定义tableview的URL数据源，为了gank.io的随机API的bug
    var randomUrlArray: [String] = []
    
    // 待下载图片的URL地址
    var tempImageURL = ""
    
    var activityIndicatorViewInCollection: NVActivityIndicatorView!
    var activityIndicatorViewInTable: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 自定义status bar
        let addStatusBar = UIView()
        // status bar的大小，位置
        addStatusBar.frame = CGRectMake(0, 0, self.view.bounds.width, 22);
        // status bar的背景颜色
        addStatusBar.backgroundColor = UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0)
        // 添加status bar到主页面
        view.addSubview(addStatusBar)
        
        
        self.OnLineOrOffLine()
        
        
    }
    
    deinit {
        fuliCollectionView.dg_removePullToRefresh()
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if (event?.subtype == UIEventSubtype.MotionShake) {
            getRandomData()
        }
    }
    
    
    func OnLineOrOffLine() -> () {
        Alamofire.request(.GET, "http://www.teddylong.net/switchGank.php").responseString { response in
            if (response.result.value! == "offline") {
                
                // 设置主TableView
                let tableRect: CGRect = CGRect(x: 0, y: 22, width: self.view.bounds.width, height: self.view.bounds.height - 20)
                self.randomTableView = UITableView(frame: tableRect, style: UITableViewStyle.Plain)
                self.randomTableView.dataSource = self
                self.randomTableView.delegate = self
                self.randomTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
                
                let tableHeaderViewFrame: CGRect = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 20)
                let tableHeaderView: UIView = UIView(frame: tableHeaderViewFrame)
                tableHeaderView.backgroundColor = UIColor.whiteColor()
                
                let labelFrame: CGRect = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 20)
                let label: UILabel = UILabel(frame: labelFrame)
                label.text = "摇一摇刷新随机文章"
                label.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
                label.textAlignment = .Center
                tableHeaderView.addSubview(label)
                
                self.randomTableView.tableHeaderView = tableHeaderView
                
                // 添加tableview到view中
                self.view.addSubview(self.randomTableView)
                
                // 请求非fuli数据
                self.getRandomData()
            }
            else {
                // 设置collection
                let fuliLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                fuliLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                
                // 初始化collection
                let fuliFrame: CGRect = CGRect(x: 0, y: 22, width: self.view.bounds.width, height: self.view.bounds.height / 2)
                self.fuliCollectionView = UICollectionView(frame: fuliFrame, collectionViewLayout: fuliLayout)
                self.fuliCollectionView.dataSource = self
                self.fuliCollectionView.delegate = self
                self.fuliCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
                self.fuliCollectionView.backgroundColor = UIColor.whiteColor()
                
                // 注册collection的header
                self.fuliCollectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "collectionHeader")
                
                // 如果不设置，则还是看不到collection的header
                let flow = self.fuliCollectionView!.collectionViewLayout as! UICollectionViewFlowLayout
                flow.headerReferenceSize = CGSizeMake(30,30)
                
                // 设置TableView的下拉刷新
                let loadingView = DGElasticPullToRefreshLoadingViewCircle()
                loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
                self.fuliCollectionView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
                    self!.getFuliData()
                    self?.fuliCollectionView.dg_stopLoading()
                    }, loadingView: loadingView)
                self.fuliCollectionView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
                self.fuliCollectionView.dg_setPullToRefreshBackgroundColor(self.fuliCollectionView.backgroundColor!)
                
                // 设置collection的auto resize，针对高度，如果不设置layout会有问题
                self.fuliCollectionView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
                
                // 添加collection到view中
                self.view.addSubview(self.fuliCollectionView)
                
                
                // 设置主TableView
                let tableRect: CGRect = CGRect(x: 0, y: self.view.bounds.height / 2, width: self.view.bounds.width, height: self.view.bounds.height / 2)
                self.randomTableView = UITableView(frame: tableRect, style: UITableViewStyle.Plain)
                self.randomTableView.dataSource = self
                self.randomTableView.delegate = self
                self.randomTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
                
                let tableHeaderViewFrame: CGRect = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 20)
                let tableHeaderView: UIView = UIView(frame: tableHeaderViewFrame)
                tableHeaderView.backgroundColor = UIColor.whiteColor()
                
                let labelFrame: CGRect = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 20)
                let label: UILabel = UILabel(frame: labelFrame)
                label.text = "摇一摇刷新随机文章"
                label.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
                label.textAlignment = .Center
                tableHeaderView.addSubview(label)
                
                self.randomTableView.tableHeaderView = tableHeaderView
                
                // 添加tableview到view中
                self.view.addSubview(self.randomTableView)
                
                // 请求fuli数据
                self.getFuliData()
                
                // 请求非fuli数据
                self.getRandomData()
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    // 定义status bar颜色
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    // 返回tableview cell的数量
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return randomArray.count
    }
    
    // 返回tableview section的数量
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    // 返回每个tableview cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        }
        
        cell!.textLabel?.text = randomArray[indexPath.row].desc
        cell?.textLabel?.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        
        cell?.accessoryType = .DisclosureIndicator
        
        cell?.detailTextLabel?.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        
        let timeMoment = moment() - moment(randomArray[indexPath.row].createdAt!)!
        
        if (timeMoment.hours < 24) {
            cell?.detailTextLabel?.text = String(Int(timeMoment.hours)) + " 小时前"
        } else {
            cell?.detailTextLabel?.text = String(Int(timeMoment.days)) + " 天前"
        }
        return cell!
    }
    
    // 点击tableview的事件
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let selectGankItemUrl: String = randomArray[indexPath.row].url!
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let destination = storyboard.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        
        destination.modalTransitionStyle = .CrossDissolve
        
        destination.url = selectGankItemUrl
        
        self.presentViewController(destination, animated: true, completion: nil)
        
    }
    
    // 返回collection cell的数量
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fuliArray.count
    }
    
    // 返回collection cell的大小
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (self.view.bounds.width - 50) / 3, height: (collectionView.bounds.height - 50) / 2)
    }
    
    // 返回collection section数量
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // 返回每个collection cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // 重用cell，但是这个地方没有用到，因为重用是要把cell单拿出去，自定义好，然后只是赋值，没有addsubview的事件，这样才能达到重用的目的，下面的方法是workaround
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as UICollectionViewCell
        
        // 删除cell下面所有的subviews
        for subView in cell.subviews {
            subView.removeFromSuperview()
        }
        
        // 向cell中添加一个image
        let imageFrame: CGRect = CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height)
        let image: UIImageView = UIImageView(frame: imageFrame)
        
        let filter = AspectScaledToFillSizeWithRoundedCornersFilter(
            size: image.frame.size,
            radius: 20.0
        )
        
        image.af_setImageWithURL(NSURL(string: fuliArray[indexPath.row])!, placeholderImage: nil, filter: filter, imageTransition:.CrossDissolve(0.5))
        
        image.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        // 填充模式 - ScaleAspectFill
        image.contentMode = .ScaleAspectFill
        // 多余的部分截掉
        image.clipsToBounds = true
        
        cell.addSubview(image)

        return cell
    }
    
    // 获取Fuli数据
    func getFuliData() -> () {
        
        // 设置Loading (颜色以及大小)
        let frame = CGRect(x: self.view.bounds.width / 2 - 20, y: self.view.bounds.height / 4 - 20, width: 40, height: 40)
        activityIndicatorViewInCollection = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.BallClipRotatePulse)
        activityIndicatorViewInCollection.color = UIColor(red: CGFloat(237 / 255.0), green: CGFloat(85 / 255.0), blue: CGFloat(101 / 255.0), alpha: 1)
        activityIndicatorViewInCollection.hidesWhenStopped = true
        
        // 加入到view中
        self.view.addSubview(activityIndicatorViewInCollection)
        
        // 开始显示Loading
        activityIndicatorViewInCollection.startAnimation()
        
        Alamofire.request(.GET, Constants.randomFuli).responseJSON{ response in
            // 解析返回JSON
            self.fuliArray = []
            if let JSON = response.result.value as? NSDictionary {
                if let results =  JSON["results"] as? NSArray {
                    for temp in results {
                        let imageUrl: String = temp["url"] as! String
                        
                        if (!self.fuliArray.contains(imageUrl)) {
                            self.fuliArray.append(imageUrl)
                            if (self.fuliArray.count == 6) {
                                break
                            }
                        }
                    }
                }
            }
            self.fuliCollectionView.reloadData()
            // 取消Loading状态
            self.activityIndicatorViewInCollection.stopAnimation()
        }
    }
    
    // 获取非福利数据
    func getRandomData() -> () {
        
        // 设置Loading (颜色以及大小)
        let loadingTableFrame = CGRect(x: self.view.bounds.width / 2 - 20, y: self.view.bounds.height - self.view.bounds.height / 4 - 20, width: 40, height: 40)
        activityIndicatorViewInTable = NVActivityIndicatorView(frame: loadingTableFrame, type: NVActivityIndicatorType.BallClipRotatePulse)
        activityIndicatorViewInTable.color = UIColor(red: CGFloat(237 / 255.0), green: CGFloat(85 / 255.0), blue: CGFloat(101 / 255.0), alpha: 1)
        activityIndicatorViewInTable.hidesWhenStopped = true
        
        // 加入到view中
        self.view.addSubview(activityIndicatorViewInTable)
        
        // 开始动画
        activityIndicatorViewInTable.startAnimation()
        
        let randomNumber: Int = Int(arc4random_uniform(4))
        Alamofire.request(.GET, Constants.randomGank[randomNumber]).responseJSON{ response in
            // 解析返回JSON
            self.randomArray = []
            self.randomUrlArray = []
            if let JSON = response.result.value as? NSDictionary {
                if let results =  JSON["results"] as? NSArray {
                    var contentArray: Array<GankItem> = []
                    for item in results {
                        let gankDic: NSDictionary = item as! NSDictionary
                        let xxx = GankItem()
                        if (!self.randomUrlArray.contains(gankDic["url"] as! String)) {
                            xxx.createdAt = gankDic["createdAt"] as? String
                            xxx.desc = gankDic["desc"] as? String
                            xxx.id = gankDic["_id"] as? String
                            xxx.publishedAt = gankDic["publishedAt"] as? String
                            xxx.source = gankDic["source"] as? String
                            xxx.type = gankDic["type"] as? String
                            xxx.url = gankDic["url"] as? String
                            xxx.who = gankDic["who"] as? String
                            contentArray.append(xxx)
                            self.randomUrlArray.append(xxx.url!)
                        }
                    }
                    self.randomArray = contentArray
                }
            }
            self.randomTableView.reloadData()
            // 取消Loading状态
            self.activityIndicatorViewInTable.stopAnimation()
        }
    }
    
    // 返回每个collection view的点击事件
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let imageUrlAddress: String = fuliArray[indexPath.row]
        
        tempImageURL = imageUrlAddress
        
        var image = [SKPhoto]()
        let photo = SKPhoto.photoWithImageURL(imageUrlAddress)
        photo.shouldCachePhotoURLImage = false
        image.append(photo)
        let browser = SKPhotoBrowser(photos: image)
        browser.delegate = self
        browser.statusBarStyle = nil
        browser.bounceAnimation = true
        browser.actionButtonTitles = ["下载", "举报"]
        
        presentViewController(browser, animated: true, completion: {})
    }
    
    // 举报方法
    func startReport() -> () {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let destination = storyboard.instantiateViewControllerWithIdentifier("ReportViewController") as! ReportViewController
        destination.modalTransitionStyle = .CrossDissolve
        self.presentViewController(destination, animated: true, completion: nil)
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
            let url = NSURL(string: self.tempImageURL)
            let data = NSData(contentsOfURL:url!)
            let mainImageView = UIImage(data: data!)
            UIImageWriteToSavedPhotosAlbum(mainImageView!, self, #selector(LatestViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
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
    
    // collection view的header设置 (和TableView是不一样的)
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        // 判断 viewForSupplementaryElementOfKind
        switch kind {
        
        // 如果是Header
        case UICollectionElementKindSectionHeader:
            
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "collectionHeader", forIndexPath: indexPath)
            
            for subview in headerView.subviews {
                subview.removeFromSuperview()
            }
            
            headerView.backgroundColor = UIColor.whiteColor();
            
            let headerFrame: CGRect = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 35)
            headerView.frame = headerFrame
            
            let labelFrame: CGRect = CGRect(x: 0, y: 5, width: self.view.bounds.width, height: 30)
            let label: UILabel = UILabel(frame: labelFrame)
            label.textAlignment=NSTextAlignment.Center
            label.text = "下拉刷新换换福利"
            label.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
            
            let reportBtnFrame: CGRect = CGRect(x: self.view.bounds.width - 10 - 30, y: 10, width: 20, height: 20)
            let reportBtn: UIButton = UIButton(frame: reportBtnFrame)
            reportBtn.setBackgroundImage(UIImage(named: "report"), forState: UIControlState.Normal)
            reportBtn.addTarget(self, action: #selector(WebViewController.reported), forControlEvents: .TouchUpInside)
            
            headerView.addSubview(label)
            headerView.addSubview(reportBtn)
            
            return headerView
            
        default:
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
        }
    }
    
    func reported() -> () {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let destination = storyboard.instantiateViewControllerWithIdentifier("ReportViewController") as! ReportViewController
        destination.modalTransitionStyle = .CrossDissolve
        self.presentViewController(destination, animated: true, completion: nil)
    }
    
}
