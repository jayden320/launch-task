//
//  TaskWorkflow.swift
//  LaunchTask
//
//  Created by Jayden Liu on 2023/2/3.
//  Copyright (c) 2023 Jayden Liu. All rights reserved.
//

import Foundation

public protocol TaskWorkflowDelegate: AnyObject {
    func workflowDidFinish(_ workflow: TaskWorkflow)
}

public enum TaskWorkflowState {
    case pending
    case executing
    case finished
}

private class WaitTask: LaunchTask {
    var unfinishAsyncTaskCount = 0
    let semaphore = DispatchSemaphore(value: 0)

    public override func main(context: [AnyHashable: Any]?) {
        semaphore.wait()
    }

    func signalIfNeed() {
        unfinishAsyncTaskCount -= 1
        if unfinishAsyncTaskCount == 0 {
            TaskWorkflow.log("semaphore will signal")
            semaphore.signal()
        }
    }
    
    override func internalName() -> String {
        "Waiting"
    }
}

public class TaskWorkflow {
    public weak var delegate: TaskWorkflowDelegate?
    public private(set) var state: TaskWorkflowState = .pending
    public let name: String
    public var concurrentQueue = TaskWorkflow.concurrentQueue
    
    private static var concurrentQueue = DispatchQueue(label: "tasklaunch.concurrent", qos: .userInitiated, attributes: .concurrent)
    private static let tag = "TaskWorkflow"
    private var tasks = [LaunchTask]()
    private var finishedTasks = [LaunchTask]()
    private var waitTasks = [WaitTask]()
    private let taskLock = NSLock()

    public init(name: String) {
        self.name = name
    }

    public func allTasks() -> [LaunchTask] {
        tasks
    }

    public func addBlockingTasks(_ blockingTasks: [LaunchTask]) {
        let waitTask = WaitTask()
        let sortedTasks = blockingTasks.sorted { $0.queue == .concurrentQueue && $1.queue == .mainQueue }
        for task in sortedTasks {
            addTask(task)
            if task.queue == .concurrentQueue {
                waitTask.unfinishAsyncTaskCount += 1
            }
        }
        if waitTask.unfinishAsyncTaskCount > 0 {
            addTask(waitTask)
        }
    }

    public func addTask(_ task: LaunchTask) {
        assert(state == .pending, "Workflow has started running or has ended. The task will not be executed")

        task.workflow = self

        taskLock.lock()
        tasks.append(task)
        if let waitTask = task as? WaitTask {
            waitTasks.append(waitTask)
        }
        taskLock.unlock()
    }

    public func start(context: [AnyHashable: Any]? = nil) {
        state = .executing
        for task in tasks {
            if task.queue == .mainQueue && Thread.isMainThread {
                TaskWorkflow.log("Task start in main thread: \(task.internalName())")
                task.start()
            } else {
                dispatchQueue(task).async {
                    TaskWorkflow.log("Task start in concurrent thread: \(task.internalName())")
                    task.start()
                }
            }
        }
    }

    func taskDidFinish(_ task: LaunchTask) {
        TaskWorkflow.log("Task finish \(task.internalName())  \(Int(task.executionDuration() * 1000))")

        taskLock.lock()
        if let waitTask = waitTasks.first, task.queue == .concurrentQueue {
            waitTask.signalIfNeed()
        }
        if task is WaitTask {
            waitTasks.remove(at: 0)
        }
        finishedTasks.append(task)

        taskLock.unlock()

        if tasks.count == finishedTasks.count {
            state = .finished
            TaskWorkflow.log("TaskWorkflow did finish: \(name)")
            delegate?.workflowDidFinish(self)
        }
    }

    public func generateTimeline() -> String {
        if state == .pending {
            return "[\(name) waiting to start]"
        }
        var mainThreadTimeline = "[\(name) start]"
        var subthreadTimeline = ""
        for task in tasks {
            let taskDesc = "[\(task.internalName()) \(Int(task.executionDuration() * 1000))ms]"
            if task.queue == .mainQueue {
                mainThreadTimeline += " - \(taskDesc) "
            } else {
                subthreadTimeline += String(repeating: " ", count: mainThreadTimeline.count)
                subthreadTimeline += " - \(taskDesc)\n"
            }
        }
        if state == .finished {
            mainThreadTimeline += " - [\(name) finish]"
        }
        return mainThreadTimeline + "\n" + subthreadTimeline
    }

    static func log(_ text: String) {
        #if DEBUG
            print("[\(TaskWorkflow.tag)] \(text)")
        #endif
    }

    private func dispatchQueue(_ task: LaunchTask) -> DispatchQueue {
        if task.queue == .mainQueue {
            return DispatchQueue.main
        } else {
            return concurrentQueue
        }
    }
}
