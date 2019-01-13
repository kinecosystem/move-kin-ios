//
//  Bundle+Extensions.swift
//  MoveKin
//
//  Created by Natan Rolnik on 13/01/19.
//  Copyright © 2019 kinecosystem. All rights reserved.
//

import Foundation

extension Bundle {
    static var appName: String? {
        return main.infoDictionary?["CFBundleDisplayName"] as? String
            ?? main.infoDictionary?["CFBundleName"] as? String
    }

    static var firstAppURLScheme: String? {
        guard let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [AnyObject],
            let urlTypesDictionary = urlTypes.first as? [String: AnyObject],
            let urlSchemes = urlTypesDictionary["CFBundleURLSchemes"] as? [String] else {
                return nil
        }

        return urlSchemes.first
    }
}
