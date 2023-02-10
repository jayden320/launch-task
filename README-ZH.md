# LaunchTask

Language: [English](README.md) | 中文

这是一个管理App启动任务的框架。
一个大型的App往往需要在启动阶段执行大量的任务。如果App的开发人员很多，容易导致AppDelegate的代码频繁修改，越来越臃肿。也容易导致App的启动时长变长，最终被Watchdog杀死。
本框架是将启动的代码封装到一个个Task的子类中，通过Workflow配置Task的执行顺序和依赖。同时通过阻塞didFinishLaunch方法，并发执行任务，加快启动时间。

## Example

假设在App启动的时候，需要执行下图中的初始化步骤。则可以通过两个Workflow来管理。
<img src="https://github.com/jayden320/launch-task/blob/master/example.jpg">
didFinishLaunch阶段
```
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var launchWorkflow = TaskWorkflow(name: "Launch")
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
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

```
viewDidAppear阶段
```
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

```
以上示例是直接在viewDidAppear中执行workflow的start方法。如果想在首帧渲染完成后执行特定的任务，也可以在CFRunLoopActivity.beforeTimers回调中执行start方法。

## Install
```
pod 'LaunchTask'
```

## Author

Jayden Liu

## License

LaunchTask is available under the MIT license. See the LICENSE file for more info.