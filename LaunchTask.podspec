#
# Be sure to run `pod lib lint LaunchTask.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LaunchTask'
  s.version          = '0.1.0'
  s.summary          = 'This is a lib for managing App launch tasks.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  This is a lib for managing App launch tasks.
  A large App often needs to perform a large number of tasks during the launch phase. 
  If there are many app developers, it is easy to cause the code of AppDelegate to be modified frequently and become more and more bloated. 
  It is also easy to cause the launch time of the App to be longer, and it will eventually be killed by Watchdog.
  This lib encapsulates the launch code into subclasses of each Task, and configures the execution order and dependencies of Tasks through Workflow. At the same time, by blocking the didFinishLaunch method, tasks are executed concurrently to speed up the launch time.
                       DESC

  s.homepage         = 'https://github.com/jayden320/launch-task'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jayden Liu' => '67111677@qq.com' }
  s.swift_version = '5.0'
  s.source           = { :git => 'https://github.com/jayden320/launch-task.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'LaunchTask/Classes/**/*'
  
  # s.resource_bundles = {
  #   'LaunchTask' => ['LaunchTask/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
