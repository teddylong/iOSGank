//
//  FuliCollectionViewCell.swift
//  swiftMeiZi
//
//  Created by teddy on 4/14/16.
//  Copyright © 2016 teddy. All rights reserved.
//

import UIKit

// 福利cell样式
class FuliCollectionViewCell: UICollectionViewCell {
    
    var imageName = "" {
        didSet {
            imageView?.af_setImageWithURL(NSURL(string: imageName)!, placeholderImage: nil, imageTransition:.CrossDissolve(0.5))
            imageView?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            imageView!.contentMode = .ScaleAspectFill
        }
    }
    
    @IBOutlet weak var imageView: UIImageView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.layer.cornerRadius = 5
        contentView.layer.borderColor = UIColor.blackColor().CGColor
        contentView.layer.borderWidth = 1
        contentView.layer.shouldRasterize = true
        contentView.layer.rasterizationScale = UIScreen.mainScreen().scale
        contentView.clipsToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView!.contentMode = .ScaleAspectFill
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        let circularlayoutAttributes = layoutAttributes as! FuliCollectionLayoutAttributes
        self.layer.anchorPoint = circularlayoutAttributes.anchorPoint
        self.center.y += (circularlayoutAttributes.anchorPoint.y - 0.5)*CGRectGetHeight(self.bounds)
    }

}
