//
//  Daily.swift
//  swiftMeiZi
//
//  Created by teddy on 4/6/16.
//  Copyright © 2016 teddy. All rights reserved.
//

import Foundation

class Daily {
    private var _category: NSArray = []
    private var _results: Array<GankItem> = []
    
    var category: NSArray {
        get{
            return _category
        }
        set {
            _category = newValue
        }
    }
    var results: Array<GankItem> {
        get{
            return _results
        }
        set {
            _results = newValue
        }
    }
}