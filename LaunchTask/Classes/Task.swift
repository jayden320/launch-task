//
//  LaunchTask.swift
//  LaunchTask
//
//  Created by Jayden Liu on 2023/2/3.
//  Copyright (c) 2023 Jayden Liu. All rights reserved.
//

import Foundation

public protocol TaskDelegate: AnyObject {
    func taskDidStart(_ task: LaunchTask)
    func taskDidFinish(_ task: LaunchTask)
}

public enum TaskState {
    case pending
    case executing
    case finished
}

public enum TaskQueue: String {
    case mainQueue
    case concurrentQueue
}

open class LaunchTask {
    public let queue: TaskQueue
    public private(set) var state: TaskState = .pending
    public weak var delegate: TaskDelegate?
    public internal(set) var name: String?

    weak var workflow: TaskWorkflow?

    private var startDate: Date?
    private var endDate: Date?

    public init(name: String? = nil, queue: TaskQueue = .mainQueue) {
        self.queue = queue
        self.name = name
    }
    
    public func start(context: [AnyHashable: Any]? = nil) {
        startDate = Date()
        state = .executing
        delegate?.taskDidStart(self)
        main(context: context)
        endDate = Date()
        state = .finished
        workflow?.taskDidFinish(self)
        delegate?.taskDidFinish(self)
    }

    open func main(context: [AnyHashable: Any]?) {}

    public func executionDuration() -> Double {
        guard let startDate, let endDate else {
            return 0
        }
        return endDate.timeIntervalSince(startDate)
    }
    
    func internalName() -> String {
        if let name {
            return name
        }
        return String(String(describing: type(of: self)).split(separator: ".").last ?? "LaunchTask")
    }
}

open class ClosureTask: LaunchTask {
    public let closure: (([AnyHashable: Any]?) -> Void)
    
    public init(name: String, queue: TaskQueue = .mainQueue, closure: @escaping ([AnyHashable : Any]?) -> Void) {
        self.closure = closure
        super.init(name: name, queue: queue)
    }
    
    open override func main(context: [AnyHashable: Any]?) {
        closure(context)
    }
}

open class SelectorTask: LaunchTask {
    public let target: AnyObject
    public let selector: Selector
    
    public init(name: String, queue: TaskQueue = .mainQueue, target: AnyObject, selector: Selector) {
        self.target = target
        self.selector = selector
        super.init(name: name, queue: queue)
    }
    
    open override func main(context: [AnyHashable: Any]?) {
        let _ = target.perform(selector)
    }
}
