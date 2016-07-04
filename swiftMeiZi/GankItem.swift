//
//  GankItem.swift
//  swiftMeiZi
//
//  Created by teddy on 4/6/16.
//  Copyright © 2016 teddy. All rights reserved.
//

import Foundation

class GankItem {
    
    private var _id: String? = ""
    private var _createdAt: String? = ""
    private var _desc: String? = ""
    private var _publishedAt: String? = ""
    private var _source: String? = ""
    private var _type: String? = ""
    private var _url: String? = ""
    private var _who: String? = ""
    private var _readability: String? = ""
    
    
    var id: String? {
        get{
            return _id
        }
        set{
            _id = newValue
        }
    }
    var createdAt: String? {
        get{
            return _createdAt
        }
        set{
            _createdAt = newValue
        }
    }
    var desc: String? {
        get{
            return _desc
        }
        set{
            _desc = newValue
        }
    }
    var publishedAt: String? {
        get{
            return _publishedAt
        }
        set{
            _publishedAt = newValue
        }
    }
    var source: String? {
        get{
            return _source
        }
        set{
            _source = newValue
        }
    }
    var type: String? {
        get{
            return _type
        }
        set{
            _type = newValue
        }
    }
    var url: String? {
        get{
            return _url
        }
        set{
            _url = newValue
        }
    }
    var who: String? {
        get{
            return _who
        }
        set{
            _who = newValue
        }
    }
    var readability: String? {
        get{
            return _readability
        }
        set{
            _readability = newValue
        }
    }
}
