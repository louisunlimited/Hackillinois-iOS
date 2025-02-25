//
//  HIApplicationStateController.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 1/21/18.
//  Copyright © 2018 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import UIKit
import SwiftUI
import Keychain

class HIApplicationStateController {
    
    static var shared = HIApplicationStateController()
    
    // MARK: - Properties
    var window = HIWindow(frame: UIScreen.main.bounds)
    var user: HIUser?
    var profile: HIProfile?
    var isGuest = false
    
    // MARK: ViewControllers
    var loginFlowController = HILoginFlowController()
    var appFlowController = HITabBarController()
    var onboardingViewController = HIOnboardingViewController()
    // MARK: - Init
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(loginUser), name: .loginUser, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logoutUser), name: .logoutUser, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loginProfile), name: .loginProfile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getStarted), name: .getStarted, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initalize() {
        window.makeKeyAndVisible()
        
        resetPersistentDataIfNeeded()
        recoverUserIfPossible()
        recoverProfileIfPossible()
        
        onboardingViewController.shouldDisplayAnimationOnNextAppearance = user == nil
        
        UserDefaults.standard.set(true, forKey: HIConstants.APPLICATION_INSTALLED_KEY)
        let shouldShowOnboarding = UserDefaults.standard.object(forKey: HIConstants.SHOULD_SHOW_ONBOARDING_KEY) as? Bool ?? true
        updateWindowViewController(animated: false, shouldShowOnboarding: shouldShowOnboarding)
    }
}

// MARK: - API
extension HIApplicationStateController {
    func resetPersistentDataIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: HIConstants.APPLICATION_INSTALLED_KEY) else { return }
        _ = Keychain.default.purge()
        HICoreDataController.shared.purge()
        UserDefaults.standard.set(true, forKey: HIConstants.APPLICATION_INSTALLED_KEY)
    }
    
    func recoverUserIfPossible() {
        guard Keychain.default.hasValue(forKey: HIConstants.STORED_ACCOUNT_KEY) else { return }
        guard let user = Keychain.default.retrieve(HIUser.self, forKey: HIConstants.STORED_ACCOUNT_KEY) else {
            Keychain.default.removeObject(forKey: HIConstants.STORED_ACCOUNT_KEY)
            return
        }
        isGuest = false
        if user.provider == .guest || user.provider == .google {
            isGuest = true
        }
        self.user = user
    }
    
    func recoverProfileIfPossible() {
        guard Keychain.default.hasValue(forKey: HIConstants.STORED_PROFILE_KEY) else { return }
        guard let profile = Keychain.default.retrieve(HIProfile.self, forKey: HIConstants.STORED_PROFILE_KEY) else {
            Keychain.default.removeObject(forKey: HIConstants.STORED_PROFILE_KEY)
            return
        }
        self.profile = profile
    }
    
    func viewControllersFor(user: HIUser) -> [UIViewController] {
        var viewControllers = [UIViewController]()
        viewControllers.append(HIHomeViewController())
        viewControllers.append(HIScheduleViewController())
        viewControllers.append(HIScanQRCodeViewController())
        viewControllers.append(HIProfileViewController())
        viewControllers.append(HILeaderboardViewController())
        return viewControllers
    }
    
    @objc func loginUser(_ notification: Notification) {
        guard let user = notification.userInfo?["user"] as? HIUser else { return }
        guard Keychain.default.store(user, forKey: HIConstants.STORED_ACCOUNT_KEY) else { return }
        self.user = user
        isGuest = false
        if user.provider == .guest || user.provider == .google {
            isGuest = true
        }
        HILocalNotificationController.shared.requestAuthorization()
        UIApplication.shared.registerForRemoteNotifications()
        updateWindowViewController(animated: true, shouldShowOnboarding: false)
    }
    
    @objc func logoutUser() {
        guard user != nil else { return }
        guard profile != nil else { return }
        Keychain.default.removeObject(forKey: HIConstants.STORED_ACCOUNT_KEY)
        Keychain.default.removeObject(forKey: HIConstants.STORED_PROFILE_KEY)
        user = nil
        profile = nil
        updateWindowViewController(animated: true, shouldShowOnboarding: false)
    }
    
    @objc func loginProfile(_ notification: Notification) {
        guard let profile = notification.userInfo?["profile"] as? HIProfile else { return }
        guard Keychain.default.store(profile, forKey: HIConstants.STORED_PROFILE_KEY) else { return }
        self.profile = profile
    }
    @objc func getStarted(_ notification: Notification) {
        updateWindowViewController(animated: true, shouldShowOnboarding: false)
        // No longer need to show onboarding
        UserDefaults.standard.set(false, forKey: HIConstants.SHOULD_SHOW_ONBOARDING_KEY)
    }
    
    func updateWindowViewController(animated: Bool, shouldShowOnboarding: Bool) {
        let viewController: UIViewController
        if shouldShowOnboarding {
            //            if #available(iOS 14.0, *) {
            viewController = UIHostingController(rootView: HIOnboardingView())
            //            } else {
            //                viewController = onboardingViewController
            //            }
            //            viewController = onboardingViewController
        } else if let user = user {
            prepareAppControllerForDisplay(with: user)
            viewController = appFlowController
        } else {
            viewController = loginFlowController
        }
        
        let duration = animated ? 0.3 : 0
        viewController.view.layoutIfNeeded()
        UIView.transition(with: window, duration: duration, options: .transitionCrossDissolve, animations: {
            self.window.rootViewController = viewController
        }, completion: nil)
    }
    
    func prepareAppControllerForDisplay(with user: HIUser) {
        let appViewControllers = viewControllersFor(user: user)
        appFlowController.setupMenuFor(appViewControllers)
        appFlowController.selectedIndex = 0
        
        // Disable the middle tabbar button (QR Code)
        if let items = appFlowController.tabBar.items {
            if items.count >= 3 {
                items[2].isEnabled = false
            }
        }
        
        HIEventDataSource.refresh()
        HIAnnouncementDataSource.refresh()
        HIProjectDataSource.refresh()
        HIProfileDataSource.refresh()
    }
}
