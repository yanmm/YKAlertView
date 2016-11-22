//
//  YKAlertView.swift
//  WEYBee
//
//  Created by Yuki on 16/4/15.
//  Copyright © 2016年 Zhejiang YaoWang Network Technology Co., Ltd. All rights reserved.
//

import UIKit

/// AlertView类型
public enum YKAlertViewStyle: Int {
    case ActionSheet
    case Alert
    case ActionTop
}

/// 添加的按钮类型
public enum YKButtonStyle: Int {
    case Normal
    /// Cancel类型只在ActionSheet底层显示，且只有一个
    case Cancel
}

/// 添加的按钮颜色
public enum YKButtonColor: Int {
    case Normal
    case Super
}

struct YKButton {
    var title: String!
    var style: YKButtonStyle!
    var color: YKButtonColor!
    var handler: (() -> Void)? = nil
    var completion: (() -> Void)? = nil
    
    init(title: String, style: YKButtonStyle, color: YKButtonColor, handler: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.color = color
        self.handler = handler
        self.completion = completion
    }
}

class YKAlertView: UIView {
    /**********         ActionSheet          ******/
    
    /// 粗线条高度
    private let blodLineHeight: CGFloat = 10.0
    /// 粗线条颜色（返回上面）
    private let blodLineColor = UIColor(hex6: 0xE7E7F1)
    
    /**********         ActionTop          ******/
    
    /// 计时器
    private var timer = NSTimer()
    /// 显示时间
    private let showTime: Double = 2
    /// ActionTop点击背景回调
    var actionTopCompletion: (() -> Void)? = nil
    /// ActionTop背景颜色
    var actionTopViewColor = UIColor(hex6: 0xFD836A)
    /// ActionTop文字颜色
    var actionTopTitleColor = UIColor(hex6: 0xFFFFFF)
    
    
    /**********           Alert              ******/
    
    /// 内容视图宽度
    private let viewWidth: CGFloat = 270
    /// 标题间距
    private let titleInset: CGFloat = 20
    /// mwssage内容上下间距
    private let messageTopInset: CGFloat = 10
    /// mwssage内容左右间距
    private let messageLeftInset: CGFloat = 15
    /// 最大高度
    private let MLFLOAT_MAX: CGFloat = 350.0
    
    
    /**********      Alert && ActionSheet && ActionTop      ******/
    
    /// 屏幕宽度
    private let kWidth = UIScreen.mainScreen().bounds.width
    /// 屏幕高度
    private let kHeight = UIScreen.mainScreen().bounds.height
    /// 内容视图高度
    private var viewHeight: CGFloat = 0
    /// 返回按钮高度
    private var cancelBtnHeight: CGFloat = 50.0
    /// 普通按钮高度
    private var actionBtnHeight: CGFloat = 50.0
    /// 标题按钮高度
    private var titleHeight: CGFloat = 35.0
    /// 动画时长
    private let animationTime = 0.3
    /// 背景遮罩透明度
    private let bgAlpha: CGFloat = 0.3
    /// 内容视图
    private lazy var contentView = UIView()
    /// 背景遮罩
    private lazy var bgBtn = UIButton(type: UIButtonType.Custom)
    /// 线条数量
    private var lineNum: Int = 0
    /// 普通按钮
    private lazy var normalBtns: [YKButton] = []
    /// 返回按钮
    private var cancelBtn: YKButton!
    /// 细线条颜色
    private var smallLineColor = UIColor(hex6: 0xE5E5E5)
    /// 普通按钮颜色
    private var normolColor = UIColor(hex6: 0x222222)
    /// 返回按钮颜色
    private var cancelColor = UIColor(hex6: 0x222222)
    /// 标题按钮颜色
    private var titleColor = UIColor(hex6: 0x222222)
    /// 提示标题
    var title: String!
    /// 提示内容（如果是ActionSheet不会显示）
    var message: String!
    /// 类型
    var style: YKAlertViewStyle! {
        didSet {
            cancelBtnHeight = style == .ActionSheet ? 50.0 : 44.0
            actionBtnHeight = style == .ActionSheet ? 50.0 : 44.0
            contentView.layer.cornerRadius = style == .Alert ? 10 : 0
            contentView.backgroundColor = style == .Alert ? UIColor.whiteColor() : UIColor.clearColor()
            titleHeight = style == .ActionSheet ? 35.0 : 21.0
            smallLineColor = style == .ActionSheet ? UIColor(hex6: 0xE5E5E5) : UIColor(hex6: 0xD4D4D4)
            titleColor = style == .ActionSheet ? UIColor(hex6: 0x222222) : UIColor(hex6: 0x030303)
            normolColor = style == .ActionSheet ? UIColor(hex6: 0x222222) : UIColor(hex6: 0x030303)
            cancelColor = style == .ActionSheet ? UIColor(hex6: 0x222222) : UIColor(hex6: 0x030303)
            contentView.clipsToBounds = true
        }
    }
    /// 特殊按钮颜色
    var superColor = UIColor(hex6: 0xFD836A)
    /// 点击按钮之后是否隐藏视图
    var shouldRemoveView = true
    
    /// 初始化方法
    class func initView(title: String?, message: String?, style: YKAlertViewStyle) -> YKAlertView {
        let view = YKAlertView()
        if style == .ActionTop {
            view.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 64)
        } else {
            view.frame = UIScreen.mainScreen().bounds
        }
        view.title = title
        view.message = message
        view.style = style
        return view
    }
    
    /// 添加按钮
    func addButton(title: String, style: YKButtonStyle, color: YKButtonColor, handler: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        let btn = YKButton(title: title, style: style, color: color, handler: handler, completion: completion)
        if btn.style == .Cancel {
            self.cancelBtn = btn
            return
        }
        self.normalBtns.append(btn)
    }
    
    /// 初始化ActionSheet视图
    private func setupActionSheet() {
        if title == nil {
            viewHeight = CGFloat(normalBtns.count) * actionBtnHeight
            if self.cancelBtn != nil {
                self.viewHeight += (cancelBtnHeight + blodLineHeight)
            }
        } else {
            viewHeight = CGFloat(normalBtns.count) * actionBtnHeight + titleHeight
            if self.cancelBtn != nil {
                self.viewHeight += (cancelBtnHeight + blodLineHeight)
            }
            lineNum += 1
        }
        
        bgBtn.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
        bgBtn.addTarget(self, action: #selector(dismissView), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(bgBtn)
        bgBtn.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(0)
        }
        
        self.addSubview(contentView)
        contentView.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(viewHeight)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(viewHeight)
        }
        
        if self.cancelBtn != nil {
            let cancelBtn = UIButton(type: UIButtonType.Custom)
            let color = self.cancelBtn.color == .Normal ? cancelColor : superColor
            cancelBtn.setTitleColor(color, forState: UIControlState.Normal)
            cancelBtn.titleLabel?.font = UIFont.preferredFontForTextStyle("Medium")
            cancelBtn.titleLabel?.font = UIFont.systemFontOfSize(18)
            cancelBtn.backgroundColor = UIColor.whiteColor()
            contentView.addSubview(cancelBtn)
            cancelBtn.tag = -1
            cancelBtn.setTitle(self.cancelBtn.title, forState: UIControlState.Normal)
            cancelBtn.addTarget(self, action: #selector(actionBtnClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cancelBtn.snp_makeConstraints { (make) -> Void in
                make.height.equalTo(cancelBtnHeight)
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.bottom.equalTo(0)
            }
        }
        
        for (index, btn) in normalBtns.enumerate().reverse() {
            let actionBtn = UIButton(type: UIButtonType.Custom)
            actionBtn.tag = index
            actionBtn.backgroundColor = UIColor.whiteColor()
            actionBtn.setTitle(btn.title, forState: UIControlState.Normal)
            let color = btn.color == .Normal ? cancelColor : superColor
            actionBtn.setTitleColor(color, forState: UIControlState.Normal)
            actionBtn.titleLabel?.font = UIFont.preferredFontForTextStyle("Medium")
            actionBtn.titleLabel?.font = UIFont.systemFontOfSize(18)
            actionBtn.addTarget(self, action: #selector(actionBtnClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            contentView.addSubview(actionBtn)
            actionBtn.snp_makeConstraints { (make) -> Void in
                make.height.equalTo(actionBtnHeight)
                make.left.equalTo(0)
                make.right.equalTo(0)
                if self.cancelBtn != nil {
                    make.bottom.equalTo(-(CGFloat(normalBtns.count - index - 1) * actionBtnHeight + cancelBtnHeight + blodLineHeight))
                } else {
                    make.bottom.equalTo(-(CGFloat(normalBtns.count - index - 1) * actionBtnHeight))
                }
                
            }
            lineNum += 1
        }
        
        if let title = title {
            let titleBtn = UIButton(type: UIButtonType.Custom)
            titleBtn.setTitleColor(titleColor, forState: UIControlState.Normal)
            titleBtn.backgroundColor = UIColor.whiteColor()
            titleBtn.titleLabel?.font = UIFont.systemFontOfSize(12)
            contentView.addSubview(titleBtn)
            titleBtn.setTitle(title, forState: UIControlState.Normal)
            titleBtn.snp_makeConstraints { (make) -> Void in
                make.height.equalTo(titleHeight)
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.top.equalTo(0)
            }
        }
        
        while lineNum > 0 {
            let line = UIView()
            if lineNum == 1 && self.cancelBtn != nil {
                line.backgroundColor = blodLineColor
                contentView.addSubview(line)
                line.snp_makeConstraints { (make) -> Void in
                    make.height.equalTo(blodLineHeight)
                    make.left.equalTo(0)
                    make.right.equalTo(0)
                    if cancelBtn != nil {
                        make.bottom.equalTo(-(CGFloat(lineNum - 1) * actionBtnHeight + cancelBtnHeight))
                    } else {
                        make.bottom.equalTo(-(CGFloat(lineNum - 1) * actionBtnHeight))
                    }
                    
                }
            } else {
                line.backgroundColor = smallLineColor
                contentView.addSubview(line)
                line.snp_makeConstraints { (make) -> Void in
                    make.height.equalTo(0.5)
                    make.left.equalTo(0)
                    make.right.equalTo(0)
                    if self.cancelBtn != nil {
                        make.bottom.equalTo(-(CGFloat(lineNum - 1) * actionBtnHeight + cancelBtnHeight + blodLineHeight))
                    } else {
                        make.bottom.equalTo(-(CGFloat(lineNum - 1) * actionBtnHeight))
                    }
                }
            }
            lineNum -= 1
        }
    }
    
    /// 初始化Alert视图
    private func setupAlert() {
        if title != nil {
            viewHeight += (titleInset + titleHeight)
        }
        if message != nil {
            let label = UILabel()
            label.text = message
            label.font = UIFont.systemFontOfSize(13.0)
            label.numberOfLines = 0
            let size = label.sizeThatFits(CGSize(width: viewWidth - 2 * messageLeftInset, height: MLFLOAT_MAX))
            viewHeight += (messageTopInset * 2 + size.height)
        }
        viewHeight += actionBtnHeight
        
        bgBtn.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
        bgBtn.addTarget(self, action: #selector(dismissView), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(bgBtn)
        bgBtn.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(0)
        }
        
        contentView.alpha = 0
        self.addSubview(contentView)
        contentView.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self.snp_center).offset(0)
            make.height.equalTo(viewHeight)
            make.width.equalTo(viewWidth)
        }
        
        if let title = self.title {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.textColor = titleColor
            titleLabel.textAlignment = NSTextAlignment.Center
            titleLabel.font = UIFont.preferredFontForTextStyle("Medium")
            titleLabel.font = UIFont.systemFontOfSize(17)
            contentView.addSubview(titleLabel)
            titleLabel.snp_makeConstraints { (make) -> Void in
                make.height.equalTo(titleHeight)
                make.left.equalTo(titleInset)
                make.right.equalTo(-titleInset)
                make.top.equalTo(titleInset)
            }
        }
        
        if let message = self.message {
            let messageLabel = UILabel()
            messageLabel.text = message
            messageLabel.textColor = normolColor
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.font = UIFont.systemFontOfSize(13)
            contentView.addSubview(messageLabel)
            messageLabel.snp_makeConstraints { (make) -> Void in
                if self.title != nil {
                    make.top.equalTo(titleHeight + titleInset + messageTopInset)
                } else {
                    make.top.equalTo(messageTopInset)
                }
                make.left.equalTo(messageLeftInset)
                make.right.equalTo(-messageLeftInset)
            }
        }
        
        if message != nil || title != nil {
            let line = UIView()
            line.backgroundColor = smallLineColor
            contentView.addSubview(line)
            line.snp_makeConstraints { (make) -> Void in
                make.height.equalTo(0.5)
                make.left.equalTo(0)
                make.right.equalTo(0)
                make.bottom.equalTo(-actionBtnHeight)
            }
        }
        
        for (index, btn) in normalBtns.enumerate() {
            let actionBtn = UIButton(type: UIButtonType.Custom)
            actionBtn.tag = index
            actionBtn.backgroundColor = UIColor.whiteColor()
            actionBtn.setTitle(btn.title, forState: UIControlState.Normal)
            let color = btn.color == .Normal ? cancelColor : superColor
            actionBtn.setTitleColor(color, forState: UIControlState.Normal)
            actionBtn.titleLabel?.font = UIFont.preferredFontForTextStyle("Medium")
            actionBtn.titleLabel?.font = UIFont.systemFontOfSize(18)
            actionBtn.addTarget(self, action: #selector(actionBtnClick), forControlEvents: UIControlEvents.TouchUpInside)
            contentView.addSubview(actionBtn)
            actionBtn.snp_makeConstraints { (make) -> Void in
                make.height.equalTo(actionBtnHeight)
                make.width.equalTo(viewWidth / CGFloat(normalBtns.count))
                make.left.equalTo(CGFloat(index) * viewWidth / CGFloat(normalBtns.count))
                make.bottom.equalTo(0)
            }
            lineNum += 1
        }
        
        lineNum -= 1
        while lineNum > 0 {
            let line = UIView()
            line.backgroundColor = smallLineColor
            contentView.addSubview(line)
            line.snp_makeConstraints { (make) -> Void in
                make.width.equalTo(0.5)
                make.height.equalTo(actionBtnHeight)
                make.left.equalTo(CGFloat(lineNum) * viewWidth / CGFloat(normalBtns.count))
                make.bottom.equalTo(0)
            }
            lineNum -= 1
        }
    }
    
    /// 初始化ActionTop视图
    private func setupActionTop() {
        viewHeight = 64
        
        self.addSubview(contentView)
        contentView.backgroundColor = actionTopViewColor
        contentView.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(viewHeight)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(-viewHeight)
        }
        
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.numberOfLines = 2
        messageLabel.textColor = actionTopTitleColor
        messageLabel.font = UIFont.systemFontOfSize(15)
        contentView.addSubview(messageLabel)
        messageLabel.snp_makeConstraints { (make) in
            // top应该是20的  可15效果好点
            make.top.equalTo(15)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(0)
        }
        
        let actionBtn = UIButton()
        contentView.addSubview(actionBtn)
        actionBtn.snp_makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        actionBtn.addTarget(self, action: #selector(actionTopViewClick), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    /// 显示视图
    func showView() {
        if style == .ActionSheet {
            setupActionSheet()
        }
        if style == .Alert {
            setupAlert()
        }
        if style == .ActionTop {
            setupActionTop()
        }
        
        UIApplication.sharedApplication().keyWindow!.addSubview(self)
        UIView.animateWithDuration(animationTime) {
            if self.style == .ActionSheet {
                self.contentView.transform = CGAffineTransformMakeTranslation(0, -self.viewHeight)
            }
            if self.style == .ActionTop {
                self.contentView.transform = CGAffineTransformMakeTranslation(0, self.viewHeight)
                self.timer = NSTimer.scheduledTimerWithTimeInterval(self.showTime, target: self, selector: #selector(self.dismissView), userInfo: nil, repeats: false)
                NSRunLoop.currentRunLoop().addTimer(self.timer, forMode: NSRunLoopCommonModes)
                return
            }
            if self.style == .Alert {
                self.contentView.alpha = 1
            }
            self.bgBtn.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(self.bgAlpha)
        }
    }
    
    @objc private func actionTopViewClick() {
        if let handler = self.actionTopCompletion {
            handler()
        }
        self.dismissView()
    }
    
    @objc private func dismissView() {
        // Alert点击背景视图不会隐藏
        if style == .Alert {
            return
        }
        UIView.animateWithDuration(animationTime, animations: {
            if self.style == .Alert {
                self.contentView.alpha = 0
            } else {
                self.contentView.transform = CGAffineTransformIdentity
            }
            self.bgBtn.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
            }) { (_) in
                self.timer.invalidate()
                self.removeFromSuperview()
        }
    }
    
    @objc private func actionBtnClick(sender: UIButton) {
        // tag == -1 ActionSheet的返回按钮点击事件
        if sender.tag == -1 {
            if let handler = self.cancelBtn.handler {
                handler()
            }
        } else {
            if let handler = self.normalBtns[sender.tag].handler {
                handler()
            }
        }
        if !shouldRemoveView {
            return
        }
        UIView.animateWithDuration(animationTime, animations: {
            self.bgBtn.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
            if self.style == .ActionSheet {
                self.contentView.transform = CGAffineTransformIdentity
            } else {
                self.contentView.alpha = 0
            }
        }) { (_) in
            if sender.tag == -1 {
                if let completion = self.cancelBtn.completion {
                    completion()
                }
            } else {
                if let completion = self.normalBtns[sender.tag].completion {
                    completion()
                }
            }
            self.removeFromSuperview()
        }
    }
}
