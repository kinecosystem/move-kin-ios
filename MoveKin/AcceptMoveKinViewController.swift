//
//  AcceptMoveKinViewController.swift
//  MoveKin
//
//  Created by Natan Rolnik on 13/01/19.
//  Copyright © 2019 kinecosystem. All rights reserved.
//

import UIKit

let thisBundle = Bundle(for: AcceptMoveKinViewController.self)

private func messageText(for sourceApp: String) -> String {
    let thisApp = Bundle.appName!
    return "In order to send Kin, \(sourceApp) would like to receive your Kin account information (i.e. your public address) from \(thisApp)."
}

class AcceptMoveKinViewController: UIViewController {
    var appName: String!
    var appURLScheme: String!
    weak var delegate: MoveKinFlowDelegate?

    let messageLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 0
        l.font = UIFont.systemFont(ofSize: 16)

        return l
    }()

    let acceptButton: UIButton = {
        let b = UIButton(type: .custom)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("I agree", for: .normal)
        let image = UIImage(named: "MK-ButtonBackground", in: thisBundle, compatibleWith: nil)
        b.setBackgroundImage(image, for: .normal)
        b.widthAnchor.constraint(equalToConstant: 280).isActive = true

        return b
    }()

    let kinImageView = UIImageView(image: UIImage(named: "MK-KinEcosystemLogo", in: thisBundle, compatibleWith: nil))

    override func loadView() {
        let v = UIView()
        v.backgroundColor = .white

        let stackView = UIStackView(arrangedSubviews: [kinImageView, messageLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .fillProportionally

        v.addSubview(stackView)
        let yConstraint = NSLayoutConstraint(item: stackView,
                                             attribute: .centerY,
                                             relatedBy: .equal,
                                             toItem: v,
                                             attribute: .centerY,
                                             multiplier: 0.75,
                                             constant: 0)
        NSLayoutConstraint.activate([stackView.centerXAnchor.constraint(equalTo: v.centerXAnchor),
                                     yConstraint,
                                     stackView.widthAnchor.constraint(equalToConstant: 280)])

        v.addSubview(acceptButton)
        acceptButton.tintColor = .white
        v.centerXAnchor.constraint(equalTo: acceptButton.centerXAnchor).isActive = true
        v.bottomAnchor.constraint(equalTo: acceptButton.bottomAnchor, constant: 90).isActive = true

        view = v
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Kin Ecosystem"
        let closeImage = UIImage(named: "CloseButton", in: thisBundle, compatibleWith: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: closeImage,
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(cancel))
        messageLabel.text = messageText(for: appName)
        acceptButton.addTarget(self, action: #selector(accept), for: .touchUpInside)
    }

    @objc func cancel() {
        let url = LaunchURLBuilder.provideAddressCancelledURL(urlScheme: appURLScheme)
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }

        dismiss(animated: true)
    }

    @objc func accept() {
        guard let delegate = delegate else {
            cancel()
            return
        }

        delegate.provideUserAddress { [weak self] address in
            guard let self = self else {
                return
            }

            DispatchQueue.main.async {
                let url: URL

                if let address = address {
                    url = LaunchURLBuilder.provideAddressURL(address: address, urlScheme: self.appURLScheme)
                } else {
                    url = LaunchURLBuilder.provideAddressNoAccount(urlScheme: self.appURLScheme)
                }

                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }

                self.dismiss(animated: true)
            }
        }
    }
}

