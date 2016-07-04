//
//  CategoryDetailViewController.swift
//  swiftMeiZi
//
//  Created by teddy on 4/11/16.
//  Copyright © 2016 teddy. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SKPhotoBrowser
import PKHUD

// Cell ID
let reuseIdentifier = "Cell"

class FuliViewController: UICollectionViewController, SKPhotoBrowserDelegate {
    
    // 变量
    var images: [String] = []
    var pages: Int = 1
    var tempImageURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 注册Cell
        collectionView!.registerNib(UINib(nibName: "FuliCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.backgroundColor = Constants.statusBackColor
        
        // 设置标题
        self.navigationItem.title = "福利"
    }
    
    // 取消右划back功能 (好像也不好用,网上找的方法)
    override func viewWillLayoutSubviews() {
        if self.respondsToSelector(Selector("interactivePopGestureRecognizer")) {
            self.navigationController?.interactivePopGestureRecognizer?.enabled = false
        }
    }
    
    // 返回collection内cell个数
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    // 返回collection内cell
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FuliCollectionViewCell
        cell.imageName = images[indexPath.row]
        return cell
    }
    
    // 判断划到即将结束的时候，load下一组图片
    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == 17 * pages) {
            
            // 拼写URL
            let jsonUrl = Constants.allFuliPre + String(pages + 1)
            
            let resultData: NSData = NSURLSession.requestSynchronousData(NSURLRequest(URL: NSURL(string: jsonUrl)!))!
            
            // 遍历返回的JSON
            do {
                let jsonArray: NSDictionary = try NSJSONSerialization.JSONObjectWithData(resultData, options:[]) as! NSDictionary
                let content: NSArray = jsonArray["results"] as! NSArray
                
                // 添加image的url到数组中
                for temp in content {
                    let imageUrl: String = temp["url"] as! String
                    self.images.append(imageUrl)
                }
            }
            catch {
                print("Error: \(error)")
            }
            
            // 页码+1
            pages = pages + 1
            
            // reload
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView?.reloadData()
            }
        }
    }
    
    // 设置每个Collection Cell
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // Image URL
        let imageUrlAddress: String = images[indexPath.row]
        
        tempImageURL = imageUrlAddress
        
        // 点击大图设置
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
    
    // 反馈页面
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
}

// 扩展NSURLSession 用来不是异步的加载
public extension NSURLSession {
    
    // Data
    public static func requestSynchronousData(request: NSURLRequest) -> NSData? {
        var data: NSData? = nil
        let semaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {
            taskData, _, error -> () in
            data = taskData
            if data == nil, let error = error {print(error)}
            dispatch_semaphore_signal(semaphore);
        })
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return data
    }
    
    // Data with url
    public static func requestSynchronousDataWithURLString(requestString: String) -> NSData? {
        guard let url = NSURL(string:requestString) else {return nil}
        let request = NSURLRequest(URL: url)
        return NSURLSession.requestSynchronousData(request)
    }
    
    // JSON
    public static func requestSynchronousJSON(request: NSURLRequest) -> AnyObject? {
        guard let data = NSURLSession.requestSynchronousData(request) else {return nil}
        return try? NSJSONSerialization.JSONObjectWithData(data, options: [])
    }
    // JSON with url
    public static func requestSynchronousJSONWithURLString(requestString: String) -> AnyObject? {
        guard let url = NSURL(string: requestString) else {return nil}
        let request = NSMutableURLRequest(URL:url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return NSURLSession.requestSynchronousJSON(request)
    }
}


