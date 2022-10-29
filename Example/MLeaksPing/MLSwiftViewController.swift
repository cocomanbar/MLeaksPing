//
//  MLSwiftViewController.swift
//  MLeaksPing_Example
//
//  Created by tanxl on 2022/10/29.
//  Copyright © 2022 cocomanbar. All rights reserved.
//

import UIKit

@objcMembers class MLSwiftView1: UIView {
    
    var aView: UIView?
}

@objcMembers class MLSwiftView2: UIView {
    
    var aView: UIView?
    
    deinit {
        print("???")
    }
}

// MARK: - 要使用 runtime特性需要声明桥接
@objcMembers class MLSwiftViewController: UIViewController {
    
    var view1: MLSwiftView1?
    var view2: MLSwiftView2?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.orange
        
        view1 = MLSwiftView1()
        view2 = MLSwiftView2()
        
        view.addSubview(view1!)
        view.addSubview(view2!)
        
        view1?.aView = view2
        view2?.aView = view1
    }
    
    deinit {
        print("??")
    }

}

