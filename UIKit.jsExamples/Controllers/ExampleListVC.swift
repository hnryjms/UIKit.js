//
//  MasterViewController.swift
//  UIKit.jsExamples
//
//  Created by Hank Brekke on 12/9/18.
//  Copyright © 2018 Hank Brekke. All rights reserved.
//

import UIKit
import UIKitJS
import Unbox

struct ExampleItem: Unboxable {
    let title: String
    let scene: String

    init(unboxer: Unboxer) throws {
        self.title = try unboxer.unbox(key: "title")
        self.scene = try unboxer.unbox(key: "scene")
    }
}

class ExampleListVC: UITableViewController {
    var exampleController: ExampleItemVC? = nil
    var examples: [ExampleItem]? = nil {
        didSet {
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.bridge!.invoke(JSOperation("MasterService.loadData()")!, withArguments: []) { result, error in
            if let result = result, let examples: [ExampleItem] = try? unbox(values: result) {
                self.examples = examples
            } else {
                let alert = UIAlertController(
                    title: "JavaScript Error",
                    message: "\(error?.toObject() ?? "Unknown JS error")",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell) {
                let example = self.examples![indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! ExampleItemVC
                controller.exampleItem = example
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.examples?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = self.examples![indexPath.row]
        cell.textLabel!.text = object.title
        return cell
    }
}
