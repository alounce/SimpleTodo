platform :ios, '11.0'

target 'SimpleTodo' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SimpleTodo
  pod 'Moya'
  pod 'Alamofire'
  pod 'SCLAlertView', :git => 'https://github.com/vikmeup/SCLAlertView-Swift.git'
  # Pods for testing
  pod 'OHHTTPStubs/Swift'

  target 'SimpleTodoTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'OHHTTPStubs/Swift'
  end
  
  target 'SimpleTodoUITests' do
      inherit! :search_paths
      # Pods for testing
      pod 'OHHTTPStubs/Swift'
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
