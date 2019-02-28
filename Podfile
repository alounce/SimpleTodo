platform :ios, '11.0'

# Pods for SimpleTodo
def appPods
  use_frameworks!
  pod 'Moya'
  pod 'Alamofire'
  pod 'SCLAlertView', :git => 'https://github.com/vikmeup/SCLAlertView-Swift.git'
  pod 'OHHTTPStubs/Swift'
end

target 'SimpleTodo' do
  appPods
  target 'SimpleTodoTests' do
    inherit! :search_paths
    appPods
  end
  
  target 'SimpleTodoUITests' do
      inherit! :search_paths
      appPods
  end

# Disable Code Coverage for Pods projects
post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_ENABLE_CODE_COVERAGE'] = 'NO'
        end
    end
end

end
