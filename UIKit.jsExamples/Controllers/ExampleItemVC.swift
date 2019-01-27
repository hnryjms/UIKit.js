//
//  DetailViewController.swift
//  UIKit.jsExamples
//
//  Created by Hank Brekke on 12/9/18.
//  Copyright © 2018 Hank Brekke. All rights reserved.
//

import UIKit

class ExampleItemVC: UIViewController {
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.exampleItem {
            self.title = detail.title

            self.view.subviews.forEach { $0.removeFromSuperview() }

            let controller = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: detail.scene)

            controller.view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(controller.view)

            NSLayoutConstraint.activate([
                self.view.topAnchor.constraint(equalTo: controller.view.topAnchor),
                self.view.leftAnchor.constraint(equalTo: controller.view.leftAnchor),
                self.view.rightAnchor.constraint(equalTo: controller.view.rightAnchor),
                self.view.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor),
            ])
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    var exampleItem: ExampleItem? {
        didSet {
            // Update the view.
            configureView()
        }
    }
}
