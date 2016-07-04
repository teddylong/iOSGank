//
//  FuliCollectionLayoutAttributes.swift
//  swiftMeiZi
//
//  Created by teddy on 4/14/16.
//  Copyright © 2016 teddy. All rights reserved.
//

import UIKit

// 福利页面Layout Attribute
class FuliCollectionLayoutAttributes: UICollectionViewLayoutAttributes {

    var anchorPoint = CGPoint(x: 0.5, y: 0.5)
    
    var angle: CGFloat = 0 {
        didSet {
            zIndex = Int(angle*1000000)
            transform = CGAffineTransformMakeRotation(angle)
        }
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        let copiedAttributes: FuliCollectionLayoutAttributes = super.copyWithZone(zone) as! FuliCollectionLayoutAttributes
        copiedAttributes.anchorPoint = self.anchorPoint
        copiedAttributes.angle = self.angle
        return copiedAttributes
    }
}

// 福利页面Layout, 没啥逻辑可言
class FuliCollectionViewLayout: UICollectionViewLayout {
    
    // 定义大小
    let itemSize = CGSize(width: 250, height: 350)
    
    var angleAtExtreme: CGFloat {
        return collectionView!.numberOfItemsInSection(0) > 0 ? -CGFloat(collectionView!.numberOfItemsInSection(0)-1)*anglePerItem : 0
    }
    
    // 角度
    var angle: CGFloat {
        return angleAtExtreme*collectionView!.contentOffset.x/(collectionViewContentSize().width - CGRectGetWidth(collectionView!.bounds))
    }
    
    // 圆角
    var radius: CGFloat = 500 {
        didSet {
            invalidateLayout()
        }
    }
    
    var anglePerItem: CGFloat {
        return atan(itemSize.width/radius)
    }
    
    var attributesList = [FuliCollectionLayoutAttributes]()
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: CGFloat(collectionView!.numberOfItemsInSection(0))*itemSize.width,
                      height: CGRectGetHeight(collectionView!.bounds))
    }
    
    override class func layoutAttributesClass() -> AnyClass {
        return FuliCollectionLayoutAttributes.self
    }
    
    // 准备Layout
    override func prepareLayout() {
        super.prepareLayout()
        
        // 计算
        let centerX = collectionView!.contentOffset.x + (CGRectGetWidth(collectionView!.bounds)/2.0)
        let anchorPointY = ((itemSize.height/2.0) + radius)/itemSize.height
        
        let theta = atan2(CGRectGetWidth(collectionView!.bounds)/2.0, radius + (itemSize.height/2.0) - (CGRectGetHeight(collectionView!.bounds)/2.0)) //1
        
        var startIndex = 0
        var endIndex = collectionView!.numberOfItemsInSection(0) - 1
        
        if (angle < -theta) {
            startIndex = Int(floor((-theta - angle)/anglePerItem))
        }
        
        endIndex = min(endIndex, Int(ceil((theta - angle)/anglePerItem)))
        
        if (endIndex < startIndex) {
            endIndex = 0
            startIndex = 0
        }
        attributesList = (startIndex...endIndex).map { (i) -> FuliCollectionLayoutAttributes in
            let attributes = FuliCollectionLayoutAttributes(forCellWithIndexPath: NSIndexPath(forItem: i, inSection: 0))
            attributes.size = self.itemSize
            attributes.center = CGPoint(x: centerX, y: CGRectGetMidY(self.collectionView!.bounds))
            attributes.angle = self.angle + (self.anglePerItem*CGFloat(i))
            attributes.anchorPoint = CGPoint(x: 0.5, y: anchorPointY)
            return attributes
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesList
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath)
        -> UICollectionViewLayoutAttributes! {
            return attributesList[indexPath.row]
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }

    // 重写
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var finalContentOffset = proposedContentOffset
        let factor = -angleAtExtreme/(collectionViewContentSize().width - CGRectGetWidth(collectionView!.bounds))
        let proposedAngle = proposedContentOffset.x*factor
        let ratio = proposedAngle/anglePerItem
        var multiplier: CGFloat
        if (velocity.x > 0) {
            multiplier = ceil(ratio)
        } else if (velocity.x < 0) {
            multiplier = floor(ratio)
        } else {
            multiplier = round(ratio)
        }
        finalContentOffset.x = multiplier*anglePerItem/factor
        return finalContentOffset
    }
 
}
