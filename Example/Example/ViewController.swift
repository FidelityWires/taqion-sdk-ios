//
//  ViewController.swift
//  Example
//
//  Created by Saika Natsui on 2020/06/22.
//  Copyright © 2020 FidelityWires. All rights reserved.
//

import UIKit
import Taqion
import TaqionCore

final class ViewController: UIViewController {

    /// Initialize `ServiceStatusInspector`
    private let serviceStatusInspector = ServiceStatusInspector()

    @IBOutlet private weak var availableView: UIStackView!
    @IBOutlet private weak var notAvailableView: UIStackView!
    @IBOutlet private weak var label: UILabel!

    private var currentSettings: [ServiceStatusInspector.DebugSetting] = [
        .init(service: .googleAnalytics, isAvailable: true),
        .init(service: .googleConsole, isAvailable: true),
        .init(service: .googleMaps, isAvailable: false),
        .init(service: .googleDrive, isAvailable: false)
    ]

    private var services: [Service] {
        currentSettings.map({ $0.service })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set API Key.
        Taqion.sharedInstance().setApiKey("xxxxx")

        let _ = serviceStatusInspector

            // If you would like to use Debug Mode.
            // Please go　Product -> Scheme -> Edit Scheme
            // Set `-STAWNDebugEnabled` as `Aguments Passed On Launch`
            .setDebug(settings: currentSettings)

        // Start inspection.
        inspect()
    }

    private func inspect() {

        serviceStatusInspector.inspect(
            services: services,
            completion: { (result) in
                switch result {
                case .success(let status):

                    if status.isAllAvailable() {
                        // All serivces are available.
                        self.availableView.isHidden = false
                        self.notAvailableView.isHidden = true
                    } else {
                        // Some services are not available.
                        self.availableView.isHidden = true
                        self.notAvailableView.isHidden = false
                        self.label.text = status.serviceStatuses.unavailableServices()
                    }
                case .failure(let error):
                    // Handle inspection error.
                    print(error.localizedDescription)
                }
        })
    }

    /// Go to Debug Setting
    @IBAction private func buttonDidTap() {
        let viewController = DebugSettingViewController.instantiate()
        viewController.delegate = self
        viewController.settings = currentSettings
        present(viewController, animated: true)
    }

}

extension ViewController: DebugSettingViewControllerDelegate {

    func settingDidUpdate(settings: [ServiceStatusInspector.DebugSetting]) {
        currentSettings = settings
        let _ = serviceStatusInspector.setDebug(settings: currentSettings)
        inspect()
    }
}

extension Sequence where Element == ServiceStatus {

    func unavailableServices() -> String {
        self.compactMap { (serviceStatus) -> String? in
            if !serviceStatus.isAvailable {
                return serviceStatus.service.service?.rawValue
            }
            return nil
        }.joined(separator: "\n")
    }
}
