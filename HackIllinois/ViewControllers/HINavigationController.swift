//
//  HINavigationController.swift
//  HackIllinois
//
//  Created by HackIllinois Team on 2/21/18.
//  Copyright © 2018 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import UIKit

class HINavigationController: UINavigationController {

    private let infoTitle = HILabel(style: .navigationInfo, additionalConfiguration: nil)
    var infoTitleIsHidden = true {
        didSet {
            infoTitle.isHidden = infoTitleIsHidden
        }
    }

    var statusBarIsHidden = false
    override var prefersStatusBarHidden: Bool {
        return statusBarIsHidden
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return (\HIAppearance.preferredStatusBarStyle).value
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        title = rootViewController.title
        NotificationCenter.default.addObserver(self, selector: #selector(refreshForThemeChange), name: .themeDidChange, object: nil)
        refreshForThemeChange()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) should not be used.")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Themeable
    @objc func refreshForThemeChange() {
        navigationBar.tintColor <- \.accent
        navigationBar.barTintColor <- \.clear
        navigationBar.isTranslucent = true

        navigationBar.addSubview(infoTitle)
        infoTitle.constrain(to: navigationBar, trailingInset: 0, bottomInset: 5, leadingInset: 20)
        infoTitle.constrain(height: 10)
        infoTitle.translatesAutoresizingMaskIntoConstraints = false
        infoTitle.isHidden = infoTitleIsHidden
        infoTitle.text = "All times are in CDT"

        additionalSafeAreaInsets.top = 15
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: (\HIAppearance.titleText).value as Any,
            NSAttributedString.Key.font: (HIAppearance.Font.contentTitle) as Any
        ]

        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        (\HIAppearance.clear).value.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        navigationBar.setBackgroundImage(image, for: .default)
    }
}
