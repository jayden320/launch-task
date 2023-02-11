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
        sleep(1)
    }
}

class TaskB: LaunchTask {
    override func main(context: [AnyHashable: Any]?) {
        sleep(1)
    }
}

class TaskC: LaunchTask {
    override func main(context: [AnyHashable: Any]?) {
        sleep(1)
    }
}

class TaskD: LaunchTask {
    override func main(context: [AnyHashable: Any]?) {
        sleep(1)
    }
}

class TaskE: LaunchTask {
    override func main(context: [AnyHashable: Any]?) {
        sleep(2)
    }
}

class TaskF: LaunchTask {
    override func main(context: [AnyHashable: Any]?) {
        sleep(5)
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
        sleep(1)
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var launchWorkflow = TaskWorkflow(name: "Launch")
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if NSClassFromString("XCTestCase") != nil {
            return true
        }
        
        launchWorkflow.setBlockingTasks([
            TaskA(),
            TaskB(),
            TaskC(sons: [TaskD()]),
            TaskE(queue: .concurrentQueue),
            TaskF(queue: .concurrentQueue),
        ])
        launchWorkflow.addTask(TaskG())
        launchWorkflow.addTask(TaskH())
        launchWorkflow.start()
        return true
    }
}

