Pod::Spec.new do |s|
  s.name             = 'LaunchTask'
  s.version          = '0.1.1'
  s.summary          = 'LaunchTask is a lib for managing App launch tasks.'

  s.description      = <<-DESC
  LaunchTask is a lib for managing App launch tasks.
  LaunchTask encapsulates the launch code into subclasses of each task, and configures the execution order and dependencies of tasks through workflow. At the same time, the launch duration is accelerated by executing tasks concurrently.
                       DESC

  s.homepage         = 'https://github.com/jayden320/launch-task'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jayden Liu' => '67111677@qq.com' }
  s.swift_version = '5.0'
  s.source           = { :git => 'https://github.com/jayden320/launch-task.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'LaunchTask/Classes/**/*'
end
