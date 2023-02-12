//
//  AppDelegate.swift
//  LaunchTask
//
//  Created by Jayden Liu on 02/03/2023.
//  Copyright (c) 2023 Jayden Liu. All rights reserved.
//

import UIKit
import LaunchTask

class TaskA: LaunchTask {
    override func main(context: [AnyHashable: Any]?) {
        Thread.sleep(forTimeInterval: 0.2)
    }
}

class TaskB: LaunchTask {
    override func main(context: [AnyHashable: Any]?) {
        Thread.sleep(forTimeInterval: 0.2)
    }
}

class TaskC: LaunchTask {
    override func main(context: [AnyHashable: Any]?) {
        Thread.sleep(forTimeInterval: 0.2)
    }
}

class TaskD: LaunchTask {
    override func main(context: [AnyHashable: Any]?) {
        Thread.sleep(forTimeInterval: 0.2)
    }
}

class TaskE: LaunchTask {
    override func main(context: [AnyHashable: Any]?) {
        Thread.sleep(forTimeInterval: 0.1)
    }
}

class TaskF: LaunchTask {
    override func main(context: [AnyHashable: Any]?) {
        Thread.sleep(forTimeInterval: 0.2)
    }
}

class TaskG: LaunchTask {
    override func main(context: [AnyHashable: Any]?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let window = UIWindow(frame: UIScreen.main.bounds)
        appDelegate.window = window
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()
    }
}

class TaskH: LaunchTask {
    override func main(context: [AnyHashable: Any]?) {
        Thread.sleep(forTimeInterval: 0.2)
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if NSClassFromString("XCTestCase") != nil {
            return true
        }
        let workflow = TaskWorkflow(name: "Launch")
        workflow.delegate = self
        workflow.addTask(TaskA())
        workflow.addTask(TaskB())
        workflow.addBlockingTasks([
            TaskC(),
            TaskD(),
            TaskE(queue: .concurrentQueue),
            TaskF(queue: .concurrentQueue),
        ])
        workflow.addTask(TaskG())
        workflow.addTask(TaskH())
        workflow.start()
        return true
    }
}

extension AppDelegate: TaskWorkflowDelegate {
    func workflowDidFinish(_ workflow: TaskWorkflow) {
        print(workflow.generateTimeline())
    }
}
