//
//  Protocols.swift
//  MoveKin
//
//  Created by Natan Rolnik on 16/01/19.
//  Copyright © 2019 kinecosystem. All rights reserved.
//

import UIKit

public enum MoveKinAmountOption {
    case specified(UInt)
    case willInput(UIViewController & MoveKinSelectAmountPage)
}

public protocol MoveKinSelectAmountPage: class {
    func setupSelectAmountPage(cancelHandler: @escaping () -> Void, selectionHandler: @escaping (UInt) -> Void)
}

public protocol MoveKinSendingPage {
    func sendKinDidStart(amount: UInt)
    func sendKinDidSucceed(amount: UInt, moveToSentPage: @escaping () -> Void)
    func sendKinDidFail(moveToErrorPage: @escaping () -> Void)
}

public protocol MoveKinSentPage {
    func setupSentKinPage(amount: UInt, finishHandler: @escaping () -> Void)
}

public protocol MoveKinErrorPage {
    func setupMoveKinErrorPage(finishHandler: @escaping () -> Void)
}

public protocol AcceptReceiveKinPage {
    var appName: String { get set }
    func setupAcceptReceiveKinPage(cancelHandler: @escaping () -> Void, acceptHandler: @escaping () -> Void)
}

public protocol SendKinFlowUIProvider: class {
    func viewControllerForConnectingStage(_ app: MoveKinApp) -> UIViewController
    func viewControllerForSendingStage(amount: UInt, app: MoveKinApp) -> UIViewController & MoveKinSendingPage
    func viewControllerForSentStage(amount: UInt, app: MoveKinApp) -> UIViewController & MoveKinSentPage
    func errorViewController() -> UIViewController & MoveKinErrorPage
}

public protocol SendKinFlowDelegate: class {
    func sendKin(amount: UInt, to address: String, app: MoveKinApp, completion: @escaping (Bool) -> Void)
}

public protocol ReceiveKinFlowDelegate: class {
    func acceptReceiveKinViewController() -> UIViewController & AcceptReceiveKinPage
    func provideUserAddress(addressHandler: @escaping (String?) -> Void)
}
