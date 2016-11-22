//
//  ViewController.swift
//  YKAlertView
//
//  Created by Yuki on 16/7/13.
//  Copyright © 2016年 Yuki. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var timer: NSTimer?
    var messages: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func show(sender: UIButton) {
        let view = YKAlertView.initView("你大爷", message: "你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？", style: YKAlertViewStyle.Alert)
        
        view.addButton("1", style: .Normal, color: .Normal, handler: {
                print("11111111")
            })
        view.addButton("2", style: .Normal, color: .Super, handler: {
            print("22222222")
        })
        view.addButton("3", style: .Normal, color: .Super, handler: {
            print("33333333")
        })
        view.showView()
    }

    @IBAction func show2(sender: UIButton) {
        let view = YKAlertView.initView("你大爷", message: "你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？你是不是傻？", style: YKAlertViewStyle.ActionSheet)
        
        view.addButton("1", style: .Normal, color: .Normal, handler: {
            print("11111111")
        })
        view.addButton("2", style: .Normal, color: .Super, handler: {
            print("22222222")
        })
        view.addButton("3", style: .Normal, color: .Super, handler: {
            print("33333333")
        })
        view.addButton("返回", style: YKButtonStyle.Cancel, color: .Super, handler: nil)
        view.showView()
    }
    
    @IBAction func show3(sender: UIButton) {
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(2.6, target: self, selector: #selector(timeRun), userInfo: nil, repeats: true)
            messages = ["A","B","C","D","E"]
        }
    }
    
    func timeRun() {
        if messages.count != 0 {
            let topView = YKAlertView.initView(nil, message: messages[0], style: YKAlertViewStyle.ActionTop)
            topView.showView()
            messages.removeAtIndex(0)
        } else {
            timer?.invalidate()
            timer = nil
        }
    }
}

