//
//  AppContainerViewController.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 1.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import UIKit

class AppContainerViewController: UIViewController {
    
    var currentViewController: UIViewController?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
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
