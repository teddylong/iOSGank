//
//  WaiBaoViewController.swift
//  swiftMeiZi
//
//  Created by teddy on 6/21/16.
//  Copyright © 2016 teddy. All rights reserved.
//
import Kanna
import Alamofire
import UIKit
import PKHUD
import NVActivityIndicatorView
import LTMorphingLabel
import SKPhotoBrowser
import MXParallaxHeader
import SwiftMoment
import AlamofireImage
import SwiftyJSON

// 外包页面
class WaiBaoViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    // 变量
    var mainImageView = UIImageView()
    var mainTableView = UITableView()
    var activityIndicatorView: NVActivityIndicatorView!
    var items: Array<WaiBao> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置Edge,要不然tableview最后一个cell会被TabBar覆盖住
        self.edgesForExtendedLayout = UIRectEdge.None
        self.automaticallyAdjustsScrollViewInsets = false;
        
        // 自定义status bar
        let addStatusBar = UIView()
        
        // status bar的大小，位置
        addStatusBar.frame = CGRectMake(0, 0, self.view.bounds.width, Constants.statusBarHeight);
        
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 添加PageView - 最新 - appear
        MobClick.beginLogPageView("外包");
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // 添加PageView - 最新 - disappear
        MobClick.endLogPageView("外包");
    }
    
    
    // 返回每个section内的条数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    // 返回Table每一行
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // cell重用
        let cell = tableView.dequeueReusableCellWithIdentifier("WaiBaoTableViewCell", forIndexPath: indexPath) as! WaiBaoTableViewCell
        
        // 取得cell的section和row来确定每一个WaiBao
        let row: Int = indexPath.row
        
        // cell数据填充
        cell.titleLabel.text = items[row].title
        cell.statusLabel.text = items[row].status
        cell.meatLabel.text = items[row].meta
        cell.bodyLabel.text = items[row].body

        // cell状态判定
        switch cell.statusLabel.text! {
        case "进行中":
            cell.statusLabel.textColor = UIColor(hexString: "15b47c")
            cell.statusImg.image = UIImage(named: "jinxingzhong")
        case "成功完成":
            cell.statusLabel.textColor = UIColor(hexString: "e85600")
            cell.statusImg.image = UIImage(named: "chenggongwancheng")
        case "流产":
            cell.statusLabel.textColor = UIColor(hexString: "000")
            cell.statusImg.image = UIImage(named: "liuchan")
        case "正在开发":
            cell.statusLabel.textColor = UIColor(hexString: "00bfff")
            cell.statusImg.image = UIImage(named: "zhengzaikaifa")
        default:
            cell.statusLabel.textColor = UIColor.whiteColor()
        }
        
        // cell内文字字体
        cell.titleLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        cell.meatLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        cell.bodyLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        cell.statusLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        
        // 返回cell
        return cell
    }
    
    // 返回cell的高度
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    // 获取数据
    func getLatestData() -> () {
        
        Alamofire.request(.GET, Constants.waiBaoURL).validate().responseString { response in
            
            let responseString: String = response.result.value!
            
            // 获取waibao页面HTML
            if let doc = Kanna.HTML(html: responseString, encoding: NSUTF8StringEncoding) {
                
                // 页面上每一个外包项目都是在 class="Card"中. 所以遍历所有的card节点
                for card in doc.xpath("//div[@class='card']") {
                    
                    // 创建临时waibao类
                    let temp: WaiBao = WaiBao()
                    
                    // 项目 - title 并处理"\n"以及左右的空格
                    let cardTitle: String = card.xpath(".//h4[@class='card-title']").innerHTML!.stringByReplacingOccurrencesOfString("\n", withString: "").stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    
                    // 项目 - url
                    let cardURL: String = card.xpath(".//a")[0]["href"]!
                    
                    // 项目 - meta 并处理"\n"以及左右的空格
                    let cardMeta: String = card.xpath(".//h6[@class='card-meta']/span[1]").innerHTML!.stringByReplacingOccurrencesOfString("\n", withString: "").stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    
                    // 项目 - Body 并处理"\n"以及左右的空格
                    let cardBody: String = card.xpath(".//div[@class='card-body']").innerHTML!.stringByReplacingOccurrencesOfString("\n", withString: "").stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    
                    // 项目 - status 并处理左右的空格
                    let cardStatus: String = card.xpath(".//div[@class='card-footer']/span[1]").innerHTML!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    
                    // 赋值
                    temp.body = cardBody
                    temp.status = cardStatus
                    temp.title = cardTitle
                    temp.url = "http://waibao.io" + cardURL
                    temp.meta = cardMeta
                    
                    // 添加到Items中
                    self.items.append(temp)
                }
            }
            
            // 展示UI
            self.setupUI()
        }
    }
    
    // 准备显示UI
    internal func setupUI() -> () {
        
        // 取消Loading状态
        activityIndicatorView.stopAnimation()

        // 设置主TableView
        let tableRect: CGRect = CGRect(x: Constants.zeroCGFloat, y: Constants.statusBarHeight, width: self.view.bounds.width, height: self.view.bounds.height - Constants.statusBarHeight)
        self.mainTableView = UITableView(frame: tableRect, style: .Plain)
        self.mainTableView.dataSource = self
        self.mainTableView.delegate = self
        self.mainTableView.registerNib(UINib(nibName: "WaiBaoTableViewCell", bundle: nil), forCellReuseIdentifier: "WaiBaoTableViewCell")
        self.mainTableView.showsVerticalScrollIndicator = false
        self.mainTableView.separatorStyle = .None
        self.mainTableView.backgroundColor = Constants.statusBackColor
        
        // 添加TableView
        view.addSubview(mainTableView)
    }
    
    // 点击tableview的事件
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // 选择取消
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // 获得row
        let row: Int = indexPath.row
        
        // 根据row来取到对应是哪个WaiBao, 拿到WaiBao对应的文章URL
        let selectWaiBaoItemUrl: String = items[row].url!
        
        // 实例化Web ViewController
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let destination = storyboard.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        destination.modalTransitionStyle = .CrossDissolve
        
        // 传url值过去
        destination.url = selectWaiBaoItemUrl
        
        // 展示
        self.presentViewController(destination, animated: true, completion: nil)
    }
}
