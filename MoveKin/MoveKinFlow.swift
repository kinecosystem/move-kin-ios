//
//  MoveKinFlow.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import UIKit

public class MoveKinFlow {
    public var isHapticFeedbackEnabled = true

    fileprivate var destinationAddress: PublicAddress?
    fileprivate var amountOption: MoveKinAmountOption?
    fileprivate var app: MoveKinApp?

    let getAddressFlow = GetAddressFlow()
    let provideAddressFlow = ProvideAddressFlow()

    public weak var sendDelegate: SendKinFlowDelegate?
    public weak var sendFlowUIProvider: SendKinFlowUIProvider?

    public weak var receiveDelegate: ReceiveKinFlowDelegate?

    private var navigationController: UINavigationController?

    public init() {}

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

    public func getAddress(for destinationApp: MoveKinApp, completion: @escaping GetAddressFlowCompletion) {
        guard getAddressFlow.state == .idle else {
            return
        }

        getAddressFlow.startMoveKinFlow(to: destinationApp, completion: completion)
    }

    public func startMoveKinFlow(to destinationApp: MoveKinApp,
                                 amountOption: MoveKinAmountOption,
                                 navigationBarImage: UIImage? = nil) {
        guard sendDelegate != nil else {
            fatalError("MoveKin flow started, but no sendDelegate was set: moveKinFlow.sendDelegate = yourDelegate")
        }

        guard let uiProvider = sendFlowUIProvider else {
            fatalError("MoveKin flow started, but no uiProvider was set: moveKinFlow.uiProvider = yourProvider")
        }

        guard getAddressFlow.state == .idle else {
            return
        }

        self.app = destinationApp
        self.amountOption = amountOption

        let connectingViewController = uiProvider.viewControllerForConnectingStage(destinationApp)
        navigationController = MoveKinNavigationController(rootViewController: connectingViewController)
        navigationController!.setNavigationBarHidden(true, animated: false)
        navigationController!.navigationBar.setBackgroundImage(navigationBarImage, for: .default)
        presenter?.present(navigationController!, animated: true) { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
                self?.connectingAppsDidPresent(to: destinationApp)
            })
        }
    }

    fileprivate func amountSelected(_ amount: UInt) {
        guard
            let sendDelegate = sendDelegate,
            let uiProvider = sendFlowUIProvider else {
            fatalError("MoveKin flow is in progress, but no delegate or uiProvider are set")
        }

        guard
            let destinationAddress = destinationAddress,
            let app = app else {
            fatalError("MoveKin flow will start sending, but no destinationAddress or app are set.")
        }

        let sendingViewController = uiProvider.viewControllerForSendingStage(amount: amount, app: app)
        navigationController!.pushViewController(sendingViewController, animated: true)
        sendingViewController.sendKinDidStart(amount: amount)
        sendDelegate.sendKin(amount: amount, to: destinationAddress.asString, app: app) { success in
            DispatchQueue.main.async {
                guard success else {
                    sendingViewController.sendKinDidFail(moveToErrorPage: { [weak self] in
                        self?.sendKinDidFail()
                    })

                    return
                }

                sendingViewController.sendKinDidSucceed(amount: amount) { [weak self] in
                    self?.sendKinDidSucceed(amount: amount, app: app)
                }
            }
        }
    }

    private func sendKinDidFail() {
        guard
            let navController = navigationController,
            let uiProvider = sendFlowUIProvider else {
            return
        }

        if #available(iOS 10.0, *), self.isHapticFeedbackEnabled {
            let feedbackGenerator = UINotificationFeedbackGenerator()
            feedbackGenerator.prepare()
            feedbackGenerator.notificationOccurred(.error)
        }

        let errorPageViewController = uiProvider.errorViewController()
        errorPageViewController.setupMoveKinErrorPage { [weak self] in
            self?.finishFlow()
        }

        navController.pushViewController(errorPageViewController, animated: true)
    }

    private func sendKinDidSucceed(amount: UInt, app: MoveKinApp) {
        guard
            let navController = navigationController,
            let uiProvider = sendFlowUIProvider else {
            return
        }

        if #available(iOS 10.0, *), isHapticFeedbackEnabled {
            let feedbackGenerator = UINotificationFeedbackGenerator()
            feedbackGenerator.prepare()
            feedbackGenerator.notificationOccurred(.success)
        }

        let sentViewController = uiProvider.viewControllerForSentStage(amount: amount, app: app)
        sentViewController.setupSentKinPage(amount: amount, finishHandler: { [weak self] in
            self?.finishFlow()
        })
        navController.pushViewController(sentViewController, animated: true)
    }

    private func connectingAppsDidPresent(to destinationApp: MoveKinApp) {
        getAddressFlow.startMoveKinFlow(to: destinationApp) { result in
            switch result {
            case .success(let publicAddress):
                self.getAddressFlowDidSucceed(with: publicAddress)
            case .cancelled:
                self.finishFlow()
            case .error(let error):
                self.getAddressFlowDidFail(error)
            }
        }
    }

    public func canHandleURL(_ url: URL) -> Bool {
        guard url.host == Constants.urlHost else {
            return false
        }

        guard url.path == Constants.receiveAddressURLPath
            || url.path == Constants.requestAddressURLPath else {
                return false
        }

        return true
    }

    public func handleURL(_ url: URL, from appBundleId: String) {
        guard url.host == Constants.urlHost else {
            return
        }

        switch url.path {
        case Constants.receiveAddressURLPath:
            getAddressFlow.handleURL(url, from: appBundleId)
        case Constants.requestAddressURLPath:
            guard let receiveDelegate = receiveDelegate
                else {
                let message =
                """
                MoveKin flow received requestAddressURL (\(Constants.requestAddressURLPath)) but receiveDelegate
                isn't set:

                moveKinFlow.receiveDelegate = yourDelegate
                or
                moveKinFlow.receiveUIProvider = yourUIProvider
                """
                print(message)
                return
            }

            provideAddressFlow.handleURL(url,
                                         from: appBundleId,
                                         receiveDelegate: receiveDelegate)
        default:
            break
        }
    }

    fileprivate func finishFlow() {
        navigationController?.dismiss(animated: true)
        navigationController = nil

        destinationAddress = nil
        amountOption = nil
    }
}

// MARK: - Success Handling
fileprivate extension MoveKinFlow {
    func getAddressFlowDidSucceed(with publicAddress: PublicAddress) {
        // Network requests fail when the app didn't finish to transition to foreground.
        // Also, for a better transition, delay the calls below by 0.5s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.destinationAddress = publicAddress

            switch self.amountOption! {
            case .specified(let amount):
                self.amountSelected(amount)
            case .willInput(let inputViewController):
                inputViewController.setupSelectAmountPage(cancelHandler: { [weak self] in
                    self?.finishFlow()
                }, selectionHandler: { [weak self] amount in
                    self?.amountSelected(amount)
                })

                self.navigationController!.pushViewController(inputViewController, animated: true)
            }
        }
    }
}

// MARK: - Error Handling
extension MoveKinFlow {
    func getAddressFlowDidFail(_ error: GetAddressFlowTypes.Error) {
        switch error {
        case .timeout:
            finishFlow()
        case .appLaunchFailed(let app):
            handleOpenAppStore(for: app)
        case .noAccount:
            getAddressFlowNoAccount()
        case.bundleIdMismatch,
            .invalidAddress,
            .invalidHandleURL,
            .invalidURLScheme,
            .invalidLaunchParameters:
            displayGeneralErrorAlert()
        }
    }

    private func displayGeneralErrorAlert() {
        let message = "There was a problem establishing a connection. Please try again in a bit."
        let alertController = UIAlertController(title: "Echo… Echo… Echo…",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(.init(title: "Back", style: .default) { [weak self] _ in
            self?.finishFlow()
        })
        navigationController?.present(alertController, animated: true)
    }

    private func getAddressFlowNoAccount() {
        displayGeneralErrorAlert()
    }

    private func handleOpenAppStore(for destinationApp: MoveKinApp) {
        guard let presented = navigationController else {
            return
        }

        let alertController = UIAlertController(title: "That app’s not here… yet ",
                                                message: "Download the app and create a wallet to send your Kin",
                                                preferredStyle: .alert)
        alertController.addAction(.init(title: "To the store", style: .default) { _ in
            presented.dismiss(animated: true) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(destinationApp.appStoreURL)
                } else {
                    UIApplication.shared.openURL(destinationApp.appStoreURL)
                }
            }
        })

        alertController.addAction(.init(title: "Back", style: .cancel) { _ in
            presented.dismiss(animated: true)
        })
        presented.present(alertController, animated: true, completion: nil)
    }
}
