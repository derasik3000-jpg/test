//
//  FlowCoordinator.swift
//  DAYTRACE
//
//  Base coordinator protocol
//

import UIKit

protocol FlowCoordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}
