//
//  TaskWorkflow.swift
//  LaunchTask
//
//  Created by Jayden Liu on 2023/2/3.
//  Copyright (c) 2023 Jayden Liu. All rights reserved.
//

import Foundation

public class WaitTask: LaunchTask {
    public override func main(context: [AnyHashable: Any]?) {
        guard let semaphore = workflow?.semaphore else {
            assertionFailure("No semaphore found, unable to wait")
            return
        }
        semaphore.wait()
    }
}

public protocol LaunchWorkflowDelegate: AnyObject {
    func workflowDidFinish(_ workflow: TaskWorkflow)
}

public enum TaskWorkflowState {
    case pending
    case executing
    case finished
}

public class TaskWorkflow {
    public weak var delegate: LaunchWorkflowDelegate?
    public var state: TaskWorkflowState = .pending
    public static let tag = "TaskWorkflow"

    var semaphore: DispatchSemaphore?

    private let name: String
    private var tasks = [LaunchTask]()
    private var unfinishAsyncTaskCount = 0
    private var finishedTasks = [LaunchTask]()
    private let taskLock = NSLock()
    private static let concurrentQueue = DispatchQueue(label: "tasklaunch.concurrent", qos: .userInitiated, attributes: .concurrent)

    public init(name: String) {
        self.name = name
    }

    public func allTasks() -> [LaunchTask] {
        tasks
    }
    
    public func setBlockingTasks(_ blockingTasks: [LaunchTask]) {
        parseNodes(blockingTasks)
        if let _ = tasks.first(where: { $0.queue == .concurrentQueue }) {
            addTask(WaitTask())
        }
    }

    private func parseNodes(_ tasks: [LaunchTask]) {
        let sortedTasks = tasks.sorted { $0.queue == .concurrentQueue && $1.queue == .mainQueue }
        for task in sortedTasks {
            addTask(task)
            if let sons = task.sons {
                parseNodes(sons)
            }
        }
    }

    public func addTask(_ task: LaunchTask) {
        TaskWorkflow.log("Add task \(NSStringFromClass(task.classForCoder)) in \(task.queue == .mainQueue ? "main queue" : "concurrent queue")")
        task.delegate = self
        task.workflow = self

        taskLock.lock()
        tasks.append(task)
        if task.queue == .concurrentQueue {
            unfinishAsyncTaskCount += 1
        }
        if task.isKind(of: WaitTask.self) {
            semaphore = DispatchSemaphore(value: 0)
        }
        taskLock.unlock()
    }

    public func start(context: [AnyHashable: Any]? = nil) {
        state = .executing
        for task in tasks {
            if task.queue == .mainQueue && Thread.isMainThread {
                task.start()
            } else {
                dispatchQueue(task).async {
                    task.start()
                }
            }
        }
    }

    private func dispatchQueue(_ task: LaunchTask) -> DispatchQueue {
        if task.queue == .mainQueue {
            return DispatchQueue.main
        } else {
            return TaskWorkflow.concurrentQueue
        }
    }
}

extension TaskWorkflow: TaskDelegate {
    func taskDidStart(_ task: LaunchTask) {
        if task.queue == .mainQueue {
            TaskWorkflow.log("Task start in main thread: \(String(describing: type(of: task)))")
        } else {
            TaskWorkflow.log("Task start in concurrent thread: \(String(describing: type(of: task)))")
        }
    }

    func taskDidFinish(_ task: LaunchTask) {
        TaskWorkflow.log("Task finish \(String(describing: type(of: task)))  \(Int(task.executionDuration() * 1000))")

        if let semaphore, task.queue == .concurrentQueue {
            taskLock.lock()
            unfinishAsyncTaskCount -= 1
            if unfinishAsyncTaskCount == 0 {
                TaskWorkflow.log("semaphore will signal")
                semaphore.signal()
            }
            taskLock.unlock()
        }

        finishedTasks.append(task)
        if tasks.count == finishedTasks.count {
            state = .finished
            delegate?.workflowDidFinish(self)
        }
    }
}

extension TaskWorkflow {
    public static func log(_ text: String) {
        #if DEBUG
            print("[\(TaskWorkflow.tag)] \(text)")
        #endif
    }
}
