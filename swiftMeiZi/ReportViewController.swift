//
//  ReportViewController.swift
//  swiftMeiZi
//
//  Created by duoba on 16/5/1.
//  Copyright © 2016年 teddy. All rights reserved.
//

import UIKit
import PKHUD
import RAMPaperSwitch
import Alamofire

// 反馈页面
class ReportViewController: UIViewController {

    // 变量
    @IBOutlet weak var backBtn: UIButton!
    var doneBtn: UIButton!
    var firstReasonSwitch: RAMPaperSwitch!
    var secondReasonSwitch: RAMPaperSwitch!
    var thridReasonSwitch: RAMPaperSwitch!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // 添加并设置 完成 按钮
        let doneBtnFrame: CGRect = CGRect(x: self.view.bounds.width - 10 - 32, y: 20, width: 32, height: 32)
        doneBtn = UIButton(frame: doneBtnFrame)
        doneBtn.setBackgroundImage(UIImage(named: "done"), forState: UIControlState.Normal)
        
        // 注册 完成 按钮的点击行为
        doneBtn.addTarget(self, action: #selector(WebViewController.tapped), forControlEvents: .TouchUpInside)
        self.view.addSubview(doneBtn)
        
        // 展示UI
        self.setupUI()
    }
    
    // Done按钮的点击事件
    func tapped() -> () {
        
        // 判断是否选择了一种反馈理由
        if(firstReasonSwitch.on || secondReasonSwitch.on || thridReasonSwitch.on) {
            Alamofire.request(.POST, Constants.reportGankURL, parameters: ["type": "naked"])
                .responseString { response in
                    
                    print(response.data)
                    print(response.result)
            }
            
            // 发送成功 并 退回上一层controller
            HUD.flash(.Label("信息已发送，谢谢您的意见！"), delay: 1.5)
            self.dismissViewControllerAnimated(true, completion: {});
        }
        else {
            
            // 失败，弹出提示框
            HUD.flash(.Label("请先选择一个原因"), delay: 1.5)
        }
    }
    
    // 返回按钮点击返回
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 添加PageView - 最新 - appear
        MobClick.beginLogPageView("反馈");
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent     
        
        // 添加PageView - 最新 - disappear
        MobClick.endLogPageView("反馈");
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // UI展示
    func setupUI() -> () {
        
        // 定义每个View的高度, 因为最上面的Label高度是55, 一共三个view
        let viewHeight: CGFloat = (self.view.bounds.height - 55) / 3
        
        // 第一个view
        // view
        let firstReasonViewFrame: CGRect = CGRect(x: 0, y: 55, width: self.view.bounds.width, height: viewHeight)
        let firstReasonView: UIView = UIView(frame: firstReasonViewFrame)
        
        // image
        let firstImageFrame = CGRect(x: self.view.bounds.width / 2 - 32, y: 20, width: 48, height: 48)
        let firstImage: UIImageView = UIImageView(frame: firstImageFrame)
        firstImage.image = UIImage(named: "reason1")
        firstReasonView.addSubview(firstImage)

        // label
        let firstReasonLabelFrame = CGRect(x: self.view.bounds.width / 2 - 100, y: viewHeight / 2 - 20, width: 200, height: 20)
        let firstReasonLabel: UILabel = UILabel(frame: firstReasonLabelFrame)
        firstReasonLabel.text = "内容过于色情"
        firstReasonLabel.textAlignment = .Center
        firstReasonView.addSubview(firstReasonLabel)
        
        // switch
        firstReasonSwitch = RAMPaperSwitch(view: firstReasonView, color: UIColor(hexString: "1FB7FC"))
        firstReasonSwitch.frame = CGRectMake(self.view.bounds.width / 2 - 25, firstReasonView.frame.height / 2 + 10, 51, 31)
        firstReasonView.addSubview(firstReasonSwitch)
        
        self.view.addSubview(firstReasonView)
        
        // 第二个view
        // view
        let secondReasonViewFrame: CGRect = CGRect(x: 0, y: 55 + firstReasonView.frame.height, width: self.view.bounds.width, height: viewHeight)
        let secondReasonView: UIView = UIView(frame: secondReasonViewFrame)
        
        // image
        let secondImageFrame = CGRect(x: self.view.bounds.width / 2 - 32, y: 20, width: 48, height: 48)
        let secondImage: UIImageView = UIImageView(frame: secondImageFrame)
        secondImage.image = UIImage(named: "reason2")
        secondReasonView.addSubview(secondImage)

        // label
        let secondReasonLabelFrame = CGRect(x: self.view.bounds.width / 2 - 100, y: viewHeight / 2 - 20, width: 200, height: 20)
        let secondReasonLabel: UILabel = UILabel(frame: secondReasonLabelFrame)
        secondReasonLabel.text = "内容频繁出现"
        secondReasonLabel.textAlignment = .Center
        secondReasonView.addSubview(secondReasonLabel)

        // switch
        secondReasonSwitch = RAMPaperSwitch(view: secondReasonView, color: UIColor(hexString: "8EC63F"))
        secondReasonSwitch.frame = CGRectMake(self.view.bounds.width / 2 - 25, secondReasonView.frame.height / 2 + 10, 51, 31)
        secondReasonView.addSubview(secondReasonSwitch)
        
        self.view.addSubview(secondReasonView)
        
        // 第三个view
        // view
        let thridReasonViewFrame: CGRect = CGRect(x: 0, y: 55 + firstReasonView.frame.height + secondReasonView.frame.height, width: self.view.bounds.width, height: viewHeight)
        let thridReasonView: UIView = UIView(frame: thridReasonViewFrame)
        
        // image
        let thridImageFrame = CGRect(x: self.view.bounds.width / 2 - 32, y: 20, width: 48, height: 48)
        let thridImage: UIImageView = UIImageView(frame: thridImageFrame)
        thridImage.image = UIImage(named: "reason3")
        thridReasonView.addSubview(thridImage)
        
        // label
        let thridReasonLabelFrame = CGRect(x: self.view.bounds.width / 2 - 100, y: viewHeight / 2 - 20, width: 200, height: 20)
        let thridReasonLabel: UILabel = UILabel(frame: thridReasonLabelFrame)
        thridReasonLabel.text = "其它原因"
        thridReasonLabel.textAlignment = .Center
        thridReasonView.addSubview(thridReasonLabel)

        // switch
        thridReasonSwitch = RAMPaperSwitch(view: thridReasonView, color: UIColor(hexString: "CCBA14"))
        thridReasonSwitch.frame = CGRectMake(self.view.bounds.width / 2 - 25, thridReasonView.frame.height / 2 + 10, 51, 31)
        thridReasonView.addSubview(thridReasonSwitch)

        self.view.addSubview(thridReasonView)
    }
}
