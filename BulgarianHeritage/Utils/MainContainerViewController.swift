//
//  MainContainerViewController.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 20.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import UIKit
import SideMenu

extension MainContainerViewController {
    @objc func menuButtonSelected(_ sender: UIBarButtonItem) {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
        
    }
    
    func dismissMenu(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismiss(animated: flag, completion: completion)
    }
}
class MainContainerViewController: UIViewController {

    var currentViewController: UIViewController?
    private var sideMenuNavigationController: UISideMenuNavigationController?

    init(_ menuViewController: MenuViewController? = nil) {
        if let menuViewController = menuViewController {
            sideMenuNavigationController = UISideMenuNavigationController(rootViewController: menuViewController)
        } else {
            sideMenuNavigationController = nil
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let locale = NSLocale.current.languageCode
        let portionOfMenu: CGFloat = locale == "bg" ? 3/5 : 2.4/5
        view.backgroundColor = UIColor.white
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "MenuButton"), style: .plain, target: self, action: #selector(menuButtonSelected(_:)))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.backBarButtonItem = backBarButtonItem
        SideMenuManager.default.menuLeftNavigationController = sideMenuNavigationController
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuPresentMode = .viewSlideOut
        SideMenuManager.default.menuBlurEffectStyle = .extraLight
        SideMenuManager.default.menuWidth = portionOfMenu * view.frame.width
        SideMenuManager.default.menuAnimationFadeStrength = 0.25
        SideMenuManager.default.menuAnimationDismissDuration = 0.8
        SideMenuManager.default.menuAnimationPresentDuration = 0.8
        SideMenuManager.default.menuAnimationCompleteGestureDuration = 0.8
        SideMenuManager.default.menuShadowColor = UIColor.black
        SideMenuManager.default.menuShadowRadius = 3.0
        SideMenuManager.default.menuShadowOpacity = 1
        sideMenuNavigationController?.navigationBar.isHidden = true
    }

    func presentViewController(_ newViewController: UIViewController, animated: Bool) {
        let preChangeAction = {
            self.currentViewController?.willMove(toParent: nil)
            self.addChild(newViewController)
            self.view.addSubview(newViewController.view)
            newViewController.view.frame = self.view.bounds
            let frame = CGRect(origin: CGPoint(x: 0, y: self.view.bounds.height), size: self.view.bounds.size)
            newViewController.view.frame = frame
        }
        
        let postChangeAction = {
            newViewController.view.frame = self.view.frame
            newViewController.didMove(toParent: self)
            self.currentViewController?.view.removeFromSuperview()
            self.currentViewController?.removeFromParent()
            self.currentViewController = newViewController
        }
        
        preChangeAction()
        if animated == true {
            UIView.animate(withDuration: 1, animations: {
                newViewController.view.frame = self.view.frame
            }, completion: { (_) in
                postChangeAction()
            })
        } else {
            postChangeAction()
        }
    }
    
    func dismissViewController(_ newViewController: UIViewController, animated: Bool) {
        let preChangeAction = {
            self.currentViewController?.willMove(toParent: nil)
            self.addChild(newViewController)
            self.view.addSubview(newViewController.view)
            newViewController.view.frame = self.view.bounds
            if let currentViewController = self.currentViewController {
                currentViewController.view.superview?.bringSubviewToFront(currentViewController.view)
            }
        }
        
        let postChangeAction = {
            newViewController.view.frame = self.view.frame
            newViewController.didMove(toParent: self)
            self.currentViewController?.view.removeFromSuperview()
            self.currentViewController?.removeFromParent()
            self.currentViewController = newViewController
        }
        
        preChangeAction()
        if animated == true {
            UIView.animate(withDuration: 1, animations: {
                let frame = CGRect(origin: CGPoint(x: 0, y: self.view.bounds.height),
                                   size: self.view.bounds.size)
                self.currentViewController?.view.frame = frame
            }, completion: { (_) in
                postChangeAction()
            })
        } else {
            postChangeAction()
        }
    }
}
