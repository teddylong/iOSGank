//
//  WaiBao.swift
//  swiftMeiZi
//
//  Created by teddy on 6/21/16.
//  Copyright © 2016 teddy. All rights reserved.
//

import Foundation

class WaiBao {
    
    private var _title: String? = ""
    private var _body: String? = ""
    private var _status: String? = ""
    private var _url: String? = ""
    private var _meta: String? = ""

    
    var title: String? {
        get{
            return _title
        }
        set{
            _title = newValue
        }
    }
    
    var body: String? {
        get{
            return _body
        }
        set{
            _body = newValue
        }
    }
    
    var status: String? {
        get{
            return _status
        }
        set{
            _status = newValue
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
    
    var meta: String? {
        get{
            return _meta
        }
        set{
            _meta = newValue
        }
    }

}