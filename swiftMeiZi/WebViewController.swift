//
//  WebViewController.swift
//  swiftMeiZi
//
//  Created by teddy on 4/13/16.
//  Copyright © 2016 teddy. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import WebKit
import PKHUD

// Web页面
class WebViewController: UIViewController, UMSocialUIDelegate {

    // 变量
    @IBOutlet weak var backButton: UIButton!
    var url: String = ""
    var webView: WKWebView!
    var shareBtn: UIButton!
    var reportBtn: UIButton!
    var activityIndicatorView: NVActivityIndicatorView!
    var progressBar: UIProgressView!
    var firstCompleted: Bool = false
    
    // 返回按钮点击返回
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 添加share按钮
        let shareBtnFrame: CGRect = CGRect(x: self.view.bounds.width - 10 - 32, y: 20, width: 32, height: 32)
        shareBtn = UIButton(frame: shareBtnFrame)
        shareBtn.setBackgroundImage(UIImage(named: "share"), forState: UIControlState.Normal)
        
        // 注册share按钮的点击行为
        shareBtn.addTarget(self, action: #selector(WebViewController.tapped), forControlEvents: .TouchUpInside)
        self.view.addSubview(shareBtn)
        
        // 添加举报按钮 (因为苹果审核,关于user提供的Content要有 "举报" 机制)
        let reportBtnFrame: CGRect = CGRect(x: self.view.bounds.width - 10 - 32 - 10 - 28, y: 22, width: 28, height: 28)
        reportBtn = UIButton(frame: reportBtnFrame)
        reportBtn.setBackgroundImage(UIImage(named: "reportWhite"), forState: UIControlState.Normal)
        reportBtn.addTarget(self, action: #selector(WebViewController.reported), forControlEvents: .TouchUpInside)
        self.view.addSubview(reportBtn)
        
        // 添加进度条
        let progressBarFrame: CGRect = CGRect(x: 0, y: 55, width: self.view.bounds.width, height: 3)
        progressBar = UIProgressView(frame: progressBarFrame)
        progressBar.progressTintColor = UIColor.redColor()
        progressBar.layer.zPosition = 99
        self.view.addSubview(progressBar)
        
        // 添加WKWebView
        let webViewFrame: CGRect = CGRect(x: 0, y: 58, width: self.view.bounds.width, height: self.view.bounds.height - 58)
        webView = WKWebView(frame: webViewFrame)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        self.view.addSubview(webView)
        webView.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
        
        // 设置Loading (颜色以及大小)
        let frame = CGRect(x: (self.view.bounds.width / 2) - (Constants.activityIndicatorWH / 2), y: self.view.bounds.height / 2 - (Constants.activityIndicatorWH / 2), width: Constants.activityIndicatorWH, height: Constants.activityIndicatorWH)
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.BallClipRotatePulse)
        activityIndicatorView.color = Constants.activityIndicatorColor
        activityIndicatorView.hidesWhenStopped = true
        
        // 加入到view中
        self.view.addSubview(activityIndicatorView)
        
        // 开始显示Loading
        activityIndicatorView.startAnimation()
    }
    
    // share按钮的点击事件
    func tapped() -> () {
        
        // 分享到微信对话和微信朋友圈
        // 设置标题和URL
        UMSocialData.defaultData().extConfig.wechatSessionData.title = "精彩文章来自于 - 干货集中营"
        UMSocialData.defaultData().extConfig.wechatSessionData.url = webView.URL?.absoluteString;

        UMSocialData.defaultData().extConfig.wechatTimelineData.title = webView.title
        UMSocialData.defaultData().extConfig.wechatTimelineData.url = webView.URL?.absoluteString;
        
        // 弹出分享框
        UMSocialSnsService.presentSnsIconSheetView(self, appKey: Constants.uMengAppKey, shareText: webView.title, shareImage: UIImage(named: "AppImage"), shareToSnsNames: [UMShareToWechatSession, UMShareToWechatTimeline], delegate: nil)
    }
    
    // report页面跳转
    func reported() -> () {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let destination = storyboard.instantiateViewControllerWithIdentifier("ReportViewController") as! ReportViewController
        destination.modalTransitionStyle = .CrossDissolve
        self.presentViewController(destination, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        // 添加PageView - 文章详情 - disappear
        MobClick.endLogPageView("文章详情");
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 添加PageView - 文章详情 - appear
        MobClick.beginLogPageView("文章详情");
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // 监视网页load进度
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<()>) {
        
        // 之前定义的key
        if (keyPath == "estimatedProgress") {
            
            // 判断进度,如果100%则隐藏ProgressBar
            progressBar.hidden = webView.estimatedProgress == 1
            
            // 设置ProgressBar进度
            progressBar.setProgress(Float(webView.estimatedProgress), animated: true)
            
            // 如果Load完成
            if(webView.estimatedProgress == 1.0)
            {
                // 恢复progress为初始状态
                progressBar.progress = 0.0
                
                // 取消Loading状态
                activityIndicatorView.stopAnimation()
                
                // 判断是否为第一次load完成,如果不是,更改WebView高度
                if (!firstCompleted) {
                    webView.frame.origin.y = webView.frame.origin.y - 3
                }
                
                // 设置第一次加载完成
                firstCompleted = true
            }
        }
    }
    
    // 销毁要注销事件
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
}
