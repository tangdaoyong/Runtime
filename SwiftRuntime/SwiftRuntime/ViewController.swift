//
//  ViewController.swift
//  SwiftRuntime
//
//  Created by 唐道勇 on 2017/12/14.
//  Copyright © 2017年 唐道勇. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setUI()
        
        methodChange(object_getClass(self)!, leftSelector: #selector(UIViewController.present(_:animated:completion:)), rightSelector: "yx_present:animated:completion:")//Selector("yx_present:animated:completion:")将系统的弹框方法替换为自己的方法。(自己的需要添加@objc，系统的方法可以直接取到)
        methodChange(object_getClass(self)!, leftSelector: #selector(UIViewController.viewWillAppear(_:)), rightSelector: "yx_viewWillAppear:")//Selector("yx_viewWillAppear:")将系统的viewWillAppear替换为自己的yx_viewWillAppear方法。(注意添加@objc)
    }
    
    @objc func yx_present(_ viewControllerToPresent:UIViewController, animated:Bool, completion:(() ->Void)?) {
        print("自定义提示方法")
        if !viewControllerToPresent.isKind(of: UIAlertController.self) {
            self.yx_present(viewControllerToPresent, animated: animated, completion: completion)//其它提示框正常处理，由于已经交换了方法，所以调用自己的方法，实际走的是系统的提示方法。
            return
        }
        guard let alertC:UIAlertController = viewControllerToPresent as? UIAlertController else {
            print("转换提示框失败")
            self.yx_present(viewControllerToPresent, animated: animated, completion: completion)//其它提示框正常处理，由于已经交换了方法，所以调用自己的方法，实际走的是系统的提示方法。
            return
        }
        if alertC.message == nil && alertC.title == nil {// 换图标时的提示框的title和message都是nil，由此可特殊处理
            print("更换图标的提示框")
            return
        }
        self.yx_present(viewControllerToPresent, animated: animated, completion: completion)//其它提示框正常处理，由于已经交换了方法，所以调用自己的方法，实际走的是系统的提示方法。
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("将要显示")
    }
    
    @objc func yx_viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("自定义将要显示")
    }
}

extension ViewController {
    
    fileprivate func setUI() {
        let buton = UIButton.init(frame: CGRect.init(x: 50, y: 80, width: UIScreen.main.bounds.width - 100, height: 50))
        buton.setTitle("更换", for: UIControlState.normal)
        buton.backgroundColor = UIColor.gray
        buton.addTarget(self, action: "buttonAction:", for: UIControlEvents.touchUpInside)//#selector(buttonAction(_:))
        self.view.addSubview(buton)
    }
    
    @objc fileprivate func buttonAction(_ button: UIButton) {
        if !UIApplication.shared.supportsAlternateIcons {
            print("不能更换图标")
            return
        }
        print("能够更换图标")
        if let iconName = UIApplication.shared.alternateIconName {
            print("当前图标" + iconName)
            UIApplication.shared.setAlternateIconName(nil, completionHandler: { (error) in
                if error != nil {
                    print("使用系统默认图标错误")
                    print(error!)
                    return
                }
                print("使用系统默认图标成功")
            })
            return
        }
        UIApplication.shared.setAlternateIconName("newIcon", completionHandler: { (error) in
            if error != nil {
                print("使用新图标错误")
                print(error!)
                return
            }
            print("使用新图标成功")
        })
    }
}

// MARK: - 替换方法
func methodChange(_ cls:AnyClass, leftSelector:Selector, rightSelector:Selector) {
    guard let leftMethod = class_getInstanceMethod(cls, leftSelector) else {
        print("leftMothod 获取失败")
        return
    }
    guard let rightMethod = class_getInstanceMethod(cls, rightSelector) else {
        print("rightMethod 获取失败")
        return
    }
    
    let didAddMethod = class_addMethod(cls, leftSelector, method_getImplementation(rightMethod), method_getTypeEncoding(rightMethod))
    if didAddMethod {
        class_replaceMethod(cls, rightSelector, method_getImplementation(leftMethod), method_getTypeEncoding(leftMethod))
    } else {
        method_exchangeImplementations(leftMethod, rightMethod)
    }
}

