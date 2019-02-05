//
//  ReceiveAddressFlow.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import Foundation
import UIKit

class ProvideAddressFlow {
    private var presenter: UIViewController? {
        guard let appDelegate = UIApplication.shared.delegate,
            var viewController = appDelegate.window??.rootViewController else {
                return nil
        }

        while let presented = viewController.presentedViewController {
            viewController = presented
        }

        return viewController
    }

    func canHandleURL(_ url: URL) -> Bool {
        guard url.host == Constants.urlHost, url.path == Constants.requestAddressURLPath else {
            return false
        }

        return true
    }

    func handleURL(_ url: URL, from appBundleId: String, receiveDelegate: MoveKinReceiveDelegate) {
        guard url.host == Constants.urlHost, url.path == Constants.requestAddressURLPath else {
            return
        }

        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = urlComponents.queryItems,
            let appURLScheme = queryItems.first(where: { $0.name == Constants.callerAppURLSchemeQueryItem })?.value else {
                return
        }

        guard
            let appName = queryItems.first(where: { $0.name == Constants.callerAppNameQueryItem })?.value,
            let presenter = presenter else {
                let url = LaunchURLBuilder.provideAddressInvalidURL(urlScheme: appURLScheme)
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
                return
        }

        let viewController = AcceptMoveKinViewController()
        viewController.delegate = receiveDelegate
        viewController.appName = appName
        viewController.appURLScheme = appURLScheme
        let navigationController = UINavigationController(rootViewController: viewController)
        presenter.present(navigationController, animated: true)
    }
}
