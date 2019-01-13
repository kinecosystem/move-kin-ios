//
//  Constants.swift
//  KinWallet
//
//  Copyright © 2019 KinFoundation. All rights reserved.
//

import Foundation

internal struct Constants {
    static let urlHost = "org.kinecosystem.movekin"
    static let requestAddressURLPath = "/request-address"
    static let callerAppNameQueryItem = "appName"
    static let callerAppURLSchemeQueryItem = "urlScheme"

    static let receiveAddressURLPath = "/receive-address"
    static let receiveAddressQueryItem = "address"
    static let receiveAddressStatusQueryItem = "status"
    static let receiveAddressStatusOk = "ok"
    static let receiveAddressStatusCancelled = "cancelled"
    static let receiveAddressStatusNoAccount = "no-account"
    static let receiveAddressStatusInvalid = "invalid-params"

    static let didBecomeActiveTimeout: TimeInterval = 1
}
