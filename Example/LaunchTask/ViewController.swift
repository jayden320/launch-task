//
//  ViewController.swift
//  LaunchTask
//
//  Created by Jayden Liu on 02/03/2023.
//  Copyright (c) 2023 Jayden Liu. All rights reserved.
//

import UIKit
import LaunchTask

class TaskI: LaunchTask {
    override func main(context: [AnyHashable: Any]?) {
        sleep(1)
    }
}

class TaskJ: LaunchTask {
    override func main(context: [AnyHashable: Any]?) {
        sleep(1)
    }
}

class TaskK: LaunchTask {
    override func main(context: [AnyHashable: Any]?) {
        sleep(1)
    }
}

class ViewController: UIViewController {
    var firstScreenWorkflow = TaskWorkflow(name: "FirstScreen")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray
        firstScreenWorkflow.addTask(TaskI())
        firstScreenWorkflow.addTask(TaskJ(queue: .concurrentQueue))
        firstScreenWorkflow.addTask(TaskK())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstScreenWorkflow.state == .pending {
            firstScreenWorkflow.start()
        }
    }
}

