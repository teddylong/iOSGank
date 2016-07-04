//
//  CategoryViewController.swift
//  swiftMeiZi
//
//  Created by teddy on 4/5/16.
//  Copyright © 2016 teddy. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftHEXColors
import LTMorphingLabel
import PKHUD
import NVActivityIndicatorView
import SwiftyJSON

// 分类页面
class CategoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource  {
    
    // 定义collection
    var myCollectionView: UICollectionView!
    
    // 定义Loading
    var activityIndicatorView: NVActivityIndicatorView!
    
    // 设置分类
    var categoryArray: NSMutableArray = ["福利", "APK", "iOS", "拓展资源", "前端", "瞎推荐"]
    
    // 颜色
    let colorArray: NSMutableArray = [Constants.cateColor1, Constants.cateColor2, Constants.cateColor3, Constants.cateColor4, Constants.cateColor5, Constants.cateColor6]
    
    // 图片
    let categoryImg: NSMutableArray = ["meinv128", "APK128", "iOS128", "ziyuan128", "front128", "tuijian128"]
    
    // 入口
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置ViewController的layout形式，超出部分截掉
        self.edgesForExtendedLayout = .None
        
        // 设置collection
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: Constants.zeroCGFloat, left: Constants.zeroCGFloat, bottom: Constants.zeroCGFloat, right: Constants.zeroCGFloat)
        
        // 设置最小间隙
        layout.minimumLineSpacing = 0
        
        // 初始化collection
        self.myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        
        // 设置collection的auto resize，针对高度，如果不设置layout会有问题
        self.myCollectionView.autoresizingMask = .FlexibleHeight
        self.myCollectionView.dataSource = self
        self.myCollectionView.delegate = self
        self.myCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        self.myCollectionView.backgroundColor = UIColor.whiteColor()
        
        // 设置Loading (颜色以及大小)
        let frame = CGRect(x: (self.view.bounds.width / 2) - (Constants.activityIndicatorWH / 2), y: self.view.bounds.height / 2 - Constants.activityIndicatorWH, width: Constants.activityIndicatorWH, height: Constants.activityIndicatorWH)
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.BallClipRotatePulse)
        activityIndicatorView.color = Constants.activityIndicatorColor
        activityIndicatorView.hidesWhenStopped = true
        
        // 加入到view中
        self.view.addSubview(activityIndicatorView)
        
        // 开始显示Loading
        activityIndicatorView.startAnimation()
        
        // 检查OnLine还是OffLine
        self.OnLineOrOffLine()
    }
    
    // 检查线上还是线下
    func OnLineOrOffLine() -> () {
        Alamofire.request(.GET, Constants.switchGankURL).responseString { response in
            
            // 如果是线下
            if (response.result.value! == "offline") {
                
                // 删除Array中 "福利" 以方便审查
                self.categoryArray.removeObject("福利")
                self.colorArray.removeObject(Constants.cateColor1)
                self.categoryImg.removeObject("meinv128")
                
                // 删除Array中 "APK" 以方便审查
                self.categoryArray.removeObject("APK")
                self.colorArray.removeObject(Constants.cateColor2)
                self.categoryImg.removeObject("APK128")
            }
            
            // 展示UI
            self.setupUI()
        }
    }
    
    // 重新计算Collection View的size
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        self.myCollectionView.frame.size = self.view.frame.size;
    }
    
    // UI展示
    func setupUI() -> () {
        
        // 取消Loading状态
        activityIndicatorView.stopAnimation()
        
        // 添加collection到view中
        self.view.addSubview(myCollectionView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // 添加PageView - 分类 - appear
        MobClick.beginLogPageView("分类");
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = .Default
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
        // 添加PageView - 分类 - disappear
        MobClick.endLogPageView("分类");
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // 返回cell的大小
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: (collectionView.bounds.height) / 2.8)
    }
    
    // 返回cell的数量
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    // 返回section
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // 点击每个cell的行为
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // 福利入口
        if(categoryArray[indexPath.row] as! String == Constants.fuliChinese) {
            
            // 初始化福利展示页面Layout
            let layout: FuliCollectionViewLayout = FuliCollectionViewLayout()
            
            // 初始化福利页面
            let fuli: FuliViewController = FuliViewController(collectionViewLayout: layout)
            
            // 因为是异步，所以先去取到数据，填充到要push到的controller的属性中，再去push。这个时候其实可以写一些loading的view去告诉用户在loading,自处为偷懒写法
            HUD.flash(.Progress, delay: 1.5)
            
            // 获取福利的数据
            Alamofire.request(.GET, Constants.allFuliPre + Constants.firstPageNumberString).responseJSON{ response in
                
                // 解析返回JSON
                if let JSON = response.result.value as? NSDictionary {
                    if let results =  JSON["results"] as? NSArray {
                        for item in results {
                            let urlString = (item as! NSDictionary)["url"] as! String
                            fuli.images.append(urlString)
                        }
                    }
                }
                
                // push到福利页面
                self.navigationController?.pushViewController(fuli, animated: true)
            }
        }
        
        // 除了福利的分类详细页面
        else {
            
            // 实例化 页面
            let commonDetail: CommonDetailViewController = CommonDetailViewController()
            
            // 传值 - 是哪个"分类"
            commonDetail.requestType = categoryArray[indexPath.row] as! String
            
            // push到CommonDetailViewController
            self.navigationController?.pushViewController(commonDetail, animated: true)
        }
    }
    
    // 返回每个cell
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // 重用cell的另外一种方法, 就是先删掉所有的子view, 然后把值全部重新赋一遍, 适用于不想再写单写cell的情况
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as UICollectionViewCell
        
        // 删除cell下面所有的subviews
        for subView in cell.subviews {
            subView.removeFromSuperview()
        }
        
        // 设置cell的背景色
        cell.backgroundColor = colorArray[indexPath.row] as? UIColor
        
        // 向cell中添加一个image
        let imageFrame: CGRect = CGRect(x: (self.view.bounds.width / 2 - 32), y: (cell.bounds.height / 2 - 48), width: 64, height: 64)
        let image: UIImageView = UIImageView(frame: imageFrame)
        image.image = UIImage(named: categoryImg[indexPath.row] as! String)
        cell.addSubview(image)
        
        // 向cell中添加一个label
        let lableFrame: CGRect = CGRect(x: (self.view.bounds.width / 2 - 100), y: (cell.bounds.height / 2) + 16 , width: 200, height: 40)
        let label: LTMorphingLabel = LTMorphingLabel(frame: lableFrame)
        label.textAlignment=NSTextAlignment.Center
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.boldSystemFontOfSize(20)
        label.text = categoryArray[indexPath.row] as? String
        
        // 设置cell中label的特效
        let effect = LTMorphingEffect(rawValue: 4)
        label.morphingEffect = effect!
        label.morphingDuration = 0.8
        cell.addSubview(label)
        
        // 返回cell
        return cell
    }
}