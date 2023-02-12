//
//  TaskWorkflowTests.swift
//  LaunchTask_Tests
//
//  Created by Jayden Liu on 2023/2/9.
//

import XCTest
@testable import LaunchTask

final class TaskWorkflowTests: XCTestCase {
    func testStartWorkflow() throws {
        // Given
        let workflow = TaskWorkflow(name: "UT")
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
        
        let counter = TaskExecutionRecorder()
        for task in workflow.allTasks() {
            if let mockTask = task as? MockTask {
                XCTAssertEqual(mockTask.executionDuration(), 0)
                mockTask.recorder = counter
            }
        }
        XCTAssertEqual(workflow.state, .pending)

        // When
        workflow.start()

        // Then
        XCTAssertEqual(workflow.state, .finished)
        XCTAssertEqual(counter.taskExecutedInMainThread, ["TaskA", "TaskB", "TaskC", "TaskD", "TaskG", "TaskH"])
        XCTAssert(counter.taskExecutedInConcurrentThread.contains("TaskE"))
        XCTAssert(counter.taskExecutedInConcurrentThread.contains("TaskF"))
        for task in workflow.allTasks() {
            if let mockTask = task as? MockTask {
                XCTAssertNotEqual(mockTask.executionDuration(), 0)
            }
        }
    }

    class TaskExecutionRecorder {
        var taskExecutedInMainThread = [String]()
        var taskExecutedInConcurrentThread = [String]()

        func record(_ task: MockTask) {
            let taskClassName = String(describing: type(of: task))
            if task.queue == .mainQueue {
                taskExecutedInMainThread.append(taskClassName)
            } else {
                taskExecutedInConcurrentThread.append(taskClassName)
            }
        }
    }

    class MockTask: LaunchTask {
        var recorder: TaskExecutionRecorder?

        override func main(context: [AnyHashable: Any]?) {
            recorder?.record(self)
        }
    }

    class TaskA: MockTask {}
    class TaskB: MockTask {}
    class TaskC: MockTask {}
    class TaskD: MockTask {}
    class TaskE: MockTask {}
    class TaskF: MockTask {}
    class TaskG: MockTask {}
    class TaskH: MockTask {}
}
